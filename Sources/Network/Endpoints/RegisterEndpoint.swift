//
//  RegisterEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Tagged

extension Endpoints {
    static func register(onEnvironment environment: Environment = .production) -> Endpoint<App> {
        return .init(path: "/apps/register", method: .get(nil), environment: environment)
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
