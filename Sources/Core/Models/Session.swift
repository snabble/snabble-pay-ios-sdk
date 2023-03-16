//
//  Session.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation
import Tagged
import SnabblePayNetwork

/// The Session is the beginning a potentiel payment process
public struct Session {
    /// Unique identifier of a session
    public let id: ID
    /// The data for the QR code, which must be presented at the point of sale
    public let token: Token
    /// Date of creation
    public let createdAt: Date
    /// If a token has been presented at the point of sale a transaction might have been started
    public let transaction: Transaction?

    /// Type Safe Identifier
    public typealias ID = Tagged<Session, String>
}

extension Session {
    /// The transaction object of a `Session`
    public struct Transaction {
        /// Unique identifier of a transaction
        public let id: ID
        /// Current State of the transaction see `Session.Transaction.State`
        public let state: State
        /// A Integer that represents an amount of money in the minor unit of the `currencyCode`
        public let amount: Int
        /// A string that represents the used currency
        public let currencyCode: String

        /// Type Safe Identifier
        public typealias ID = Tagged<Transaction, String>

        /// Constants indicating the transaction's state
        public enum State: String, Decodable {
            /// Amount was sucessfully preauthorized
            case preauthorizationSuccessful = "PREAUTHORIZATION_SUCCESSFUL"
            /// Preauthorization failed
            case preauthorizationFailed = "PREAUTHORIZATION_FAILED"
            /// Transaction was successfuly captured
            case successful = "SUCCESSFUL"
            /// Capture failed
            case failed = "FAILED"
            /// Error while processing the transaction
            case errored = "ERRORED"
            /// Transaction aborted
            case aborted = "ABORTED"
        }
    }

    /// The object for the QR code, which must be presented at the point of sale
    public struct Token {
        /// Unique identifier of the token
        public let id: ID
        /// The string for the QR code, which must be presented at the point of sale
        public let value: String
        /// Date of creation
        public let createdAt: Date
        /// Date as soon as the token should be updated. See `SnabblePay.refreshToken(withSessionId:)`.
        public let refreshAt: Date
        /// Date until the token can be used to be shown at a point of sale
        public let validUntil: Date

        /// Type Safe Identifier
        public typealias ID = Tagged<Token, String>
    }
}

extension Session.Transaction.State: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Session.Transaction.State) {
        switch dto {
        case .preauthorizationSuccessful:
            self = .preauthorizationSuccessful
        case .preauthorizationFailed:
            self = .preauthorizationFailed
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
        self.currencyCode = dto.currencyCode
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
