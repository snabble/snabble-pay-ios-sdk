//
//  AccountEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Tagged
import Combine

extension Endpoints {
    public enum Account {
        public static func get(onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Account> {
            .init(path: "/apps/account", method: .get(nil), environment: environment)
        }
    }
}

public struct Account: Decodable {
    public let credentials: [Credentials]
    public let validationURL: URL

    let urlScheme: String

    enum CodingKeys: String, CodingKey {
        case credentials
        case validationURL = "validationLink"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.credentials = try container.decode([Account.Credentials].self, forKey: .credentials)
        self.validationURL = try container.decode(URL.self, forKey: .validationURL)

        guard let urlScheme = decoder.userInfo[.urlScheme] as? String else {
            throw DecodingError.valueNotFound(String.self, .init(codingPath: [], debugDescription: "Missing URLScheme in decoders userInfo"))
        }
        self.urlScheme = urlScheme
    }

    public func validateCallbackURL(_ url: URL) -> Bool {
        guard url.scheme == urlScheme,
              url.host == "account",
              url.lastPathComponent == "validation" else {
            return false
        }
        return true
    }
}

extension Account: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.credentials == rhs.credentials
    }
}


