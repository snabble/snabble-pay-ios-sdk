//
//  AppDelegate.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-16.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("Your code here")
        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if url.host == "authorize" {
            guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
                let queryItems = components.queryItems else {
                return true
            }

            if let code = queryItems.first(where: { $0.name == "code" })?.value,
                let state = queryItems.first(where: { $0.name == "state" })?.value {
                print("code: ", code)
                print("state: ", state)
                return true
            }

            if let error = queryItems.first(where: { $0.name == "error" })?.value, !error.isEmpty {
                print("error: ", error)
                return true
            }
        }

        return false
    }
}
