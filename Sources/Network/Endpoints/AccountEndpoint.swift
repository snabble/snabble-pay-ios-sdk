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

    let urlScheme: String

    public enum State {
        case pending(URL)
        case successful(Credentials, Mandate)
        case failed(String)
        case error(String)
    }

    private enum StateCodingKeys: String, Decodable {
        case pending = "PENDING"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
        case error = "ERROR"
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case state
        case credentials
        case validationURL = "validationLink"
        case message
        case mandate
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let stateKey = try container.decode(StateCodingKeys.self, forKey: .state)
        switch stateKey {
        case .pending:
            let validationURL = try container.decode(URL.self, forKey: .validationURL)
            self.state = .pending(validationURL)
        case .successful:
            let credentials = try container.decode(Credentials.self, forKey: .credentials)
#warning("Remove optional try if backend has added it")
            let mandate = try container.decodeIfPresent(Mandate.self, forKey: .mandate) ?? Mandate(state: .pending, text: "Mandate Text")
            self.state = .successful(credentials, mandate)
        case .error:
            let message = try container.decode(String.self, forKey: .message)
            self.state = .error(message)
        case .failed:
            let message = try container.decode(String.self, forKey: .message)
            self.state = .failed(message)
        }
        guard let urlScheme = decoder.userInfo[.urlScheme] as? String else {
            throw DecodingError.valueNotFound(String.self, .init(codingPath: [], debugDescription: "Missing URLScheme in decoders userInfo"))
        }
        self.urlScheme = urlScheme
    }

    public func validateCallbackURL(_ url: URL) -> Bool {
        guard url.scheme == urlScheme,
              url.host == "account",
              url.lastPathComponent == "validation" else {
            return false
        }
        return true
    }
}

extension Account: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.state == rhs.state
    }
}

extension Account.State: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.pending, .pending):
            return true
        case (.successful, .successful):
            return true
        case (.error, .error):
            return true
        case (.failed, .failed):
            return true
        default:
            return false
        }
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
