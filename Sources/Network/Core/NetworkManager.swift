//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

public protocol NetworkManagerDelegate: AnyObject {
    func networkManager(_ networkManager: NetworkManager, didUpdateCredentials credentials: Credentials?)
}

public class NetworkManager {
    public let urlSession: URLSession

    public weak var delegate: NetworkManagerDelegate?

    public let authenticator: Authenticator

    public init(apiKey: String, credentials: Credentials?, urlSession: URLSession) {
        self.urlSession = urlSession

        self.authenticator = Authenticator(
            apiKey: apiKey,
            credentials: credentials,
            urlSession: urlSession
        )
        self.authenticator.delegate = self
    }

    public func publisher<Response: Decodable>(for endpoint: Endpoint<Response>) -> AnyPublisher<Response, Swift.Error> {
        return authenticator.validToken(onEnvironment: endpoint.environment)
            .map { token in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { [self] endpoint in
                urlSession.publisher(for: endpoint)
            }
            .tryCatch { [self] error in
                if case HTTPError.invalidResponse(let statusCode, _) = error, statusCode == .unauthorized {
                    return authenticator.validToken(forceRefresh: true, onEnvironment: endpoint.environment)
                        .map { token in
                            var endpoint = endpoint
                            endpoint.token = token
                            return endpoint
                        }
                        .flatMap { [self] endpoint in
                            urlSession.publisher(for: endpoint)
                        }
                }
                throw error
            }
            .eraseToAnyPublisher()
    }
}

extension NetworkManager: AuthenticatorDelegate {
    func authenticator(_ authenticator: Authenticator, didUpdateCredentials credentials: Credentials?) {
        delegate?.networkManager(self, didUpdateCredentials: credentials)
    }
}
