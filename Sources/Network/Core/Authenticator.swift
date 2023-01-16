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
    let customUrlScheme: String
    let apiKey: String

    enum Error: Swift.Error {
        case unknown
    }

    @KeychainStorage("token", service: "io.snabble.pay.authenticator")
    private(set) var token: Token?

    @KeychainStorage("app", service: "io.snabble.pay.authenticator")
    private(set) var app: App?

    private let queue: DispatchQueue = .init(label: "io.snabble.pay.authenticator.\(UUID().uuidString)")

    private var refreshPublisher: AnyPublisher<Token, Swift.Error>?

    init(session: URLSession = .shared, customUrlScheme: String, apiKey: String) {
        self.session = session
        self.customUrlScheme = customUrlScheme
        self.apiKey = apiKey
    }

    private func validateApp(using decoder: JSONDecoder, onEnvironment environment: Environment = .production) -> AnyPublisher<App, Swift.Error> {
        // scenario 1: app instance is registered
        if let app = self.app {
            return Just(app)
                .setFailureType(to: Swift.Error.self)
                .eraseToAnyPublisher()
        }

        // scenario 2: we have to register the app instance
        let endpoint = Endpoints.register(
            customUrlScheme: customUrlScheme,
            apiKeyValue: apiKey,
            onEnvironment: environment
        )
        let publisher = session.publisher(for: endpoint, using: decoder)
            .handleEvents(receiveOutput: { [weak self] app in
                self?.app = app
            }, receiveCompletion: { _ in })
            .eraseToAnyPublisher()
        return publisher
    }

    func validToken(
        using decoder: JSONDecoder,
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
            let publisher = validateApp(using: decoder, onEnvironment: environment)
                .map { app -> Endpoint<Token> in
                    Endpoints.token(
                        withAppIdentifier: app.identifier,
                        appSecret: app.secret,
                        onEnvironment: environment
                    )
                }
                .tryMap { endpoint -> (URLSession, Endpoint<Token>) in
                    guard let session = self?.session else {
                        throw Error.unknown
                    }
                    return (session, endpoint)
                }
                .flatMap { session, endpoint in
                    return session.publisher(for: endpoint, using: decoder)
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

    func reset() {
        token = nil
        app = nil
    }
}
