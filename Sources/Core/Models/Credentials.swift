//
//  Credentials.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-01.
//

import Foundation
import Tagged
import SnabblePayNetwork

/// A class that contains credentials for a user of your app
public struct Credentials {
    /// application identifier
    public let identifier: Identifier
    /// application secret
    public let secret: Secret

    /// Type Safe Identifier
    public typealias Identifier = Tagged<(Credentials, identifier: ()), String>
    /// Type Safe Secret
    public typealias Secret = Tagged<(Credentials, secret: ()), String>

    /// Create an credentials instance
    /// - Parameters:
    ///   - identifier: Application identifier
    ///   - secret: Application secret
    public init(identifier: Identifier, secret: Secret) {
        self.identifier = identifier
        self.secret = secret
    }
}

extension Credentials: FromDTO {
    init(fromDTO dto: SnabblePayNetwork.Credentials) {
        self.identifier = Identifier(dto.identifier)
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
