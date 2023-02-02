//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

public struct NetworkManager {
    public let urlSession: URLSession
    public let jsonDecoder: JSONDecoder

    public let authenticator: Authenticator

    public init(apiKey: String, urlSession: URLSession) {
        self.urlSession = urlSession

        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        self.jsonDecoder = jsonDecoder

        self.authenticator = Authenticator(
            apiKey: apiKey,
            urlSession: urlSession
        )
    }

    public func publisher<Response: Decodable>(for endpoint: Endpoint<Response>) -> AnyPublisher<Response, Swift.Error> {
        return authenticator.validToken(using: jsonDecoder, onEnvironment: endpoint.environment)
            .map { token in
                var endpoint = endpoint
                endpoint.token = token
                endpoint.jsonDecoder = jsonDecoder
                return endpoint
            }
            .flatMap { endpoint in
                urlSession.publisher(for: endpoint)
            }
            .tryCatch { error in
                if case HTTPError.invalidResponse(let statusCode) = error, statusCode == .unauthorized {
                    return authenticator.validToken(using: jsonDecoder, forceRefresh: true, onEnvironment: endpoint.environment)
                        .map { token in
                            var endpoint = endpoint
                            endpoint.token = token
                            endpoint.jsonDecoder = jsonDecoder
                            return endpoint
                        }
                        .flatMap { endpoint in
                            urlSession.publisher(for: endpoint)
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
