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
        if let account = viewModel.account {
            switch account.state {
            case .ready:
                CredentialsView(credentials: account.credentials) {
                    viewModel.removeAppId()
                }
            case .pending:
                AccountPendingView(
                    url: account.validationURL,
                    onValidation: {
                        if viewModel.validateCallbackURL($0) {
                            viewModel.loadAccount()
                        } else {
                            #warning("something todo")
                        }
                    })
            }
        } else {
            if viewModel.errorOccured {
                Text("Error")
            } else {
                Text("Loading")
                    .onAppear {
                        viewModel.loadAccount()
                    }
            }
        }
    }
}
