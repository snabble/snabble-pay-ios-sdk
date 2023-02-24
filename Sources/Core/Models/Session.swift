//
//  Session.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation
import Tagged
import SnabblePayNetwork

public struct Session {
    public let id: ID
    public let token: Token
    public let createdAt: Date
    public let refreshAt: Date
    public let validUntil: Date
    public let transaction: Transaction?

    public typealias ID = Tagged<Session, String>
    public typealias Token = Tagged<(Session, token: ()), String>
}

public struct Transaction {
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

extension Transaction.State: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Transaction.State) {
        switch dto {
        case .ongoing:
            self = .ongoing
        case .pending:
            self = .pending
        case .successful:
            self = .successful
        case .failed:
            self = .failed
        case .errored:
            self = .errored
        case .aborted:
            self = .aborted
        }
    }
}

extension Transaction: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Transaction) {
        self.id = ID(dto.id)
        self.state = .init(fromDTO: dto.state)
        self.amount = dto.amount
        self.currency = dto.currency
    }
}

extension Session: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Session) {
        self.id = ID(dto.id)
        self.token = Token(dto.token)
        self.createdAt = dto.createdAt
        self.refreshAt = dto.refreshAt
        self.validUntil = dto.validUntil
        if let transaction = dto.transaction {
            self.transaction = .init(fromDTO: transaction)
        } else {
            self.transaction = nil
        }
    }
}

extension SnabblePayNetwork.Session: ToModel {
    func toModel() -> Session {
        .init(fromDTO: self)
    }
}
