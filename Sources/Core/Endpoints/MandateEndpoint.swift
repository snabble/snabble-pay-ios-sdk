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
        public static func create(forAccountId accountId: Account.ID, city: String, country: String, onEnvironment environment: Environment = .production) -> Endpoint<Account.Mandate> {
            let jsonObject = [
                "city": city,
                "country": country
            ]
            // swiftlint:disable:next force_try
            let jsonData = try! JSONSerialization.data(withJSONObject: jsonObject)
            return .init(
                path: "/apps/accounts/\(accountId.rawValue)/mandate",
                method: .post(jsonData),
                environment: environment
            )
        }

        public static func get(forAccountId accountId: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account.Mandate> {
            return .init(
                path: "/apps/accounts/\(accountId.rawValue)/mandate",
                method: .get(nil),
                environment: environment
            )
        }

        public static func accept(mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account.Mandate> {
            .init(
                path: "/apps/accounts/\(accountId.rawValue)/mandate",
                method: .patch(data(for: .accept, withMandateId: mandateId)),
                environment: environment
            )
        }

        public static func decline(mandateId: Account.Mandate.ID, forAccountId accountId: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account.Mandate> {
            .init(
                path: "/apps/accounts/\(accountId.rawValue)/mandate",
                method: .patch(data(for: .decline, withMandateId: mandateId)),
                environment: environment
            )
        }

        private enum Action: String {
            case accept = "ACCEPTED"
            case decline = "DECLINED"
        }

        // swiftlint:disable force_try
        private static func data(for action: Action, withMandateId mandateId: Account.Mandate.ID) -> Data {
            let jsonObject = [
                "id": mandateId.rawValue,
                "state": action.rawValue
            ]
            return try! JSONSerialization.data(withJSONObject: jsonObject)
        }
        // swiftlint:enable force_try
    }
}
