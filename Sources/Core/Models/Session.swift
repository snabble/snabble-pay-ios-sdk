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

extension Session {
    public struct Error: Decodable {
        public let reason: Reason
        public let message: String?

        enum CodingKeys: String, CodingKey {
            case reason
            case message
        }

        enum RootKeys: String, CodingKey {
            case error
        }

        public enum Reason: String, Decodable {
            case mandateDeclined = "MANDATE_DECLINED"
            case mandatePending = "MANDATE_PENDING"
            case accountErrored = "ACCOUNT_ERRORED"
            case accountFailed = "ACCOUNT_FAILED"
            case unknown
        }

        public init(from decoder: Decoder) throws {
            let topLevelContainer = try decoder.container(keyedBy: RootKeys.self)
            let container = try topLevelContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
            self.reason = try container.decode(Session.Error.Reason.self, forKey: Session.Error.CodingKeys.reason)
            self.message = try container.decodeIfPresent(String.self, forKey: Session.Error.CodingKeys.message)
        }
    }
}

extension Session.Error.Reason {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
