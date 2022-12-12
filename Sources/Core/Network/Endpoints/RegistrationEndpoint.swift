//
//  RegistrationEndpoint.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

public struct RegistrationEndpoint<Response>: Endpoint {
    typealias Result = Response

    var path: String {
        "/apps/credentials"
    }

    var method: HTTPMethod {
        .post(nil)
    }

    var headerFields: [String : String]? {
        nil
    }
}
