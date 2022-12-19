//
//  Authenticator.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Dispatch
import Combine

class Authenticator {

    enum AuthenticatorError: Error {
        case registrationRequired
        case loginRequired
    }

    let session: URLSession
    private(set) var token: Token? {
        didSet {
            print("save token")
        }
    }
    private(set) var credentials: Credentials? {
        didSet {
            print("save credentials")
        }
    }
    private let queue: DispatchQueue = .init(label: "io.snabble.pay.authenticator.\(UUID().uuidString)")

    private var credentialsPublisher: AnyPublisher<Credentials, Swift.Error>?
    private var tokenPublisher: AnyPublisher<Token, Swift.Error>?

    init(session: URLSession = .shared) {
        self.session = session
        self.credentials = nil // load credentials
        self.token = nil // load token
    }

    func validateApp(onEnvironment environment: Environment = .production) -> AnyPublisher<Credentials, Swift.Error> {
        return queue.sync { [weak self] in
            // scenario 1: we're already registrating the app instance
            if let publisher = self?.credentialsPublisher {
                return publisher
            }

            // scenario 2: app instance is registered
            if let credentials = self?.credentials {
                return Just(credentials)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            // scenario 3: we have to register the app instance
            let endpoint: Endpoint<Credentials> = .credentials(onEnvironment: environment)
            let publisher = session.publisher(for: endpoint)
                .handleEvents(receiveOutput: { credentials in
                    self?.credentials = credentials
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.credentialsPublisher = nil
                    }
                })
                .eraseToAnyPublisher()
            self?.credentialsPublisher = publisher
            return publisher
        }
    }


    func validToken(forceRefresh: Bool = false, onEnvironment environment: Environment = .production) -> AnyPublisher<Token, Swift.Error> {
        return queue.sync { [weak self] in
            // scenario 1: we're already loading a new token
            if let publisher = self?.tokenPublisher {
                return publisher
            }

            // scenario 2: we don't have a token at all, the app instance needs to be registered
            guard let credentials = self?.credentials else {
                return Fail(error: AuthenticatorError.registrationRequired)
                    .eraseToAnyPublisher()
            }

            // scenario 3: we already have a valid token and don't want to force a refresh
            if let token = token, token.isValid(), !forceRefresh {
                return Just(token)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            // scenario 4: we need a new token
            let endpoint: Endpoint<Token> = .token(
                withAppIdentifier: credentials.appIdentifier,
                appSecret: credentials.appSecret,
                onEnvironment: environment
            )
            let publisher = session.publisher(for: endpoint)
                .share()
                .handleEvents(receiveOutput: { token in
                    self?.token = token
                }, receiveCompletion: { _ in
                    self?.queue.sync {
                        self?.tokenPublisher = nil
                    }
                })
                .eraseToAnyPublisher()

            self?.tokenPublisher = publisher
            return publisher
        }
    }
}
