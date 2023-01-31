//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation

extension Account {
    public struct Mandate: Decodable {
        public let state: State
        public let text: String?

        public enum State: String, Decodable {
            case pending = "PENDING"
            case accepted = "ACCEPTED"
            case declined = "DECLINED"
        }
    }
}

extension Account.Mandate: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }
}
