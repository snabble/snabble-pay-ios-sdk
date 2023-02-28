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
        /// Invalid request, e.g. invalid URL
        case invalidRequestError(String)

        /// Indicates an error on the transport layer, e.g. not being able to connect to the server
        case transportError(URLError)

        /// Received an invalid response, e.g. non-HTTP result
        case invalidResponse(URLResponse)

        /// Server-side validation error
        case validationError(httpStatusCode: HTTPStatusCode, error: Endpoints.Error?)

        /// The server sent data in an unexpected format
        case decodingError(DecodingError)

        /// Unexpected error within the flow
        case unexpected(Swift.Error)
    }
}

extension APIError: ToModel {
    func toModel() -> SnabblePay.Error {
        switch self {
        case .invalidRequestError(let details):
            return .invalidRequestError(details)
        case .transportError(let urlError):
            return .transportError(urlError)
        case .invalidResponse(let urlResponse):
            return .invalidResponse(urlResponse)
        case .validationError(let httpStatusCode, let error):
            return .validationError(httpStatusCode: httpStatusCode, error: error)
        case .decodingError(let decodingError):
            return .decodingError(decodingError)
        case .unexpected(let error):
            return .unexpected(error)
        }
    }
}
