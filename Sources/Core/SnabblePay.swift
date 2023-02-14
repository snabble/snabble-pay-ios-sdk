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

    public func accountCheck(withAppUri appUri: URL, completionHandler: @escaping (Result<Account.Check, Error>) -> Void) {
        let endpoint = Endpoints.Accounts.check(appUri: appUri, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
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
        let endpoint = Endpoints.Accounts.get(onEnvironment: environment)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
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
        let endpoint = Endpoints.Accounts.get(id: id, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
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

    public func deleteAccount(withId id: Account.ID, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = Endpoints.Accounts.delete(id: id, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .sink {
                switch $0 {
                case .finished:
                    completionHandler(.success(()))
                case let .failure(error):
                    completionHandler(.failure(error))
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }

    public func mandate(forAccountId accountId: Account.ID, completionHandler: @escaping (Result<Account.Mandate, Error>) -> Void) {
        let endpoint = Endpoints.Accounts.Mandate.get(accountId: accountId, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
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
        let endpoint = Endpoints.Accounts.Mandate.accept(mandateId: mandateId, forAccountId: accountId, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
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
        let endpoint = Endpoints.Accounts.Mandate.decline(mandateId: mandateId, forAccountId: accountId, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
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
        let endpoint = Endpoints.Session.get(onEnvironment: environment)
        networkManager.publisher(for: endpoint)
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
        let endpoint = Endpoints.Session.post(withAccountId: accountId, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
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
        let endpoint = Endpoints.Session.get(id: id, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
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
        let endpoint = Endpoints.Session.delete(id: id, onEnvironment: environment)
        networkManager.publisher(for: endpoint)
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

    public func reset() {
        networkManager.reset()
    }
}
