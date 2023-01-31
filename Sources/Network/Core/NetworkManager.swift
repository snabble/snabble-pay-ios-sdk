//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

public struct NetworkManager {
    public let session: URLSession
    public let decoder: JSONDecoder

    let authenticator: Authenticator

    public init(apiKey: String, session: URLSession = .shared) {
        self.session = session

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self.decoder = decoder

        self.authenticator = Authenticator(
            apiKey: apiKey,
            session: session
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
