//
//  SnabblePay+Error.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-27.
//

import Foundation
import SnabblePayNetwork

extension SnabblePay {
    public enum Error: Swift.Error {
        case unknown(error: Swift.Error)
        case network(httpStatusCode: Int)
        case mandateNotAccepted
        case accountNotFound
    }
}

extension Endpoints.Error {
    func toModel(withStatusCode statusCode: Int) -> SnabblePay.Error {
        switch reason {
        case .unknown:
            return .network(httpStatusCode: statusCode)
        case .accountNotFound, .validationError:
            return .accountNotFound
        case .mandateNotAccepted:
            return .mandateNotAccepted
        }
    }
}

extension HTTPError: ToModel {
    func toModel() -> SnabblePay.Error {
        switch self {
        case .invalidResponse(let httpStatusCode, let endpointError):
            return endpointError?.toModel(withStatusCode: httpStatusCode.rawValue) ?? .network(httpStatusCode: httpStatusCode.rawValue)
        case .unknownResponse:
            return .unknown(error: self)
        }
    }
}
