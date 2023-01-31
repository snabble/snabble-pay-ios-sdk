//
//  CredentialsView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import SnabblePayCore
import SnabblePayNetwork
import Combine
import BetterSafariView

class AccountsViewModel: ObservableObject {
    let snabblePay: SnabblePay = .shared

    @Published var accounts: [Account]?
    @Published var accountCheck: Account.Check?
    @Published var session: SnabblePayNetwork.Session?

    var onDestructiveAction: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    func loadAccountCheck() {
        snabblePay.accountCheck(withAppUri: "snabble-pay://account/check") { [weak self] in
            self?.accountCheck = try? $0.get()
        }
    }

    func loadAccounts() {
        snabblePay.accounts { [weak self] in
            self?.accounts = try? $0.get()
        }
    }

    func acceptMandate(forAccount account: Account) {
        snabblePay.acceptMandate(forAccount: account) { [weak self] _ in
            self?.loadAccounts()
        }
    }

    func declineMandate(forAccount account: Account) {
        snabblePay.declineMandate(forAccount: account) { [weak self] _ in
            self?.loadAccounts()
        }
    }

    func startSession(withAccount account: Account) {
        snabblePay.startSession(withAccount: account) { [weak self] in
            self?.session = try? $0.get()
        }
    }
}

struct AccountsView: View {
    @ObservedObject var viewModel: AccountsViewModel = .init()

    var body: some View {
        NavigationView {
            if let accounts = viewModel.accounts {
                ForEach(accounts) { account in
                    HStack {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(account.holderName)
                            Text(account.iban.rawValue)
                        }
                        Spacer()
                        switch account.mandate.state {
                        case .pending:
                            VStack(alignment: .center, spacing: 8) {
                                Button {
                                    viewModel.acceptMandate(forAccount: account)
                                } label: {
                                    Text("Accept")
                                }
                                Button {
                                    viewModel.declineMandate(forAccount: account)
                                } label: {
                                    Text("Decline")
                                }
                            }
                        case .accepted:
                            Button {
                                viewModel.startSession(withAccount: account)
                            } label: {
                                Text("Session")
                            }
                        case .declined:
                            Text("Declined")
                        }
                    }
                }
                .padding()
                .navigationTitle("Bank accounts")
            } else {
                Text("Empty State").onAppear {
                    viewModel.loadAccounts()
                }
                .padding()
                .navigationTitle("Bank accounts")
                .toolbar {
                    Button("Add Account") {
                        viewModel.loadAccountCheck()
                    }
                }
            }
        }
        .sheet(
            item: $viewModel.accountCheck,
            content: { accountCheck in
                SafariView(url: accountCheck.validationURL)
            }
        )
        .onOpenURL {
            guard viewModel.accountCheck?.validate(url: $0) ?? false else {
                #warning("do something")
                return
            }
            viewModel.accountCheck = nil
        }
    }
}
