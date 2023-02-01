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
        public static func post(apiKeyValue: String, onEnvironment environment: Environment = .production) -> Endpoint<App> {
            var endpoint: Endpoint<App> = .init(path: "/apps/register", method: .post(nil), environment: environment)
            endpoint.headerFields = ["snabblePayKey": apiKeyValue]
            return endpoint
        }
    }
}

struct App: Codable {
    let identifier: Idenitifer
    let secret: Secret

    typealias Idenitifer = Tagged<(App, identifier: ()), String>
    typealias Secret = Tagged<(App, secret: ()), String>

    enum CodingKeys: String, CodingKey {
        case identifier = "appIdentifier"
        case secret = "appSecret"
    }
}
