//
//  SessionEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-19.
//

import Foundation
import Tagged
import SnabblePayNetwork

public typealias ModelSession = Session

extension Endpoints {
    public enum Session {
        public static func post(withAccountId accountId: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<ModelSession> {
            let jsonObject = ["accountId": accountId.rawValue]
            return .init(
                path: "/apps/session",
                // swiftlint:disable:next force_try
                method: .post(try! JSONSerialization.data(withJSONObject: jsonObject)),
                environment: environment
            )
        }

        public static func get(id: ModelSession.ID, onEnvironment environment: Environment = .production) -> Endpoint<ModelSession> {
            return .init(path: "/apps/session/\(id.rawValue)", method: .get(nil), environment: environment)
        }

        public static func delete(id: ModelSession.ID, onEnvironment environment: Environment = .production) -> Endpoint<Data> {
            return .init(path: "/apps/session/\(id.rawValue)", method: .delete, environment: environment)
        }
    }
}
