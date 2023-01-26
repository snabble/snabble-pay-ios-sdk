//
//  CredentialsView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import SnabblePayNetwork
import Combine

struct CredentialsView: View {
    let credentials: [Account.Credentials]
    var onDestructiveAction: (() -> Void)?

    init(credentials: [Account.Credentials], onDestructiveAction: (() -> Void)? = nil) {
        self.credentials = credentials
        self.onDestructiveAction = onDestructiveAction
    }

    var body: some View {
        NavigationView {
                List(credentials) { credential in
                    VStack(spacing: 8) {
                        Text(credential.holderName)
                        Text(credential.iban.rawValue)
                    }

                }
                .navigationTitle("Bank accounts")
                .toolbar { EditButton() }
            }
        Button {
            onDestructiveAction?()
        } label: {
            Text("Remove AppId")
        }
    }
}
