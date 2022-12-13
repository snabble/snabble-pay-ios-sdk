//
//  RegistrationEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

extension Endpoint {
    static func credentials(onEnvironment environment: Environment = .production) throws -> Endpoint<Credentials> {
        return .init(path: "/apps/credentials", method: .get(nil))
    }
}

struct Credentials: Decodable {
    let appIdentifier: String
    let appSecret: String
}
