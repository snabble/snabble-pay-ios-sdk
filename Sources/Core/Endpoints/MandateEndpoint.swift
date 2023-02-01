//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-23.
//

import Foundation
import SnabblePayNetwork

extension Endpoints.Accounts {
    public enum Mandate {
        public static func get(accountId: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account.Mandate> {
            .init(
                path: "/apps/accounts/\(accountId.rawValue)/mandate",
                method: .get(nil),
                environment: environment
            )
        }

        public static func accept(accountId: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account.Mandate> {
            .init(
                path: "/apps/accounts/\(accountId.rawValue)/mandate",
                method: .patch(data(for: .accept)),
                environment: environment
            )
        }

        public static func decline(accountId: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account.Mandate> {
            .init(
                path: "/apps/accounts/\(accountId.rawValue)/mandate",
                method: .patch(data(for: .decline)),
                environment: environment
            )
        }

        private enum Action: String {
            case accept = "ACCEPTED"
            case decline = "DECLINED"
        }

        // swiftlint:disable force_try
        private static func data(for action: Action) -> Data {
            let jsonObject = ["state": action.rawValue]
            return try! JSONSerialization.data(withJSONObject: jsonObject)
        }
        // swiftlint:enable force_try
    }
}
