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

    private var refreshPublisher: AnyPublisher<Token, Swift.Error>?

    init(session: URLSession = .shared) {
        self.session = session
        self.credentials = nil // load credentials
        self.token = nil // load token
    }

    private func validateApp(onEnvironment environment: Environment = .production) -> AnyPublisher<Credentials, Swift.Error> {
        return queue.sync { [weak self] in
            // scenario 1: app instance is registered
            if let credentials = self?.credentials {
                return Just(credentials)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            // scenario 2: we have to register the app instance
            let endpoint: Endpoint<Credentials> = .credentials(onEnvironment: environment)
            let publisher = session.publisher(for: endpoint)
                .handleEvents(receiveOutput: { credentials in
                    self?.credentials = credentials
                }, receiveCompletion: { _ in })
                .eraseToAnyPublisher()
            return publisher
        }
    }


    func validToken(forceRefresh: Bool = false, onEnvironment environment: Environment = .production) -> AnyPublisher<Token, Swift.Error> {
        return queue.sync { [weak self] in
            // scenario 1: we're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            // scenario 2: we already have a valid token and don't want to force a refresh
            if let token = token, token.isValid(), !forceRefresh {
                return Just(token)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }

            // scenario 3: we need a new token
            let publisher = validateApp(onEnvironment: environment)
                .map { credentials -> Endpoint<Token> in
                    .token(
                        withAppIdentifier: credentials.appIdentifier,
                        appSecret: credentials.appSecret,
                        onEnvironment: environment
                    )
                }
                .flatMap { endpoint in
                    self!.session.publisher(for: endpoint)
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
