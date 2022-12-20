//
//  RegisterEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation
import Tagged

extension Endpoint {
    static func register(onEnvironment environment: Environment = .production) -> Endpoint<App> {
        return .init(path: "/apps/register", method: .get(nil), environment: environment)
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
