//
//  Environment.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

enum Environment {
    case development
    case staging
    case production

    var headers: [String: String]? {
        return [
            "Content-Type": "application/json"
        ]
    }

    var baseURL: URL {
        switch self {
        case .development:
            return "https://payment.snabble-testing.io"
        case .staging:
            return "https://payment.snabble-staging.io"
        case .production:
            return "https://payment.snabble.io"
        }
    }
}
