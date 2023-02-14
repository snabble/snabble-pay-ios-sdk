//
//  SnabblePay.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-20.
//

import Foundation
import SnabblePayNetwork
import Combine

public protocol SnabblePayDelegate: AnyObject {
    func snabblePay(_ snabblePay: SnabblePay, didUpdateCredentials credentials: Credentials?)
}

public class SnabblePay {
    public let networkManager: NetworkManager
    public var environment: Environment = .production

    public weak var delegate: SnabblePayDelegate?

    public var apiKey: String {
        networkManager.authenticator.apiKey
    }

    public var urlSession: URLSession {
        networkManager.urlSession
    }

    private var cancellables = Set<AnyCancellable>()

    public init(apiKey: String, credentials: Credentials?, urlSession: URLSession = .shared) {
        self.networkManager = NetworkManager(apiKey: apiKey, credentials: credentials, urlSession: urlSession)
        self.networkManager.delegate = self
    }
}

// MARK: Combine
extension SnabblePay {

    public func accountCheck(withAppUri appUri: URL) -> AnyPublisher<Account.Check, Error> {
        let endpoint = Endpoints.Accounts.check(
            appUri: appUri,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func accounts() -> AnyPublisher<[Account], Error> {
        let endpoint = Endpoints.Accounts.get(
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func account(withId id: Account.ID) -> AnyPublisher<Account, Error> {
        let endpoint = Endpoints.Accounts.get(
            id: id,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func deleteAccount(withId id: Account.ID) -> AnyPublisher<Account, Error> {
        let endpoint = Endpoints.Accounts.delete(
            id: id,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func mandate(forAccountId accountId: Account.ID) -> AnyPublisher<Account.Mandate, Error> {
        let endpoint = Endpoints.Accounts.Mandate.get(
            accountId: accountId,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func acceptMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID) -> AnyPublisher<Account.Mandate, Error> {
        let endpoint = Endpoints.Accounts.Mandate.accept(
            mandateId: mandateId,
            forAccountId: accountId,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func declineMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID) -> AnyPublisher<Account.Mandate, Error> {
        let endpoint = Endpoints.Accounts.Mandate.decline(
            mandateId: mandateId,
            forAccountId: accountId,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func sessions() -> AnyPublisher<[Session], Error> {
        let endpoint = Endpoints.Session.get(
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func session(withAccountId accountId: Account.ID) -> AnyPublisher<Session, Error> {
        let endpoint = Endpoints.Session.post(
            withAccountId: accountId,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func session(withId id: Session.ID) -> AnyPublisher<Session, Error> {
        let endpoint = Endpoints.Session.get(
            id: id,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func deleteSession(withId id: Session.ID) -> AnyPublisher<Session, Error> {
        let endpoint = Endpoints.Session.delete(
            id: id,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: Async

extension SnabblePay {
    public func accountCheck(withAppUri appUri: URL) async throws -> Account.Check {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = accountCheck(withAppUri: appUri)
                .sink { result in
                    switch result {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func accounts() async throws -> [Account] {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = accounts()
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func account(withId id: Account.ID) async throws -> Account {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = account(withId: id)
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func deleteAccount(withId id: Account.ID) async throws -> Account {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = deleteAccount(withId: id)
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func mandate(forAccountId accountId: Account.ID) async throws -> Account.Mandate {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = mandate(forAccountId: accountId)
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func acceptMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID) async throws -> Account.Mandate {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = acceptMandate(withId: mandateId, forAccountId: accountId)
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func declineMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID) async throws -> Account.Mandate {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = declineMandate(withId: mandateId, forAccountId: accountId)
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func sessions() async throws -> [Session] {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = sessions()
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func session(withAccountId accountId: Account.ID) async throws -> Session {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = session(withAccountId: accountId)
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func session(withId id: Session.ID) async throws -> Session {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = session(withId: id)
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }

    public func deleteSession(withId id: Session.ID) async throws -> Session {
        try await withCheckedThrowingContinuation({ continuation in
            var cancellable: AnyCancellable?

            cancellable = deleteSession(withId: id)
                .sink {
                    switch $0 {
                    case .finished:
                        break
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                    cancellable?.cancel()
                } receiveValue: {
                    continuation.resume(with: .success($0))
                }
        })
    }
}

// MARK: Completion Handler
extension SnabblePay {
    public func accountCheck(withAppUri appUri: URL, completionHandler: @escaping (Result<Account.Check, Error>) -> Void) {
        accountCheck(withAppUri: appUri)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func accounts(completionHandler: @escaping (Result<[Account], Error>) -> Void) {
        accounts()
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func account(withId id: Account.ID, completionHandler: @escaping (Result<Account, Error>) -> Void) {
        account(withId: id)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func deleteAccount(withId id: Account.ID, completionHandler: @escaping (Result<Account, Error>) -> Void) {
        deleteAccount(withId: id)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func mandate(forAccountId accountId: Account.ID, completionHandler: @escaping (Result<Account.Mandate, Error>) -> Void) {
        mandate(forAccountId: accountId)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func acceptMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID, completionHandler: @escaping (Result<Account.Mandate, Error>) -> Void) {
        acceptMandate(withId: mandateId, forAccountId: accountId)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func declineMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID, completionHandler: @escaping (Result<Account.Mandate, Error>) -> Void) {
        declineMandate(withId: mandateId, forAccountId: accountId)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func sessions(completionHandler: @escaping (Result<[Session], Error>) -> Void) {
        sessions()
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func session(withAccountId accountId: Account.ID, completionHandler: @escaping (Result<Session, Error>) -> Void) {
        session(withAccountId: accountId)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func session(withId id: Session.ID, completionHandler: @escaping (Result<Session, Error>) -> Void) {
        session(withId: id)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }

    public func deleteSession(withId id: Session.ID, completionHandler: @escaping (Result<Session, Error>) -> Void) {
        deleteSession(withId: id)
            .sink {
                switch $0 {
                case .finished:
                    break
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: {
                completionHandler(.success($0))
            }
            .store(in: &cancellables)
    }
}
