//
//  SnabblePay.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-20.
//

import Foundation
import SnabblePayNetwork
import Combine

public class SnabblePay {
    public let networkManager: NetworkManager
    public var environment: Environment = .production

    public var apiKey: String {
        networkManager.authenticator.apiKey
    }

    public var urlSession: URLSession {
        networkManager.urlSession
    }

    private var cancellables = Set<AnyCancellable>()

    public init(apiKey: String, urlSession: URLSession = .shared) {
        self.networkManager = NetworkManager(apiKey: apiKey, urlSession: urlSession)
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

    public func delete(account: Account, completionHandler: @escaping (Result<Void, Error>) -> Void) {
        let endpoint = Endpoints.Accounts.delete(id: account.id, onEnvironment: environment)
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

    public func mandate(forAccount account: Account, completionHandler: @escaping (Result<Account.Mandate, Error>) -> Void) {
        let endpoint = Endpoints.Accounts.Mandate.get(accountId: account.id, onEnvironment: environment)
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

    public func acceptMandate(forAccount account: Account, completionHandler: @escaping (Result<Account.Mandate, Error>) -> Void) {
        let endpoint = Endpoints.Accounts.Mandate.accept(accountId: account.id, onEnvironment: environment)
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

    public func declineMandate(forAccount account: Account, completionHandler: @escaping (Result<Account.Mandate, Error>) -> Void) {
        let endpoint = Endpoints.Accounts.Mandate.decline(accountId: account.id, onEnvironment: environment)
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

    public func startSession(withAccount account: Account, completionHandler: @escaping (Result<Session, Error>) -> Void) {
        let endpoint = Endpoints.Session.post(withAccountId: account.id, onEnvironment: environment)
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
