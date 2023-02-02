//
//  App.swift
//  
//
//  Created by Andreas Osberghaus on 2023-02-01.
//

import Foundation
import Tagged

struct App: Codable {
    let identifier: Idenitifer
    let secret: Secret

    typealias Idenitifer = Tagged<(App, identifier: ()), String>
    typealias Secret = Tagged<(App, secret: ()), String>

    enum CodingKeys: String, CodingKey {
        case identifier = "appIdentifier"
        case secret = "appSecret"
    }
}
