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
    public let transaction: Transaction?

    public typealias ID = Tagged<Session, String>
}

extension Session {
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

    public struct Token {
        public let id: ID
        public let value: String
        public let createdAt: Date
        public let refreshAt: Date
        public let validUntil: Date

        public typealias ID = Tagged<Token, String>
    }
}

extension Session.Transaction.State: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Session.Transaction.State) {
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

extension Session.Token: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Session.Token) {
        self.id = ID(dto.id)
        self.value = dto.value
        self.createdAt = dto.createdAt
        self.refreshAt = dto.refreshAt
        self.validUntil = dto.validUntil
    }
}

extension Session.Transaction: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Session.Transaction) {
        self.id = ID(dto.id)
        self.state = .init(fromDTO: dto.state)
        self.amount = dto.amount
        self.currency = dto.currency
    }
}

extension Session: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Session) {
        self.id = ID(dto.id)
        self.token = .init(fromDTO: dto.token)
        self.createdAt = dto.createdAt
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

extension SnabblePayNetwork.Session.Token: ToModel {
    func toModel() -> Session.Token {
        .init(fromDTO: self)
    }
}
