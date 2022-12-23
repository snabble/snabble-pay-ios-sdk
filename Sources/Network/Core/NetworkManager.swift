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
    let authenticator: Authenticator

    public static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    public init(session: URLSession = .shared) {
        self.session = session
        self.authenticator = Authenticator(session: session)
    }

    public func publisher<Response: Decodable>(
        for endpoint: Endpoint<Response>,
        using decoder: JSONDecoder = Self.decoder
    ) -> AnyPublisher<Response, Swift.Error> {
        return authenticator.validToken(onEnvironment: endpoint.environment)
            .map { token in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { endpoint in
                session.publisher(for: endpoint, using: decoder)
            }
            .tryCatch { error in
                print("error:", error)
                return authenticator.validToken(forceRefresh: true, onEnvironment: endpoint.environment)
                    .map { token in
                        var endpoint = endpoint
                        endpoint.token = token
                        return endpoint
                    }
                    .flatMap { endpoint in
                        session.publisher(for: endpoint, using: decoder)
                    }
            }
            .eraseToAnyPublisher()
    }
}
