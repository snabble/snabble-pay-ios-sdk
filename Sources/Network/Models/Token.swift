//
//  Token.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-01.
//

import Foundation
import Tagged

struct Token: Codable {
    let accessToken: AccessToken
    let expiresAt: Date
    let scope: Scope
    let type: `Type`

    typealias AccessToken = Tagged<(Token, accessToken: ()), String>

    enum Scope: String, Codable {
        case all
    }

    enum `Type`: String, Codable {
        case bearer = "Bearer"
    }

    enum CodingKeys: String, CodingKey {
        case accessToken
        case expiresAt
        case scope
        case type = "tokenType"
    }

    func isValid() -> Bool {
        return expiresAt.timeIntervalSinceNow.sign == .plus
    }
}
