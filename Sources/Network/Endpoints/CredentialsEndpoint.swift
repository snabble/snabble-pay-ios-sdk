//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-25.
//

import Foundation
import Tagged
import Combine

extension Endpoints.Account {
    public enum Credentials {
        public static func get(onEnvironment environment: Environment = .production) -> Endpoint<[SnabblePayNetwork.Account.Credentials]> {
            .init(path: "/apps/account/credentials", method: .get(nil), environment: environment)
        }

        public static func get(id: Account.Credentials.ID, onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Account.Credentials> {
            .init(path: "/apps/account/credentials/\(id.rawValue)", method: .get(nil), environment: environment)
        }

        public static func delete(id: Account.Credentials.ID, onEnvironment environment: Environment = .production) -> Endpoint<Data> {
            .init(path: "/apps/account/credentials/\(id.rawValue)", method: .delete, environment: environment)
        }
    }
}

extension Account {
    public struct Credentials: Decodable, Identifiable {
        public let id: ID
        public let name: String
        public let holderName: String
        public let currencyCode: CurrencyCode
        public let bank: String
        public let createdAt: Date
        public let iban: IBAN
        public let mandate: Mandate

        public typealias ID = Tagged<Credentials, String>
        public typealias IBAN = Tagged<(Credentials, iban: ()), String>
        public typealias CurrencyCode = Tagged<(Credentials, currencyCode: ()), String>
    }
}

extension Account.Credentials: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id && lhs.mandate == rhs.mandate
    }
}
