//
//  NetworkManager.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Combine
import Foundation

struct NetworkManager {
    let session: URLSession

    let authenticator: Authenticator

    init(session: URLSession = .shared) {
        self.session = session
        self.authenticator = Authenticator(session: session)
    }

//    func performRequest<Response>(with endpoint: Endpoint<Response>) -> AnyPublisher<Response, Error> {
//        return authenticator.validate()
//            .flatMap({ token in
//                publisher(for: endpoint, withToken: token)
//            })
//            .tryCatch({ error -> AnyPublisher<Response, Error> in
//
//                return authenticator.validate(forceRefresh: true)
//                    .flatMap({ token in
//                        // we can now use this new token to authenticate the second attempt at making this request
//                        publisher(for: endpoint, withToken: token)
//                    })
//                    .eraseToAnyPublisher()
//            })
//        .eraseToAnyPublisher()
//    }
}

//extension NetworkManager {
//    private func publisher<Response>(for endpoint: Endpoint<Response>, withToken token: Token?) -> AnyPublisher<Response, Swift.Error> {
//        var endpoint = endpoint
//        if let token = token {
//            endpoint.addAuthorizationToken(token)
//        }
//        return session.publisher(for: endpoint)
//    }
//}
