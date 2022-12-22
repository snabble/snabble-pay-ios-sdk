//
//  KeychainAccess+PropertyWrapper.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-20.
//

import UIKit
import KeychainAccess

@propertyWrapper
struct KeychainStorage<Value: Codable> {

    let key: String
    let keychain: Keychain
    let initialValue: Value?

    var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
    
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }

    init(wrappedValue initialValue: Value? = nil, _ key: String, service: String) {
        self.initialValue = initialValue
        self.key = key
        self.keychain = Keychain(service: service)
    }

    var wrappedValue: Value? {
        get {
            do {
                guard let data = try? keychain.getData(key) else {
                    return initialValue
                }
                return try decoder.decode(Value.self, from: data)
            } catch {
                return nil
            }
        }
        set {
            guard let newData = try? encoder.encode(newValue) else {
                return
            }
            do {
                try keychain.set(newData, key: key)
            } catch {}
        }
    }
}
