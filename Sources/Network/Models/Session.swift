//
//  Session.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation

public struct Session: Decodable {
    public let id: String
    public let token: Session.Token
    public let createdAt: Date
    public let transaction: Session.Transaction?
}

extension Session {
    public struct Token: Decodable {
        public let id: String
        public let value: String
        public let createdAt: Date
        public let refreshAt: Date
        public let validUntil: Date
    }

    public struct Transaction: Decodable {
        public let id: String
        public let state: State
        public let amount: String
        public let currency: String

        public enum State: String, Decodable {
            case preauthorized = "PREAUTHORIZED"
            case preauthorizationFailed = "PREAUTH_FAILED"
            case successful = "SUCCESSFUL"
            case failed = "FAILED"
            case errored = "ERRORED"
            case aborted = "ABORTED"
        }
    }
}
