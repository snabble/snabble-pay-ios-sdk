//
//  AccountEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-25.
//

import Foundation
import Tagged
import Combine

extension Endpoints {
    public enum Accounts {
        public static func check(appUri: String, onEnvironment environment: Environment = .production) -> Endpoint<Account.Check> {
            .init(path: "/apps/accounts/check", method: .get([.init(name: "appUri", value: appUri)]), environment: environment)
        }
        public static func get(onEnvironment environment: Environment = .production) -> Endpoint<[Account]> {
            .init(path: "/apps/accounts", method: .get(nil), environment: environment)
        }

        public static func get(id: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Account> {
            .init(path: "/apps/accounts/\(id.rawValue)", method: .get(nil), environment: environment)
        }

        public static func delete(id: Account.ID, onEnvironment environment: Environment = .production) -> Endpoint<Data> {
            .init(path: "/apps/accounts/\(id.rawValue)", method: .delete, environment: environment)
        }
    }
}

extension Account {
    public struct Check: Decodable {
        public let validationURL: URL
        public let appUri: URL

        enum CodingKeys: String, CodingKey {
            case validationURL = "validationLink"
            case appUri
        }

        func validate(url: URL) -> Bool {
            return appUri == url
        }
    }
}

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
