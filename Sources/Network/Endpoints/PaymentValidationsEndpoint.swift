//
//  PaymentValidationsEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Tagged
import Combine

public extension Endpoint {
    static func paymentValidations(onEnvironment environment: Environment = .production) -> Endpoint<PaymentValidation> {
        .init(path: "/apps/payment-validations", method: .post(nil), environment: environment)
    }

    static func paymentValidations(withID id: PaymentValidation.ID, onEnvironment environment: Environment = .production) -> Endpoint<PaymentValidation> {
        .init(path: "/apps/payment-validations/\(id.rawValue)", method: .get(nil), environment: environment)
    }
}

public struct PaymentValidation: Decodable {
    public let id: ID
    public let state: State
    public let credential: Credential?

    public typealias ID = Tagged<PaymentValidation, String>

    public enum State: String, Decodable {
        case pending = "PENDING"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
        case errored = "ERRORED"
    }
}

public struct Credential: Decodable {
    public let id: ID
    public let createdAt: String
    public let iban: IBAN

    public typealias ID = Tagged<Credential, String>
    public typealias IBAN = Tagged<(Credential, iban: ()), String>
}
