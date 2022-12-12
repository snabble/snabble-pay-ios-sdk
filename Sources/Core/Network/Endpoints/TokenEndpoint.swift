//
//  TokenEndpoint.swift
//
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

extension Endpoint {
    static func token(
        with appIdentifier: String,
        appSecret: String,
        scope: Token.Scope = .all,
        onEnvironment environment: Environmentable = Environment.production
    ) throws -> Endpoint<Token> {
        return .init(path: "/apps/token", method: .get([
            .init(name: "grant_type", value: "client_credentials"),
            .init(name: "client_id", value: appIdentifier),
            .init(name: "client_secret", value: appSecret),
            .init(name: "scope", value: scope.rawValue)
        ]))
    }
}

struct Token: Decodable {
    enum Scope: String, Decodable {
        case all
    }

    enum `Type`: String, Decodable {
        case bearer = "Bearer"
    }

    let accessToken: String
    let expiresIn: TimeInterval
    let scope: Scope
    let tokenType: `Type`

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case scope
        case tokenType = "token_type"
    }
}
