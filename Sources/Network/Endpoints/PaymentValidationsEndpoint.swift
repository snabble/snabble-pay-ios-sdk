//
//  PaymentValidationsEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Tagged
import Combine

extension Endpoints {
    public static func paymentValidations(onEnvironment environment: Environment = .production) -> Endpoint<PaymentValidation> {
        .init(path: "/apps/payment-validations", method: .get(nil), environment: environment)
    }
}

public struct PaymentValidation: Decodable {
    public let state: State
    public let credentials: Credential?
    public let validationLink: URL?
    public let message: String?

    public typealias ID = Tagged<PaymentValidation, String>

    public enum State: String, Decodable {
        case pending = "PENDING"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
        case error = "ERROR"
    }

    enum CodingKeys: CodingKey {
        case id
        case state
        case credentials
        case validationLink
        case message
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.state = try container.decode(PaymentValidation.State.self, forKey: .state)
        switch state {
        case .pending:
            self.validationLink = try container.decode(URL.self, forKey: .validationLink)
            self.credentials = nil
            self.message = nil
        case .successful:
            self.validationLink = nil
            self.credentials = try container.decode(Credential.self, forKey: .credentials)
            self.message = nil
        case .error, .failed:
            self.validationLink = nil
            self.credentials = nil
            self.message = try container.decode(String.self, forKey: .message)
        }
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
