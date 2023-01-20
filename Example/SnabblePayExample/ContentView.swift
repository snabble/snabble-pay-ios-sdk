//
//  ContentView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2022-12-08.
//

import SwiftUI
import Combine
import SnabblePayCore
import SnabblePayNetwork
import BetterSafariView

class ViewModel: ObservableObject {
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
        guard Account.validateCallbackURL(url, forScheme: networkManager.config.customUrlScheme) else {
            return false
        }
        return true
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    @State var validationURL: URL?
    @State var iban: Credential.IBAN?
    
    var body: some View {
        VStack(spacing: 8) {
            Button {
                viewModel.loadAccount()
            } label: {
                Text("Fetch Account")
            }
            .sheet(item: $validationURL) { url in
                SafariView(url: url)
            }

            if let iban = iban {
                Text(iban.rawValue)
            }

            Button {
                viewModel.removeAppId()
            } label: {
                Text("Remove AppId")
            }
        }
        .onChange(of: viewModel.account, perform: { newValue in
            validationURL = newValue?.validationURL
            iban = newValue?.credentials?.iban
        })
        .alert(isPresented: $viewModel.errorOccured, content: {
            Alert(title: Text("Error occured"))
        })
        .onOpenURL {
            if viewModel.validateCallbackURL($0) {
                validationURL = nil
                viewModel.loadAccount()
            }

        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
