//
//  AccountsEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-25.
//

import Foundation
import Tagged
import Combine
import SnabblePayNetwork

extension Endpoints {
    public enum Accounts {
        public static func check(appUri: URL, city: String, countryCode: String, onEnvironment environment: Environment = .production) -> Endpoint<Account.Check> {
            .init(path: "/apps/accounts/check",
                  method: .get(
                    [
                        .init(name: "appUri", value: appUri.absoluteString),
                        .init(name: "countryCode", value: countryCode),
                        .init(name: "city", value: city)
                    ]
                  ),
                  environment: environment
            )
        }
        public static func get(onEnvironment environment: Environment = .production) -> Endpoint<[Account]> {
            .init(path: "/apps/accounts", method: .get(nil), environment: environment)
        }

        public static func get(id: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account> {
            .init(path: "/apps/accounts/\(id.rawValue)", method: .get(nil), environment: environment)
        }

        public static func delete(id: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account> {
            .init(path: "/apps/accounts/\(id.rawValue)", method: .delete, environment: environment)
        }
    }
}
