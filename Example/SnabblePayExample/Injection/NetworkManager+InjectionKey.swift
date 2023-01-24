//
//  NetworkManager+InjectionKey.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import Foundation
import SnabblePayNetwork

private struct NetworkManagerKey: InjectionKey {
    static var currentValue: NetworkManager = .init(
        session: .shared,
        config: .init(
            customUrlScheme: "snabble-pay",
            apiKey: "IO2wX69CsqZUQ3HshOnRkO4y5Gy/kRar6Fnvkp94piA2ivUun7TC7MjukrgUKlu7g8W8/enVsPDT7Kvq28ycw=="
        )
    )
}

extension InjectedValues {
    var networkManager: NetworkManager {
        get { Self[NetworkManagerKey.self] }
        set { Self[NetworkManagerKey.self] = newValue }
    }
}
