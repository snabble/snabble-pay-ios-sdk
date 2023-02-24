//
//  Account.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation
import Tagged
import SnabblePayNetwork

public struct Account: Identifiable {
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

extension Account: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Account) {
        self.id = ID(dto.id)
        self.name = dto.name
        self.holderName = dto.holderName
        self.currencyCode = CurrencyCode(dto.currencyCode)
        self.bank = dto.bank
        self.createdAt = dto.createdAt
        self.iban = IBAN(dto.iban)
        self.mandateState = .init(fromDTO: dto.mandateState)
    }
}

extension SnabblePayNetwork.Account: ToModel {
    func toModel() -> Account {
        .init(fromDTO: self)
    }
}
