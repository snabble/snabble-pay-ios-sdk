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

    @Published var mandate: Account.Mandate?
    @Published var session: Session?

    func createMandate() {
        snabblePay.createMandate(forAccountId: account.id) { [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func decline(mandateId: Account.Mandate.ID) {
        snabblePay.declineMandate(withId: mandateId, forAccountId: account.id) { [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func accept(mandateId: Account.Mandate.ID) {
        snabblePay.acceptMandate(withId: mandateId, forAccountId: account.id) { [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func startSession() {
        snabblePay.startSession(withAccountId: "23") { [weak self] result in
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
