//
//  TokenEndpoint.swift
//
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Tagged

extension Endpoints {
    enum Token {
        static func get(
            withCredentials credentials: Credentials,
            scope: SnabblePayNetwork.Token.Scope = .all,
            onEnvironment environment: Environment = .production
        ) -> Endpoint<SnabblePayNetwork.Token> {
            return .init(path: "/apps/token",
                         method: .get([
                            .init(name: "grant_type", value: "client_credentials"),
                            .init(name: "client_id", value: credentials.identifier),
                            .init(name: "client_secret", value: credentials.secret),
                            .init(name: "scope", value: scope.rawValue)
                         ]),
                         environment: environment)
        }
    }
}
