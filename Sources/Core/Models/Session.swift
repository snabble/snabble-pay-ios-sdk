//
//  Session.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation
import Tagged

public struct Session: Decodable {
    public let id: ID
    public let token: Token
    public let createdAt: Date
    public let refreshAt: Date
    public let validUntil: Date
    public let transaction: Transaction?

    public typealias ID = Tagged<Session, String>
    public typealias Token = Tagged<(Session, token: ()), String>
}

public struct Transaction: Decodable {
    public let id: ID
    public let state: State
    public let amount: String
    public let currency: String

    public typealias ID = Tagged<Transaction, String>

    public enum State: String, Decodable {
        case ongoing = "ONGOING"
        case pending = "PENDING"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
        case errored = "ERRORED"
        case aborted = "ABORTED"
    }
}
