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
    static func paymentValidations(onEnvironment environment: Environment = .production) -> Endpoint<PaymentValidations> {
        .init(path: "apps/payment-validations", method: .post(nil), environment: environment)
    }

    static func paymentValidations(withID id: PaymentValidations.ID, onEnvironment environment: Environment = .production) -> Endpoint<PaymentValidations> {
        .init(path: "apps/payment-validations/\(id.rawValue)", method: .get(nil), environment: environment)
    }
}

struct PaymentValidations: Decodable {
    let id: ID
    let state: String

    typealias ID = Tagged<PaymentValidations, String>
}

