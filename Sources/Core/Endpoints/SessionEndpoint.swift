//
//  SessionEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-19.
//

import Foundation
import Tagged
import SnabblePayNetwork

typealias ModelSession = Session

extension Endpoints {
    enum Session {
        static func post(withAccountId accountId: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<ModelSession> {
            let jsonObject = ["accountId": accountId.rawValue]
            return .init(
                path: "/apps/sessions",
                // swiftlint:disable:next force_try
                method: .post(try! JSONSerialization.data(withJSONObject: jsonObject)),
                environment: environment
            )
        }

        static func get(onEnvironment environment: Environment = .production) -> Endpoint<[ModelSession]> {
            return .init(path: "/apps/sessions", method: .get(nil), environment: environment)
        }

        static func get(id: ModelSession.ID, onEnvironment environment: Environment = .production) -> Endpoint<ModelSession> {
            return .init(path: "/apps/sessions/\(id.rawValue)", method: .get(nil), environment: environment)
        }

        static func delete(id: ModelSession.ID, onEnvironment environment: Environment = .production) -> Endpoint<ModelSession> {
            return .init(path: "/apps/sessions/\(id.rawValue)", method: .delete, environment: environment)
        }
    }
}
