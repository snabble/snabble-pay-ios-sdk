//
//  SessionEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-19.
//

import Foundation
import Tagged

extension Endpoints {
    public enum Session {
        public static func post(onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Session> {
            return .init(path: "/apps/session", method: .post(nil), environment: environment)
        }

        public static func get(id: SnabblePayNetwork.Session.ID, onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Session> {
            return .init(path: "/apps/session/\(id.rawValue)", method: .get(nil), environment: environment)
        }

        public static func delete(id: SnabblePayNetwork.Session.ID, onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Session> {
            return .init(path: "/apps/session/\(id.rawValue)", method: .delete, environment: environment)
        }
    }
}

public struct Session: Decodable {
    public typealias ID = Tagged<Session, String>
    public typealias Token = Tagged<(Session, token: ()), String>

    public let id: ID
    public let token: Token
    public let createdAt: Date
    public let refreshAt: Date
    public let validUntil: Date
    public let transaction: Transaction?
}

public struct Transaction: Decodable {
    public typealias ID = Tagged<Transaction, String>

    public enum State: String, Decodable {
        case ongoing = "ONGOING"
        case pending = "PENDING"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
        case errored = "ERRORED"
        case aborted = "ABORTED"
    }

    public let id: ID
    public let state: State
    public let amount: String
    public let currency: String
}
