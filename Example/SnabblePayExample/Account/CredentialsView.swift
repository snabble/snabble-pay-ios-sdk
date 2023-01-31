//
//  CredentialsView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import SnabblePayNetwork
import Combine

class CredentialsViewModel: ObservableObject {
    @Published private(set) var accounts: [Account]
    let networkManager: NetworkManager = .shared

    @Published private(set) var session: SnabblePayNetwork.Session?

    var onDestructiveAction: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    init(accounts: [Account], onDestructiveAction: (() -> Void)? = nil) {
        self.accounts = accounts
        self.onDestructiveAction = onDestructiveAction
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

struct CredentialsView: View {
    @ObservedObject var viewModel: CredentialsViewModel

    init(accounts: [Account], onDestructiveAction: (() -> Void)? = nil) {
        self.viewModel = .init(
            accounts: accounts,
            onDestructiveAction: onDestructiveAction
        )
    }

    var body: some View {
        NavigationView {
            ForEach(viewModel.accounts) { account in
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
        }
        Button {
            viewModel.onDestructiveAction?()
        } label: {
            Text("Remove AppId")
        }
    }
}
