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
        public static func get(
            withAppIdentifier appIdentifier: App.Idenitifer,
            appSecret: App.Secret,
            scope: SnabblePayNetwork.Token.Scope = .all,
            onEnvironment environment: Environment = .production
        ) -> Endpoint<SnabblePayNetwork.Token> {
            return .init(path: "/apps/token",
                         method: .get([
                            .init(name: "grant_type", value: "client_credentials"),
                            .init(name: "client_id", value: appIdentifier.rawValue),
                            .init(name: "client_secret", value: appSecret.rawValue),
                            .init(name: "scope", value: scope.rawValue)
                         ]),
                         environment: environment)
        }
    }
}

struct Token: Codable {
    enum Scope: String, Codable {
        case all
    }

    enum `Type`: String, Codable {
        case bearer = "Bearer"
    }

    let accessToken: AccessToken
    let expiresAt: Date
    let scope: Scope
    let type: `Type`

    enum CodingKeys: String, CodingKey {
        case accessToken
        case expiresAt
        case scope
        case type = "tokenType"
    }

    typealias AccessToken = Tagged<(Token, accessToken: ()), String>

    func isValid() -> Bool {
        return expiresAt.timeIntervalSinceNow.sign == .plus
    }
}
