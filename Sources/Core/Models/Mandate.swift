//
//  Mandate.swift
//  
//
//  Created by Andreas Osberghaus on 2023-01-31.
//

import Foundation
import Tagged
import SnabblePayNetwork

extension Account {
    public struct Mandate {
        public let id: ID
        public let state: State
        public let htmlText: String?

        public enum State: String, Decodable {
            case pending = "PENDING"
            case accepted = "ACCEPTED"
            case declined = "DECLINED"
        }

        public typealias ID = Tagged<Account, String>
    }
}

extension Account.Mandate: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Account.Mandate: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Account.Mandate) {
        self.id = ID(dto.id)
        self.state = .init(fromDTO: dto.state)
        self.htmlText = dto.htmlText
    }
}

extension Account.Mandate.State: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Account.Mandate.State) {
        switch dto {
        case .declined:
            self = .declined
        case .pending:
            self = .pending
        case .accepted:
            self = .accepted
        }
    }
}

extension SnabblePayNetwork.Account.Mandate: ToModel {
    func toModel() -> Account.Mandate {
        .init(fromDTO: self)
    }
}
