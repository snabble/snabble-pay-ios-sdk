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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            AccountView(viewModel: .init())
        }
    }
}
