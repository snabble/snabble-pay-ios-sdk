//
//  Resource.swift
//  
//
//  Created by Andreas Osberghaus on 2022-12-13.
//

import Foundation
import XCTest

func loadResource(filename: String, withExtension ext: String?) throws -> Data {
    guard let resourceURL = Bundle.module.url(forResource: filename, withExtension: ext) else {
        throw URLError(.badURL)
    }
    return try Data(contentsOf: resourceURL)
}
