//
//  AccountView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-02-22.
//

import SwiftUI
import SnabblePay
import Combine

class AccountViewModel: ObservableObject {
    let snabblePay: SnabblePay = .shared

    let account: Account

    init(account: Account) {
        self.account = account
    }

    @Published var mandate: Account.Mandate? = nil
    @Published var session: Session? = nil

    func createMandate() {
        snabblePay.createMandate(forAccountId: account.id, city: "Bonn", countryCode: "DE") { [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func decline(mandateId: Account.Mandate.ID) {
        snabblePay.declineMandate(withId: mandateId, forAccountId: account.id){ [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func accept(mandateId: Account.Mandate.ID) {
        snabblePay.acceptMandate(withId: mandateId, forAccountId: account.id) { [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func startSession() {
        snabblePay.startSession(withAccountId: account.id) { [weak self] result in
            self?.session = try? result.get()
        }
    }
}


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
                Button {
                    viewModel.accept(mandateId: mandate.id)
                } label: {
                    Text("Accept")
                }

                Button {
                    viewModel.decline(mandateId: mandate.id)
                } label: {
                    Text("Decline")
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
