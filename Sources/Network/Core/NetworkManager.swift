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

extension Publisher {
   private func retryOnly<U: Publisher>(
         upstream: U,
         retries: Int,
         when predicate: @escaping (U.Failure) -> Bool
      ) -> AnyPublisher<U.Output, U.Failure> {

      upstream
         .map { v -> Result<U.Output, U.Failure> in .success(v) }
         .catch { err -> AnyPublisher<Result<U.Output, U.Failure>, U.Failure> in
            if predicate(err) {
               return Fail(error: err).eraseToAnyPublisher()
            } else {
               return Just(.failure(err))
                  .setFailureType(to: U.Failure.self)
                  .eraseToAnyPublisher()
            }
         }
         .retry(retries)
         .flatMap { result in result.publisher }
         .eraseToAnyPublisher()
   }

   func retry(_ retries: Int, when predicate: @escaping (Failure) -> Bool) -> AnyPublisher<Output, Failure> {
      return retryOnly(upstream: self, retries: retries, when: predicate)
   }
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

    public func publisher<Response: Decodable>(for endpoint: Endpoint<Response>) -> AnyPublisher<Response, NetworkError> {
        return authenticator.validToken(onEnvironment: endpoint.environment)
            .map { token in
                var endpoint = endpoint
                endpoint.token = token
                return endpoint
            }
            .flatMap { [self] endpoint in
                urlSession.publisher(for: endpoint)
            }
            .retry(1, when: { [self] networkError in
                if case .httpError(let httpError) = networkError {
                    if case .invalidResponse(let statusCode, _) = httpError, statusCode == .unauthorized {
                        authenticator.invalidateToken()
                        return true
                    }
                }
                return false
            })
            .eraseToAnyPublisher()
    }
//            .tryCatch { [self] _ in
//                return authenticator.validToken(
//                    forceRefresh: true,
//                    onEnvironment: endpoint.environment
//                )
//                    .map { token in
//                        var endpoint = endpoint
//                        endpoint.token = token
//                        return endpoint
//                    }
//                    .flatMap { [self] endpoint in
//                        urlSession.publisher(for: endpoint).eraseToAnyPublisher()
//                    }

//                if case .httpError(let httpError) = networkError {
//                    if case .invalidResponse(let statusCode, _) = httpError, statusCode == .unauthorized {
//                        return authenticator.validToken(
//                            forceRefresh: true,
//                            onEnvironment: endpoint.environment
//                        )
//                            .map { token in
//                                var endpoint = endpoint
//                                endpoint.token = token
//                                return endpoint
//                            }
//                            .flatMap { [self] endpoint in
//                                urlSession.publisher(for: endpoint)
//                            }
////                            .setFailureType(to: NetworkError.self)
//                    }
//                }
//                throw networkError
//            }
//            .mapError({ $0 as! NetworkError })
//            .eraseToAnyPublisher()
//    }
}

extension NetworkManager: AuthenticatorDelegate {
    func authenticator(_ authenticator: Authenticator, didUpdateCredentials credentials: Credentials?) {
        delegate?.networkManager(self, didUpdateCredentials: credentials)
    }
}
