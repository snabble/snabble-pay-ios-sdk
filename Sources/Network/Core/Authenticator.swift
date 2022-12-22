//
//  Authenticator.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Dispatch
import Combine
import KeychainAccess

class Authenticator {
    let session: URLSession

    @KeychainStorage("token", service: "io.snabble.pay.authenticator")
    private(set) var token: Token?

//    @KeychainStorage("app", service: "io.snabble.pay.authenticator")
    private(set) var app: App?

    private let queue: DispatchQueue = .init(label: "io.snabble.pay.authenticator.\(UUID().uuidString)")

    private var refreshPublisher: AnyPublisher<Token, Swift.Error>?

    init(session: URLSession = .shared) {
        self.session = session
    }

    private func validateApp(onEnvironment environment: Environment = .production) -> AnyPublisher<App, Swift.Error> {
        // scenario 1: app instance is registered
        if let app = self.app {
            return Just(app)
                .setFailureType(to: Swift.Error.self)
                .eraseToAnyPublisher()
        }

        // scenario 2: we have to register the app instance
        let endpoint: Endpoint<App> = .register(onEnvironment: environment)
        let publisher = session.publisher(for: endpoint)
            .handleEvents(receiveOutput: { [weak self] app in
                self?.app = app
            }, receiveCompletion: { _ in })
            .eraseToAnyPublisher()
        return publisher
    }

    func validToken(
        forceRefresh: Bool = false,
        onEnvironment environment: Environment = .production
    ) -> AnyPublisher<Token, Swift.Error> {
        return queue.sync { [weak self] in
            // scenario 1: we're already loading a new token
            if let publisher = self?.refreshPublisher {
                return publisher
            }

            // scenario 2: we already have a valid token and don't want to force a refresh
            if let token = token, token.isValid(), !forceRefresh {
                return Just(token)
                    .setFailureType(to: Swift.Error.self)
                    .eraseToAnyPublisher()
            }

            // scenario 3: we need a new token
            let publisher = validateApp(onEnvironment: environment)
                .map { app -> Endpoint<Token> in
                    print("app:", app)
                    return .token(
                        withAppIdentifier: app.identifier,
                        appSecret: app.secret,
                        onEnvironment: environment
                    )
                }
                .flatMap { endpoint in
                    print("endpoint:", endpoint.urlRequest)
                    return self!.session.publisher(for: endpoint)
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
