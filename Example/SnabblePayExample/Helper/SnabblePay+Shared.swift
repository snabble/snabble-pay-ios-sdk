//
//  NetworkManager+Shared.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-26.
//

import Foundation
import SnabblePay

extension SnabblePay {
    static var shared: SnabblePay = {
        var credentials: Credentials?
        if let savedPerson = UserDefaults.standard.object(forKey: "credentials") as? Data {
            credentials = try? JSONDecoder().decode(Credentials.self, from: savedPerson)
        }
        let snabblePay: SnabblePay = .init(
            apiKey: "IO2wX69CsqZUQ3HshOnRkO4y5Gy/kRar6Fnvkp94piA2ivUun7TC7MjukrgUKlu7g8W8/enVsPDT7Kvq28ycw==",
            credentials: credentials,
            urlSession: .shared
        )
        snabblePay.environment = .development
        snabblePay.delegate = snabblePay
        return snabblePay
    }()

    static func reset() {
        UserDefaults.standard.set(nil, forKey: "credentials")
    }
}

extension SnabblePay: SnabblePayDelegate {
    public func snabblePay(_ snabblePay: SnabblePay, didUpdateCredentials credentials: Credentials?) {
        if let encoded = try? JSONEncoder().encode(credentials) {
            UserDefaults.standard.set(encoded, forKey: "credentials")
        } else {
            UserDefaults.standard.set(nil, forKey: "credentials")
        }
        UserDefaults.standard.synchronize()
    }
}

extension Credentials: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let identifier = try container.decode(Credentials.Idenitifer.self, forKey: .identifier)
        let secret = try container.decode(Credentials.Secret.self, forKey: .secret)
        self.init(identifier: identifier, secret: secret)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.identifier, forKey: .identifier)
        try container.encode(self.secret, forKey: .secret)
    }

    enum CodingKeys: String, CodingKey {
        case identifier
        case secret
    }
}
