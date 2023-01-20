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
    enum Account {
        public static func get(onEnvironment environment: Environment = .production) -> Endpoint<SnabblePayNetwork.Account> {
            .init(path: "/apps/account", method: .get(nil), environment: environment)
        }
    }
}

public struct Account: Decodable {
    public let state: State
    public let credentials: Credential?
    public let validationURL: URL?
    public let message: String?

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
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.state = try container.decode(Account.State.self, forKey: .state)
        switch state {
        case .pending:
            self.validationURL = try container.decode(URL.self, forKey: .validationURL)
            self.credentials = nil
            self.message = nil
        case .successful:
            self.validationURL = nil
            self.credentials = try container.decode(Credential.self, forKey: .credentials)
            self.message = nil
        case .error, .failed:
            self.validationURL = nil
            self.credentials = nil
            self.message = try container.decode(String.self, forKey: .message)
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

public struct Credential: Decodable {
    public let id: ID
    public let name: String
    public let holderName: String
    public let currencyCode: CurrencyCode
    public let bank: String
    public let createdAt: Date
    public let iban: IBAN

    public typealias ID = Tagged<Credential, String>
    public typealias IBAN = Tagged<(Credential, iban: ()), String>
    public typealias CurrencyCode = Tagged<(Credential, currencyCode: ()), String>
}

extension Credential: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}
