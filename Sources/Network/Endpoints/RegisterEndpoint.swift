//
//  RegisterEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Tagged

extension Endpoints {
    public enum Register {
        public static func post(apiKeyValue: String, onEnvironment environment: Environment = .production) -> Endpoint<App> {
            var endpoint: Endpoint<App> = .init(path: "/apps/register", method: .post(nil), environment: environment)
            endpoint.headerFields = ["snabblePayKey": apiKeyValue]
            return endpoint
        }
    }
}

public struct App: Codable {
    public let identifier: Idenitifer
    public let secret: Secret

    public typealias Idenitifer = Tagged<(App, identifier: ()), String>
    public typealias Secret = Tagged<(App, secret: ()), String>

    enum CodingKeys: String, CodingKey {
        case identifier = "appIdentifier"
        case secret = "appSecret"
    }
}
