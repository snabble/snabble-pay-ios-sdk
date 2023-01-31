//
//  NetworkManager+Shared.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-26.
//

import Foundation
import SnabblePayNetwork

extension NetworkManager {
    static let shared: NetworkManager = .init(
        apiKey: "IO2wX69CsqZUQ3HshOnRkO4y5Gy/kRar6Fnvkp94piA2ivUun7TC7MjukrgUKlu7g8W8/enVsPDT7Kvq28ycw==",
        session: .shared
    )
}
