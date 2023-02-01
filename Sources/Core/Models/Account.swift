//
//  Account.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation
import Tagged

public struct Account: Decodable, Identifiable {
    public let id: ID
    public let name: String
    public let holderName: String
    public let currencyCode: CurrencyCode
    public let bank: String
    public let createdAt: Date
    public let iban: IBAN
    public let mandate: Mandate

    public typealias ID = Tagged<Account, String>
    public typealias IBAN = Tagged<(Account, iban: ()), String>
    public typealias CurrencyCode = Tagged<(Account, currencyCode: ()), String>
}

extension Account: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.mandate == rhs.mandate
    }
}
