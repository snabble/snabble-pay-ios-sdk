//
//  TokenEndpoint.swift
//
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Tagged

extension Endpoint {
    static func token(
        withAppIdentifier appIdentifier: Credentials.AppIdenitifer,
        appSecret: Credentials.AppSecret,
        scope: Token.Scope = .all,
        onEnvironment environment: Environment = .production
    ) -> Endpoint<Token> {
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

struct Token: Decodable {
    enum Scope: String, Decodable {
        case all
    }

    enum `Type`: String, Decodable {
        case bearer = "Bearer"
    }

    let accessToken: AccessToken
    let expiresIn: TimeInterval
    let scope: Scope
    let tokenType: `Type`

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn = "expires_in"
        case scope
        case tokenType = "token_type"
    }

    typealias AccessToken = Tagged<(Token, accessToken: ()), String>

    func isValid() -> Bool {
        return true
    }
}
