//
//  Account+State.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-25.
//

import Foundation

extension Account {
    public enum State {
        case pending
        case ready
    }

    public var state: State {
        guard !credentials.isEmpty else {
            return .pending
        }
        return .ready
    }
}
