//
//  RegisterEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Tagged

extension Endpoints {
    enum Register {
        static func post(apiKeyValue: String, onEnvironment environment: Environment = .production) -> Endpoint<App> {
            var endpoint: Endpoint<App> = .init(path: "/apps/register", method: .post(nil), environment: environment)
            endpoint.headerFields = ["snabblePayKey": apiKeyValue]
            return endpoint
        }
    }
}
