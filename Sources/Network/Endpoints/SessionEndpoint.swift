//
//  SessionEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-19.
//

import Foundation
import Tagged

extension Endpoints {
    public static func session(onEnvironment environment: Environment = .production) -> Endpoint<Session> {
        return .init(path: "/apps/sessions", method: .post(nil), environment: environment)
    }

    public static func getSession(id: Session.ID, onEnvironment environment: Environment = .production) -> Endpoint<Session> {
        return .init(path: "/apps/sessions/\(id.rawValue)", method: .get(nil), environment: environment)
    }

    public static func deleteSession(id: Session.ID, onEnvironment environment: Environment = .production) -> Endpoint<Session> {
        return .init(path: "/apps/sessions/\(id.rawValue)", method: .delete, environment: environment)
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
    public let currenty: String
}


