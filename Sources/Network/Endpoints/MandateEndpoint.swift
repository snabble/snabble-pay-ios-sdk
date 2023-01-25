//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-23.
//

import Foundation

extension Endpoints.Account.Credentials {
    public enum Mandate {
        public static func get(credentialsId: Account.Credentials.ID, onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Account.Credentials.Mandate> {
            .init(
                path: "/apps/account/credentials/\(credentialsId.rawValue)/mandate",
                method: .get(nil),
                environment: environment
            )
        }

        public static func accept(credentialsId: Account.Credentials.ID, onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Account.Credentials.Mandate> {
            .init(
                path: "/apps/account/credentials/\(credentialsId.rawValue)/mandate",
                method: .patch(data(for: .accept)),
                environment: environment
            )
        }

        public static func decline(credentialsId: Account.Credentials.ID, onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Account.Credentials.Mandate> {
            .init(
                path: "/apps/account/credentials/\(credentialsId.rawValue)/mandate",
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

extension Account.Credentials {
    public struct Mandate: Decodable {
        public let state: State
        public let text: String?

        public enum State: String, Decodable {
            case pending = "PENDING"
            case accepted = "ACCEPTED"
            case declined = "DECLINED"
        }
    }
}

extension Account.Credentials.Mandate: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }
}
