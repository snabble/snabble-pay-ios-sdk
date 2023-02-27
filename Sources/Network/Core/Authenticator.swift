//
//  Authenticator.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Dispatch
import Combine

protocol AuthenticatorDelegate: AnyObject {
    func authenticator(_ authenticator: Authenticator, didUpdateCredentials credentials: Credentials?)
}

public class Authenticator {
    public let urlSession: URLSession
    public let apiKey: String

    weak var delegate: AuthenticatorDelegate?

    private(set) var token: Token?
    private(set) var credentials: Credentials? {
        didSet {
            delegate?.authenticator(self, didUpdateCredentials: credentials)
        }
    }

    private let queue: DispatchQueue = .init(label: "io.snabble.pay.authenticator.\(UUID().uuidString)")

    private var refreshPublisher: AnyPublisher<Token, NetworkError>?

    init(apiKey: String, credentials: Credentials?, urlSession: URLSession) {
        self.urlSession = urlSession
        self.apiKey = apiKey
        self.credentials = credentials
    }

    func invalidateToken() {
        token = nil
    }

    private func validateCredentials(onEnvironment environment: Environment = .production) -> AnyPublisher<Credentials, NetworkError> {
        // scenario 1: app instance is registered
        if let credentials = self.credentials {
            return Just(credentials)
                .setFailureType(to: NetworkError.self)
                .eraseToAnyPublisher()
        }

        // scenario 2: we have to register the app instance
        let endpoint = Endpoints.Register.post(
            apiKeyValue: apiKey,
            onEnvironment: environment
        )
        let publisher = urlSession.publisher(for: endpoint)
            .handleEvents(receiveOutput: { [weak self] credentials in
                self?.credentials = credentials
            }, receiveCompletion: { _ in })
            .eraseToAnyPublisher()
        return publisher
    }

    func validToken(
        forceRefresh: Bool = false,
        onEnvironment environment: Environment = .production
    ) -> AnyPublisher<Token, NetworkError> {
        return queue.sync { [weak self] in
            // scenario 1: we're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            // scenario 2: we already have a valid token and don't want to force a refresh
            if let token = token, token.isValid(), !forceRefresh {
                return Just(token)
                    .setFailureType(to: NetworkError.self)
                    .eraseToAnyPublisher()
            }

            // scenario 3: we need a new token
            let publisher = validateCredentials(onEnvironment: environment)
                .map { credentials -> Endpoint<Token> in
                    return Endpoints.Token.get(
                        withCredentials: credentials,
                        onEnvironment: environment
                    )
                }
                .tryMap { endpoint -> (URLSession, Endpoint<Token>) in
                    guard let urlSession = self?.urlSession else {
                        throw NetworkError.missingURLSession
                    }
                    return (urlSession, endpoint)
                }
                .flatMap { urlSession, endpoint in
                    return urlSession.publisher(for: endpoint)
                }
                .share()
                .handleEvents(receiveOutput: { token in
                    self?.token = token
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.refreshPublisher = nil
                    }
                })
                .eraseToAnyPublisher()

            self?.refreshPublisher = publisher
            return publisher
        }
    }
}
