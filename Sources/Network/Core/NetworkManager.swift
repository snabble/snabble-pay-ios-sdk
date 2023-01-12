//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

public struct NetworkConfig {
    let customUrlScheme: String
    let apiKeyValue: String
}

public struct NetworkManager {
    public let session: URLSession
    let authenticator: Authenticator
    let config: NetworkConfig

    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public init(session: URLSession = .shared, config: NetworkConfig) {
        self.session = session
        self.config = config
        self.authenticator = Authenticator(
            session: session,
            customUrlScheme: config.customUrlScheme,
            apiKeyValue: config.apiKeyValue
        )
    }

    public func publisher<Response: Decodable>(for endpoint: Endpoint<Response>) -> AnyPublisher<Response, Swift.Error> {
        return authenticator.validToken(using: Self.decoder, onEnvironment: endpoint.environment)
            .map { token in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { endpoint in
                session.publisher(for: endpoint, using: Self.decoder)
            }
            .tryCatch { error in
                if case HTTPError.invalidResponse(let statusCode) = error, statusCode == .unauthorized {
                    return authenticator.validToken(using: Self.decoder, forceRefresh: true, onEnvironment: endpoint.environment)
                        .map { token in
                            var endpoint = endpoint
                            endpoint.token = token
                            return endpoint
                        }
                        .flatMap { endpoint in
                            session.publisher(for: endpoint, using: Self.decoder)
                        }
                }
                throw error
            }
            .eraseToAnyPublisher()
    }
}
