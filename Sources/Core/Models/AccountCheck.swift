//
//  AccountCheck.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation
import SnabblePayNetwork

extension Account {
    public struct Check {
        public let validationURL: URL
        public let appUri: URL

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

extension Account.Check: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Account.Check) {
        self.validationURL = dto.validationURL
        self.appUri = dto.appUri
    }
}

extension SnabblePayNetwork.Account.Check: ToModel {
    func toModel() -> Account.Check {
        .init(fromDTO: self)
    }
}
