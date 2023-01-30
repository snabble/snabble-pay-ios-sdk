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
    private(set) var credentials: [Account.Credentials]
    let networkManager: NetworkManager = .shared

    private(set) var session: SnabblePayNetwork.Session?

    var onDestructiveAction: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    init(credentials: [Account.Credentials], onDestructiveAction: (() -> Void)? = nil) {
        self.credentials = credentials
        self.onDestructiveAction = onDestructiveAction
    }

    func acceptMandate(forCredentialsId credentialsId: Account.Credentials.ID) {
        let endpoint = Endpoints.Account.Credentials.Mandate.accept(credentialsId: credentialsId, onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { [weak self] _ in
                self?.update()
            } receiveValue: { mandate in
                print(mandate)
            }
            .store(in: &cancellables)
    }

    func declineMandate(forCredentialsId credentialsId: Account.Credentials.ID) {
        let endpoint = Endpoints.Account.Credentials.Mandate.decline(credentialsId: credentialsId, onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { [weak self] _ in
                self?.update()
            } receiveValue: { mandate in
                print(mandate)
            }
            .store(in: &cancellables)
    }

    func startSession(withCredentialsId credentialsId: Account.Credentials.ID) {
        let endpoint = Endpoints.Session.post(withCredentialsId: credentialsId, onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { [weak self] _ in
                self?.update()
            } receiveValue: { session in
                self.session = session
            }
            .store(in: &cancellables)
    }

    private func update() {
        let endpoint = Endpoints.Account.Credentials.get(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { completion in
                print(completion)
            } receiveValue: { credentials in
                self.credentials = credentials
            }
            .store(in: &cancellables)
    }
}

struct CredentialsView: View {
    @ObservedObject var viewModel: CredentialsViewModel

    init(credentials: [Account.Credentials], onDestructiveAction: (() -> Void)? = nil) {
        self.viewModel = .init(
            credentials: credentials,
            onDestructiveAction: onDestructiveAction
        )
    }

    var body: some View {
        NavigationView {
            ForEach(viewModel.credentials) { credential in
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(credential.holderName)
                        Text(credential.iban.rawValue)
                    }
                    Spacer()
                    switch credential.mandate.state {
                    case .pending:
                        VStack(alignment: .center, spacing: 8) {
                            Button {
                                viewModel.acceptMandate(forCredentialsId: credential.id)
                            } label: {
                                Text("Accept")
                            }
                            Button {
                                viewModel.declineMandate(forCredentialsId: credential.id)
                            } label: {
                                Text("Decline")
                            }
                        }
                    case .accepted:
                        Button {
                            viewModel.startSession(withCredentialsId: credential.id)
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
