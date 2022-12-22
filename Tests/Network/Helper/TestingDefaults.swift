//
//  File.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-22.
//

import Foundation

enum TestingDefaults {
    static var dateFormatter = {
        let dateFormatter = ISO8601DateFormatter()
        return dateFormatter
    }()

    static var jsonDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}