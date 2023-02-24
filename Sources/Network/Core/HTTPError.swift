//
//  HTTPError.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-24.
//

import Foundation

public enum HTTPError: Equatable {
    case invalidResponse(HTTPStatusCode, Endpoints.Error?)
    case unknownResponse(URLResponse)
}

extension HTTPError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .invalidResponse(statusCode, error):
            return "Error: \(statusCode) \(String(describing: error))"
        case let .unknownResponse(response):
            return "Error: unknown \(response)"
        }
    }
}
