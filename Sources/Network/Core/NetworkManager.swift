//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

public struct NetworkConfig {
    public let customUrlScheme: String
    public let apiKey: String

    public init(customUrlScheme: String, apiKey: String) {
        self.customUrlScheme = customUrlScheme
        self.apiKey = apiKey
    }
}

public struct NetworkManager {
    public let session: URLSession
    public let config: NetworkConfig

    let authenticator: Authenticator

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
            apiKey: config.apiKey
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

    public func reset() {
        authenticator.reset()
    }
}
