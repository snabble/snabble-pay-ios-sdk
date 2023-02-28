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
            case mandateNotAccepted = "mandate_not_accepted"
            case accountNotFound = "account_not_found"
            case validationError = "validation_error"
            case sessionNotFound = "session_not_found"
            case invalidSessionState = "invalid_session_state"
            case unauthorized = "unauthorized"
            case unknown
        }

        public init(from decoder: Decoder) throws {
            let topLevelContainer = try decoder.container(keyedBy: RootKeys.self)
            let container = try topLevelContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: .error)
            self.reason = try container.decode(Endpoints.Error.Reason.self, forKey: Endpoints.Error.CodingKeys.reason)
            self.message = try container.decodeIfPresent(String.self, forKey: Endpoints.Error.CodingKeys.message)
        }
    }
}

extension Endpoints.Error.Reason {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: decoder.singleValueContainer().decode(RawValue.self)) ?? .unknown
    }
}
