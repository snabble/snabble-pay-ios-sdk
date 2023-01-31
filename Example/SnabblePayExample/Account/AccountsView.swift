//
//  CredentialsView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import SnabblePayNetwork
import Combine
import BetterSafariView

class AccountsViewModel: ObservableObject {
    let networkManager: NetworkManager = .shared

    @Published var accounts: [Account]?
    @Published var accountCheck: Account.Check?
    @Published var session: SnabblePayNetwork.Session?

    var onDestructiveAction: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    func loadAccountCheck() {
        let endpoint = Endpoints.Accounts.check(appUri: "snabble-pay://account/check", onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.accountCheck = nil
                }
            } receiveValue: {
                self.accountCheck = $0
            }
            .store(in: &cancellables)
    }

    func loadAccounts() {
        let endpoint = Endpoints.Accounts.get(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.accounts = nil
                }
            } receiveValue: {
                self.accounts = $0
            }
            .store(in: &cancellables)
    }

    func acceptMandate(forAccountId accountId: Account.ID) {
        let endpoint = Endpoints.Accounts.Mandate.accept(accountId: accountId, onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { [weak self] _ in
                self?.update()
            } receiveValue: { mandate in
                print(mandate)
            }
            .store(in: &cancellables)
    }

    func declineMandate(forAccountId accountId: Account.ID) {
        let endpoint = Endpoints.Accounts.Mandate.decline(accountId: accountId, onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { [weak self] _ in
                self?.update()
            } receiveValue: { mandate in
                print(mandate)
            }
            .store(in: &cancellables)
    }

    func startSession(withAccountId accountId: Account.ID) {
        let endpoint = Endpoints.Session.post(withAccountId: accountId, onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { [weak self] _ in
                self?.update()
            } receiveValue: { session in
                self.session = session
            }
            .store(in: &cancellables)
    }

    private func update() {
        let endpoint = Endpoints.Accounts.get(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { completion in
                print(completion)
            } receiveValue: { accounts in
                self.accounts = accounts
            }
            .store(in: &cancellables)
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
                                    viewModel.acceptMandate(forAccountId: account.id)
                                } label: {
                                    Text("Accept")
                                }
                                Button {
                                    viewModel.declineMandate(forAccountId: account.id)
                                } label: {
                                    Text("Decline")
                                }
                            }
                        case .accepted:
                            Button {
                                viewModel.startSession(withAccountId: account.id)
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
