//
//  AccountView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import Foundation
import SnabblePayCore
import SnabblePayNetwork
import SwiftUI
import Combine

class AccountViewModel: ObservableObject {
    @Injected(\.networkManager) var networkManager: NetworkManager

    @Published var account: Account?
    @Published var errorOccured: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func loadAccount() {
        let endpoint = Endpoints.Account.get(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.account = nil
                    self.errorOccured = true
                }
            } receiveValue: {
                self.account = $0
            }
            .store(in: &cancellables)
    }

    func acceptMandate() {
        performMandate(action: .accept)
    }

    func declineMandate() {
        performMandate(action: .decline)
    }

    private func performMandate(action: MandateAction) {
        networkManager.publisher(for: action.endpoint(onEnvironment: .development))
            .flatMap { _ in
                let endpoint = Endpoints.Account.get(onEnvironment: .development)
                return self.networkManager.publisher(for: endpoint)
            }
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.account = nil
                }
            } receiveValue: { account in
                self.account = account
            }
            .store(in: &cancellables)
    }

    private enum MandateAction {
        case accept
        case decline

        func endpoint(onEnvironment environment: SnabblePayNetwork.Environment) -> Endpoint<Data> {
            switch self {
            case .accept:
                return Endpoints.Account.Mandate.accept(onEnvironment: environment)
            case .decline:
                return Endpoints.Account.Mandate.decline(onEnvironment: environment)
            }
        }
    }

    func removeAppId() {
        account = nil
        networkManager.reset()
        objectWillChange.send()
    }

    func validateCallbackURL(_ url: URL) -> Bool {
        account?.validateCallbackURL(url) ?? false
    }
}

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel
    
    var body: some View {
        switch viewModel.account?.state {
        case .successful(let credentials, let mandate):
            AccountSuccessView(
                credentials: credentials,
                mandate: mandate,
                onDestructiveAction: {
                    viewModel.removeAppId()
                },
                onAcceptMandate: {
                    viewModel.acceptMandate()
                },
                onDeclineMandate: {
                    print("decline mandate")
                }
            )
        case .pending(let url):
            AccountPendingView(
                url: url,
                onValidation: {
                    if viewModel.validateCallbackURL($0) {
                        viewModel.loadAccount()
                    } else {
                        #warning("something todo")
                    }
                })
        case .error(let message), .failed(let message):
            AccountErrorView(message: message)
        case .none:
            Text("Loading").onAppear {
                viewModel.loadAccount()
            }
        }

    }
}
