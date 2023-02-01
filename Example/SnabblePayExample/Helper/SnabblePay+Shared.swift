//
//  NetworkManager+Shared.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-26.
//

import Foundation
import SnabblePayCore

extension SnabblePay {
    static var shared: SnabblePay = {
        let snabblePay: SnabblePay = .init(
            apiKey: "IO2wX69CsqZUQ3HshOnRkO4y5Gy/kRar6Fnvkp94piA2ivUun7TC7MjukrgUKlu7g8W8/enVsPDT7Kvq28ycw==",
            session: .shared
        )
        snabblePay.environment = .development
        return snabblePay
    }()
}
