//
//  Environment.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-12.
//

import Foundation

/// Protocol to which environments must conform
protocol Environmentable {

    /// The default HTTP request headers for the environment.
    var headers: [String: String]? { get }

    /// The base URL of the environment.
    var baseURL: URL { get }
}

enum Environment: Environmentable {
    case development
    case staging
    case production

    var headers: [String : String]? {
        return [
            "Content-Type" : "application/json"
        ]
    }

    var baseURL: URL {
        switch self {
        case .development:
            return "https://api.snabble-testing.io"
        case .staging:
            return "https://api.snabble-staging.io"
        case .production:
            return "https://api.snabble-production.io"
        }
    }
}
