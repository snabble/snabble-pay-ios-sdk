//
//  RegistrationEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

extension Endpoint {
    static func credentials(with appIdentifier: String, onEnvironment environment: Environment = .production) throws -> Endpoint<Credentials> {
        let jsonObject = ["appIdentifier": appIdentifier]
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject)
        return .init(path: "/apps/credentials", method: .post(jsonData))
    }
}

struct Credentials: Decodable {
    let appIdentifier: String
    let appSecret: String
}
