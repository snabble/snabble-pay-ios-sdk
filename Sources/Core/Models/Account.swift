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
    public let mandateState: Mandate.State

    public typealias ID = Tagged<Account, String>
    public typealias IBAN = Tagged<(Account, iban: ()), String>
    public typealias CurrencyCode = Tagged<(Account, currencyCode: ()), String>

    enum CodingKeys: CodingKey {
        case id
        case name
        case holderName
        case currencyCode
        case bank
        case createdAt
        case iban
        case mandateState
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Account.ID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.holderName = try container.decode(String.self, forKey: .holderName)
        self.currencyCode = try container.decode(Account.CurrencyCode.self, forKey: .currencyCode)
        self.bank = try container.decode(String.self, forKey: .bank)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.iban = try container.decode(Account.IBAN.self, forKey: .iban)
        self.mandateState = try container.decode(Account.Mandate.State.self, forKey: .mandateState)
    }
}

extension Account: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Account: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
