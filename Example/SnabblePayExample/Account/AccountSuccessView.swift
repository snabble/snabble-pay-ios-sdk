//
//  AccountSuccessView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import SnabblePayNetwork

struct AccountSuccessView: View {
    var credentials: Account.Credentials

    var body: some View {
        VStack(spacing: 8) {
            Text("Account Success View")
            Text(credentials.holderName)
            Text(credentials.iban.rawValue)
        }
    }
}
