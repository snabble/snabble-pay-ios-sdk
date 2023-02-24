//
//  AccountView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-02-22.
//

import SwiftUI
import SnabblePay

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel

    init(account: Account) {
        self.viewModel = AccountViewModel(account: account)
    }

    var body: some View {
        VStack {
            Text(viewModel.account.id.rawValue)
            Text(viewModel.account.holderName)
            Text(viewModel.account.iban.rawValue)
            Text(viewModel.account.mandateState.rawValue)
            Spacer(minLength: 16)
            Button {
                viewModel.startSession()
            } label: {
                Text("Start session")
            }
            if let session = viewModel.session {
                QRCodeView(code: session.token.rawValue)
            }

            Spacer(minLength: 16)
            if let mandate = viewModel.mandate {
                Text(mandate.id.rawValue)
                Text(mandate.state.rawValue)
                if mandate.state == .pending {
                    Button {
                        viewModel.accept(mandateId: mandate.id)
                    } label: {
                        Text("Accept")
                    }
                }
            } else {
                Text("No Mandate")
            }
        }
        .onAppear {
            viewModel.createMandate()
        }
    }
}
