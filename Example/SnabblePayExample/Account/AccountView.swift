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
    let networkManager: NetworkManager = .init(
        config: .init(
            customUrlScheme: "snabble-pay",
            apiKey: "IO2wX69CsqZUQ3HshOnRkO4y5Gy/kRar6Fnvkp94piA2ivUun7TC7MjukrgUKlu7g8W8/enVsPDT7Kvq28ycw=="
        )
    )

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
                    self.errorOccured = true
                }
            } receiveValue: {
                self.account = $0
            }
            .store(in: &cancellables)
    }

    func removeAppId() {
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
            AccountSuccessView(credentials: credentials, mandate: mandate)
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
