//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2023-03-16.
//

import Foundation
import SnabblePayNetwork

public struct Customer: Decodable {
    let id: String?
    let loyaltyId: String?
}

extension Customer: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

extension Customer: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Customer) {
        id = dto.id
        loyaltyId = dto.id
    }
}

extension SnabblePayNetwork.Customer: ToModel {
    func toModel() -> Customer {
        .init(fromDTO: self)
    }
}
