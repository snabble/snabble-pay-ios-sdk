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
    var mandate: Account.Mandate?

    var onButtonAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            Text("Account Success View")
            Text(credentials.holderName)
            Text(credentials.iban.rawValue)
            Button {
                onButtonAction?()
            } label: {
                Text("Remove AppId")
            }

        }
    }
}
