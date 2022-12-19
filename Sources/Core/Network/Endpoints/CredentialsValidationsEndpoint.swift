//
//  CredentialsValidationsEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-19.
//

import Foundation
import Tagged
import Combine

extension Endpoint {
    static func credentialsValidations(onEnvironment environment: Environment = .production) -> Endpoint<CredentialsValidations> {
        .init(path: "apps/credentials-validations", method: .post(nil), environment: environment)
    }

    static func credentialsValidations(withID id: CredentialsValidations.ID, onEnvironment environment: Environment = .production) -> Endpoint<CredentialsValidations> {
        .init(path: "apps/credentials-validations/\(id.rawValue)", method: .get(nil), environment: environment)
    }
}

struct CredentialsValidations: Decodable {
    let id: ID
    let state: String

    typealias ID = Tagged<CredentialsValidations, String>
}

