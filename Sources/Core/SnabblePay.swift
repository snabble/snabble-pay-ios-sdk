//
//  SnabblePay.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-20.
//

import Foundation
import SnabblePayNetwork
import Combine
import Tagged

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
        self.networkManager = NetworkManager(apiKey: apiKey, credentials: credentials?.toDTO(), urlSession: urlSession)
        self.networkManager.delegate = self
    }
}

// MARK: Combine
extension SnabblePay {

    /// Asks for a new mandate
    /// - Parameters:
    ///   - appUri: Callback URLScheme to inform the app that the process is completed
    ///   - city: The city of residence
    ///   - countryCode: The countryCode [PayOne - ISO 3166](https://docs.payone.com/pages/releaseview.action?pageId=1213959) of residence.
    /// - Returns: An account check publisher
    /// - Important: A list of supported two letter country codes from ISO 3166 can be found here: https://docs.payone.com/pages/releaseview.action?pageId=1213959
    public func accountCheck(withAppUri appUri: URL, city: String, countryCode: String) -> AnyPublisher<Account.Check, SnabblePay.Error> {
        let endpoint = Endpoints.Accounts.check(
            appUri: appUri,
            city: city,
            countryCode: countryCode,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func accounts() -> AnyPublisher<[Account], SnabblePay.Error> {
        let endpoint = Endpoints.Accounts.get(
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func account(withId id: Account.ID) -> AnyPublisher<Account, SnabblePay.Error> {
        let endpoint = Endpoints.Accounts.get(
            id: id.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func deleteAccount(withId id: Account.ID) -> AnyPublisher<Account, SnabblePay.Error> {
        let endpoint = Endpoints.Accounts.delete(
            id: id.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func createMandate(forAccountId accountId: Account.ID) -> AnyPublisher<Account.Mandate, SnabblePay.Error> {
        let endpoint = Endpoints.Accounts.Mandate.post(
            forAccountId: accountId.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func mandate(forAccountId accountId: Account.ID) -> AnyPublisher<Account.Mandate, SnabblePay.Error> {
        let endpoint = Endpoints.Accounts.Mandate.get(
            forAccountId: accountId.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func acceptMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID) -> AnyPublisher<Account.Mandate, SnabblePay.Error> {
        let endpoint = Endpoints.Accounts.Mandate.accept(
            mandateId: mandateId.rawValue,
            forAccountId: accountId.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func declineMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID) -> AnyPublisher<Account.Mandate, SnabblePay.Error> {
        let endpoint = Endpoints.Accounts.Mandate.decline(
            mandateId: mandateId.rawValue,
            forAccountId: accountId.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func sessions() -> AnyPublisher<[Session], SnabblePay.Error> {
        let endpoint = Endpoints.Session.get(
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func startSession(withAccountId accountId: Account.ID) -> AnyPublisher<Session, SnabblePay.Error> {
        let endpoint = Endpoints.Session.post(
            withAccountId: accountId.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func refreshToken(withSessionId sessionId: Session.ID) -> AnyPublisher<Session.Token, SnabblePay.Error> {
        let endpoint = Endpoints.Session.Token.post(
            sessionId: sessionId.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func session(withId id: Session.ID) -> AnyPublisher<Session, SnabblePay.Error> {
        let endpoint = Endpoints.Session.get(
            id: id.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    public func deleteSession(withId id: Session.ID) -> AnyPublisher<Session, SnabblePay.Error> {
        let endpoint = Endpoints.Session.delete(
            id: id.rawValue,
            onEnvironment: environment
        )
        return networkManager.publisher(for: endpoint)
            .map { $0.toModel() }
            .mapError { $0.toModel() }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

// MARK: Completion Handler
extension SnabblePay {
    public func accountCheck(withAppUri appUri: URL, city: String, countryCode: String, completionHandler: @escaping (Result<Account.Check, SnabblePay.Error>) -> Void) {
        accountCheck(withAppUri: appUri, city: city, countryCode: countryCode)
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

    public func accounts(completionHandler: @escaping (Result<[Account], SnabblePay.Error>) -> Void) {
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

    public func account(withId id: Account.ID, completionHandler: @escaping (Result<Account, SnabblePay.Error>) -> Void) {
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

    public func deleteAccount(withId id: Account.ID, completionHandler: @escaping (Result<Account, SnabblePay.Error>) -> Void) {
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

    public func createMandate(forAccountId accountId: Account.ID, completionHandler: @escaping (Result<Account.Mandate, SnabblePay.Error>) -> Void) {
        createMandate(forAccountId: accountId)
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

    public func mandate(forAccountId accountId: Account.ID, completionHandler: @escaping (Result<Account.Mandate, SnabblePay.Error>) -> Void) {
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

    public func acceptMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID, completionHandler: @escaping (Result<Account.Mandate, SnabblePay.Error>) -> Void) {
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

    public func declineMandate(withId mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID, completionHandler: @escaping (Result<Account.Mandate, SnabblePay.Error>) -> Void) {
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

    public func sessions(completionHandler: @escaping (Result<[Session], SnabblePay.Error>) -> Void) {
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

    public func startSession(withAccountId accountId: Account.ID, completionHandler: @escaping (Result<Session, SnabblePay.Error>) -> Void) {
        startSession(withAccountId: accountId)
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

    public func refreshToken(withSessionId sessionId: Session.ID, completionHandler: @escaping (Result<Session.Token, SnabblePay.Error>) -> Void) {
        refreshToken(withSessionId: sessionId)
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

    public func session(withId id: Session.ID, completionHandler: @escaping (Result<Session, SnabblePay.Error>) -> Void) {
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

    public func deleteSession(withId id: Session.ID, completionHandler: @escaping (Result<Session, SnabblePay.Error>) -> Void) {
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
