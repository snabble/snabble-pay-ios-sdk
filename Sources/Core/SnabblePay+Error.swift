//
//  SnabblePay+Error.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-27.
//

import Foundation
import SnabblePayNetwork

extension SnabblePay {
    /// Public snabble pay error
    public enum Error: Swift.Error {
        /// Invalid request, e.g. invalid URL
        case invalidRequestError(String)

        /// Indicates an error on the transport layer, e.g. not being able to connect to the server
        case transportError(URLError)

        /// Received an invalid response, e.g. non-HTTP result
        case invalidResponse(URLResponse)

        /// Server-side validation error
        case validationError(ValidationError)

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
        case .validationError(_, let error):
            return .validationError(error.toModel())
        case .decodingError(let decodingError):
            return .decodingError(decodingError)
        case .unexpected(let error):
            return .unexpected(error)
        }
    }
}

public struct ValidationError {
    let reason: Reason
    let message: String?

    public enum Reason: String, Decodable {
        case notFound = "not_found"
        case validationError = "validation_error"
        case mandateNotAccepted = "mandate_not_accepted"
        case sessionTokenExpired = "session_token_expired"
        case transactionAlreadyStarted = "transaction_already_started"
        case invalidSessionState = "invalid_session_state"
        case invalidTransactionState = "invalid_transaction_state"
        case internalServerError = "internal_server_error"
        case unauthorized = "unauthorized"
        case unknown
    }
}

extension ValidationError: FromDTO {
    init(fromDTO dto: Endpoints.Error) {
        reason = dto.reason.toModel()
        message = dto.message
    }
}

extension Endpoints.Error: ToModel {
    func toModel() -> ValidationError {
        .init(fromDTO: self)
    }
}

extension Endpoints.Error.Reason: ToModel {
    func toModel() -> ValidationError.Reason {
        switch self {
        case .notFound:
            return .notFound
        case .validationError:
            return .validationError
        case .mandateNotAccepted:
            return .mandateNotAccepted
        case .sessionTokenExpired:
            return .sessionTokenExpired
        case .transactionAlreadyStarted:
            return .transactionAlreadyStarted
        case .invalidSessionState:
            return .invalidSessionState
        case .invalidTransactionState:
            return .invalidTransactionState
        case .internalServerError:
            return .internalServerError
        case .unauthorized:
            return .unauthorized
        case .unknown:
            return .unknown
        }
    }
}
