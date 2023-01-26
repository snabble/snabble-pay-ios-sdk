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
        public static func post(customUrlScheme: String, apiKeyValue: String, onEnvironment environment: Environment = .production) -> Endpoint<App> {
            let jsonObject = ["appUrlScheme": customUrlScheme]
            // swiftlint:disable:next force_try
            let dataObject = try! JSONSerialization.data(withJSONObject: jsonObject)
            var endpoint: Endpoint<App> = .init(path: "/apps/register", method: .post(dataObject), environment: environment)
            endpoint.headerFields = ["snabblePayKey": apiKeyValue]
            return endpoint
        }
    }
}

public struct App: Codable {
    public let identifier: Idenitifer
    public let secret: Secret
    public let urlScheme: UrlScheme

    public typealias Idenitifer = Tagged<(App, identifier: ()), String>
    public typealias Secret = Tagged<(App, secret: ()), String>
    public typealias UrlScheme = Tagged<(App, urlScheme: ()), String>

    enum CodingKeys: String, CodingKey {
        case identifier = "appIdentifier"
        case secret = "appSecret"
        case urlScheme = "appUrlScheme"
    }
}
