//
//  RegisterEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

extension Endpoints {
    enum Register {
        static func post(apiKeyValue: String, onEnvironment environment: Environment = .production) -> Endpoint<Credentials> {
            var endpoint: Endpoint<Credentials> = .init(path: "/apps/register", method: .post(nil), environment: environment)
            endpoint.headerFields = ["snabblePayKey": apiKeyValue]
            return endpoint
        }
    }
}
