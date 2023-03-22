//
//  Endpoints+Error.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-27.
//

import Foundation

extension Endpoints {
    public struct Error: Decodable, Equatable {
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
            case notFound = "not_found"
            case mandateNotAccepted = "mandate_not_accepted"
            case validationError = "validation_error"
            case sessionTokenExpired = "session_token_expired"
            case transactionAlreadyStarted = "transaction_already_started"
            case invalidSessionState = "invalid_session_state"
            case invalidTransactionState = "invalid_transaction_state"
            case internalServerError = "internal_server_error"
            case unauthorized = "unauthorized"
            case unknown
        }

        public init(from decoder: Decoder) throws {
            let topLevelContainer = try decoder.container(keyedBy: RootKeys.self)
            let container = try topLevelContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
            self.reason = try container.decode(Endpoints.Error.Reason.self, forKey: Endpoints.Error.CodingKeys.reason)
            self.message = try container.decodeIfPresent(String.self, forKey: Endpoints.Error.CodingKeys.message)
        }

        private init(reason: Reason, message: String?) {
            self.reason = reason
            self.message = message
        }

        static var unknown: Self {
            Endpoints.Error(reason: .unknown, message: nil)
        }
    }
}

extension Endpoints.Error.Reason {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
