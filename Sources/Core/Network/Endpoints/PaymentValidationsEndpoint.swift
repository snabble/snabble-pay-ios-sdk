//
//  PaymentValidationsEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Tagged
import Combine

extension Endpoint {
    static func paymentValidations(onEnvironment environment: Environment = .production) -> Endpoint<PaymentValidation> {
        .init(path: "/apps/payment-validations", method: .post(nil), environment: environment)
    }

    static func paymentValidations(withID id: PaymentValidation.ID, onEnvironment environment: Environment = .production) -> Endpoint<PaymentValidation> {
        .init(path: "/apps/payment-validations/\(id.rawValue)", method: .get(nil), environment: environment)
    }
}

struct PaymentValidation: Decodable {
    let id: ID
    let state: State
    let credential: Credential?

    typealias ID = Tagged<PaymentValidation, String>

    enum State: String, Decodable {
        case pending = "PENDING"
        case successful = "SUCCESSFUL"
        case failed = "FAILED"
        case errored = "ERRORED"
    }
}

struct Credential: Decodable {
    let id: ID
    let createdAt: String
    let iban: IBAN

    typealias ID = Tagged<Credential, String>
    typealias IBAN = Tagged<(Credential, iban: ()), String>
}
