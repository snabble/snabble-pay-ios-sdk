//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation
import Tagged

extension Account {
    public struct Mandate: Decodable {
        public let id: ID
        public let state: State
        public let htmlText: String?

        public enum State: String, Decodable {
            case pending = "PENDING"
            case accepted = "ACCEPTED"
            case declined = "DECLINED"
        }

        public typealias ID = Tagged<Account, String>

        enum CodingKeys: CodingKey {
            case id
            case state
            case htmlText
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: Account.Mandate.CodingKeys.self)
            self.id = try container.decode(Account.Mandate.ID.self, forKey: .id)
            self.state = try container.decode(Account.Mandate.State.self, forKey: .state)
            self.htmlText = try container.decodeIfPresent(String.self, forKey: .htmlText)
        }
    }
}

extension Account.Mandate: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
