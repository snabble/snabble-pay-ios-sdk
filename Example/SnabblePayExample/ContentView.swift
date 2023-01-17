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

    @Published var validationURL: URL?
    @Published var errorOccured: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func accountValidation() {
        let endpoint = Endpoints.account(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .map(\.validationURL)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self.errorOccured = true
                }
            } receiveValue: {
                self.validationURL = $0
            }
            .store(in: &cancellables)
    }

    func removeAppId() {
        networkManager.reset()
        objectWillChange.send()
    }

    func validateCallbackURL(_ url: URL) {
        guard Account.validateCallbackURL(url, forScheme: networkManager.config.customUrlScheme) else {
            return
        }
        validationURL = nil
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Button {
                viewModel.accountValidation()
            } label: {
                Text("Account Validation")
            }
            .sheet(item: $viewModel.validationURL) { url in
                SafariView(url: url)
            }
            Button {
                viewModel.removeAppId()
            } label: {
                Text("Remove AppId")
            }
        }
        .alert(isPresented: $viewModel.errorOccured, content: {
            Alert(title: Text("Error occured"))
        })
        .onOpenURL {
            viewModel.validateCallbackURL($0)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
