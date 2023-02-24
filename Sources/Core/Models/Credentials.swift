//
//  Credentials.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-01.
//

import Foundation
import Tagged
import SnabblePayNetwork

public struct Credentials {
    public let identifier: Idenitifer
    public let secret: Secret

    public typealias Idenitifer = Tagged<(Credentials, identifier: ()), String>
    public typealias Secret = Tagged<(Credentials, secret: ()), String>

    public init(identifier: Idenitifer, secret: Secret) {
        self.identifier = identifier
        self.secret = secret
    }
}

extension Credentials: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Credentials) {
        self.identifier = Idenitifer(dto.identifier)
        self.secret = Secret(dto.secret)
    }
}

extension Credentials: ToDTO {
    func toDTO() -> SnabblePayNetwork.Credentials {
        .init(identifier: identifier.rawValue, secret: secret.rawValue)
    }
}

extension SnabblePayNetwork.Credentials: ToModel {
    func toModel() -> Credentials {
        .init(fromDTO: self)
    }
}
