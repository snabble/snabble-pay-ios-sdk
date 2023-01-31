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
    let networkManager: NetworkManager = .shared

    @Published var accounts: [Account]?
    @Published var errorOccured: Bool = false

    private var cancellables = Set<AnyCancellable>()

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
                    self.errorOccured = true
                }
            } receiveValue: {
                self.accounts = $0
            }
            .store(in: &cancellables)
    }

    func removeAppId() {
        accounts = nil
        networkManager.reset()
        objectWillChange.send()
    }

//    func validateCallbackURL(_ url: URL) -> Bool {
//        account?.validateCallbackURL(url) ?? false
//    }
}

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel

    @State var showQRCode: Bool = false
    
    var body: some View {
        if let accounts = viewModel.accounts {
            if accounts.isEmpty {
                AccountPendingView()
            } else {
                CredentialsView(accounts: accounts) {
                    viewModel.removeAppId()
                }
            }
        } else {
            if viewModel.errorOccured {
                Text("Error")
            } else {
                Text("Loading")
                    .onAppear {
                        viewModel.loadAccounts()
                    }
            }
        }
        Button {
            showQRCode.toggle()
        } label: {
            Text("Show QRCode")
        }
        .sheet(isPresented: $showQRCode) {
            QRCodeView(code: "12345")
        }
    }
}
