//
//  AccountEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Tagged
import Combine

extension Endpoints {
    public enum Account {
        public static func get(onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Account> {
            .init(path: "/apps/account", method: .get(nil), environment: environment)
        }
    }
}

public struct Account: Decodable {
    public let state: State
    public let credentials: Credentials?
    public let validationURL: URL?
    public let message: String?
    public let mandate: Mandate?

    public enum State: String, Decodable {
        case pending = "PENDING"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
        case error = "ERROR"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case state
        case credentials
        case validationURL = "validationLink"
        case message
        case mandate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.state = try container.decode(Account.State.self, forKey: .state)
        switch state {
        case .pending:
            self.validationURL = try container.decode(URL.self, forKey: .validationURL)
            self.credentials = nil
            self.message = nil
            self.mandate = nil
        case .successful:
            self.validationURL = nil
            self.credentials = try container.decode(Credentials.self, forKey: .credentials)
            self.message = nil
#warning("Remove optional try if backend has added it")
            self.mandate = try? container.decode(Mandate.self, forKey: .mandate)
        case .error, .failed:
            self.validationURL = nil
            self.credentials = nil
            self.message = try container.decode(String.self, forKey: .message)
            self.mandate = nil
        }
    }

    public static func validateCallbackURL(_ url: URL, forScheme scheme: String) -> Bool {
        guard url.scheme == scheme,
              url.host == "account",
              url.lastPathComponent == "validation" else {
            return false
        }
        return true
    }
}

extension Account: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state &&
        lhs.credentials == rhs.credentials &&
        lhs.validationURL == rhs.validationURL &&
        lhs.message == rhs.message
    }
}

extension Account {
    public struct Credentials: Decodable {
        public let id: ID
        public let name: String
        public let holderName: String
        public let currencyCode: CurrencyCode
        public let bank: String
        public let createdAt: Date
        public let iban: IBAN

        public typealias ID = Tagged<Credentials, String>
        public typealias IBAN = Tagged<(Credentials, iban: ()), String>
        public typealias CurrencyCode = Tagged<(Credentials, currencyCode: ()), String>
    }
}

extension Account.Credentials: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}