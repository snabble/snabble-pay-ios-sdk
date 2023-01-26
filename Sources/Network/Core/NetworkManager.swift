//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

extension CodingUserInfoKey {
    static let urlScheme = CodingUserInfoKey(rawValue: "urlScheme")!
}

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
    public let decoder: JSONDecoder

    let authenticator: Authenticator

    public init(session: URLSession = .shared, config: NetworkConfig) {
        self.session = session
        self.config = config

        let decoder = JSONDecoder()
        decoder.userInfo[.urlScheme] = config.customUrlScheme
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        self.authenticator = Authenticator(
            session: session,
            customUrlScheme: config.customUrlScheme,
            apiKey: config.apiKey
        )
    }

    public func publisher<Response: Decodable>(for endpoint: Endpoint<Response>) -> AnyPublisher<Response, Swift.Error> {
        return authenticator.validToken(using: decoder, onEnvironment: endpoint.environment)
            .map { token in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { endpoint in
                session.publisher(for: endpoint, using: decoder)
            }
            .tryCatch { error in
                if case HTTPError.invalidResponse(let statusCode) = error, statusCode == .unauthorized {
                    return authenticator.validToken(using: decoder, forceRefresh: true, onEnvironment: endpoint.environment)
                        .map { token in
                            var endpoint = endpoint
                            endpoint.token = token
                            return endpoint
                        }
                        .flatMap { endpoint in
                            session.publisher(for: endpoint, using: decoder)
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
