//
//  TokenEndpoint.swift
//
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Tagged

public extension Endpoint {
    static func token(
        withAppIdentifier appIdentifier: App.Idenitifer,
        appSecret: App.Secret,
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

public struct Token: Codable {
    public enum Scope: String, Codable {
        case all
    }

    public enum `Type`: String, Codable {
        case bearer = "Bearer"
    }

    public let accessToken: AccessToken
    public let expiresAt: Date
    public let scope: Scope
    public let type: `Type`

    enum CodingKeys: String, CodingKey {
        case accessToken
        case expiresAt
        case scope
        case type = "tokenType"
    }

    public typealias AccessToken = Tagged<(Token, accessToken: ()), String>

    func isValid() -> Bool {
        return true
    }
}
