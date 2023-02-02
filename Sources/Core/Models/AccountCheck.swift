//
//  AccountCheck.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation

extension Account {
    public struct Check: Decodable {
        public let validationURL: URL
        public let appUri: URL

        enum CodingKeys: String, CodingKey {
            case validationURL = "validationLink"
            case appUri
        }

        public func validate(url: URL) -> Bool {
            return appUri == url
        }
    }
}

extension Account.Check: Identifiable {
    public var id: URL {
        validationURL
    }
}
