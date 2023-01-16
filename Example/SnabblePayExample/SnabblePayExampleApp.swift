//
//  SnabblePayExampleApp.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2022-12-08.
//

import SwiftUI
import SnabblePayCore
import SnabblePayNetwork

@main
struct SnabblePayExampleApp: SwiftUI.App {
    let networkConfig: NetworkConfig = .init(
        customUrlScheme: "snabble-pay",
        apiKey: "IO2wX69CsqZUQ3HshOnRkO4y5Gy/kRar6Fnvkp94piA2ivUun7TC7MjukrgUKlu7g8W8/enVsPDT7Kvq28ycw=="
    )

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: .init())
        }
    }
}
