//
//  TokenEndpoint.swift
//
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

extension Endpoints {
    enum Token {
        static func get(
            withCredentials credentials: Credentials,
            scope: SnabblePayNetwork.Token.Scope = .all,
            onEnvironment environment: Environment = .production
        ) -> Endpoint<SnabblePayNetwork.Token> {
            let jsonObject = [
                "grant_type": "client_credentials",
                "client_id": credentials.identifier,
                "client_secret": credentials.secret,
                "scope": scope.rawValue
            ]
            let data = try! JSONSerialization.data(withJSONObject: jsonObject)
            var endpoint: Endpoint<SnabblePayNetwork.Token> = .init(path: "/apps/token",
                                                                    method: .post(data),
                                                                    environment: environment
            )
            endpoint.headerFields = ["Content-Type": "application/x-www-form-urlencoded"]
            return endpoint
        }
    }
}
