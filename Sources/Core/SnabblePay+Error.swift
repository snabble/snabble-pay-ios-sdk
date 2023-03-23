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
    public let reason: Reason
    public let message: String?

    public enum Reason: String, Decodable {
        case internalError = "internal_error"
        case unauthorized = "unauthorized"
        case userNotFound = "user_not_found"
        case tokenNotFound = "token_not_found"
        case accountNotFound = "account_not_found"
        case sessionNotFound = "session_not_found"
        case transactionNotFound = "transaction_not_found"
        case customerNotFound = "customer_not_found"
        case validationError = "validation_error"
        case sessionTokenExpired = "session_token_expired"
        case mandateNotAccepted = "mandate_not_accepted"
        case invalidSessionState = "invalid_session_state"
        case invalidTransactionState = "invalid_transaction_state"
        case sessionHasTransaction = "session_has_transaction"
        case transactionAlreadyStarted = "transaction_already_started"
        case localMandate = "local_mandate"
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
        case .internalError:
            return .internalError
        case .unauthorized:
            return .unauthorized
        case .userNotFound:
            return .userNotFound
        case .tokenNotFound:
            return .tokenNotFound
        case .accountNotFound:
            return .accountNotFound
        case .sessionNotFound:
            return .sessionNotFound
        case .transactionNotFound:
            return .transactionNotFound
        case .customerNotFound:
            return .customerNotFound
        case .validationError:
            return .validationError
        case .sessionTokenExpired:
            return .sessionTokenExpired
        case .mandateNotAccepted:
            return .mandateNotAccepted
        case .invalidSessionState:
            return .invalidSessionState
        case .invalidTransactionState:
            return .invalidTransactionState
        case .sessionHasTransaction:
            return .sessionHasTransaction
        case .transactionAlreadyStarted:
            return .transactionAlreadyStarted
        case .localMandate:
            return .localMandate
        case .unknown:
            return .unknown
        }
    }
}
