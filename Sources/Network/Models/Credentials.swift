//
//  Credentials.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-01.
//

import Foundation
import Tagged

public struct Credentials: Codable {
    public let identifier: Idenitifer
    public let secret: Secret

    public typealias Idenitifer = Tagged<(Credentials, identifier: ()), String>
    public typealias Secret = Tagged<(Credentials, secret: ()), String>

    enum CodingKeys: String, CodingKey {
        case identifier = "appIdentifier"
        case secret = "appSecret"
    }

    public init(identifier: Idenitifer, secret: Secret) {
        self.identifier = identifier
        self.secret = secret
    }
}
