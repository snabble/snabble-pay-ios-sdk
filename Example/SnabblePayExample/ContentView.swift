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
    let networkManager: NetworkManager = .init(config: .init(customUrlScheme: "snabble-pay", apiKey: "IO2wX69CsqZUQ3HshOnRkO4y5Gy/kRar6Fnvkp94piA2ivUun7TC7MjukrgUKlu7g8W8/enVsPDT7Kvq28ycw=="))

    private var cancellables = Set<AnyCancellable>()

    @Published var validationURL: URL?

    func accountValidation() {
        let endpoint = Endpoints.account(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .map(\.validationURL)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("error: ", error.localizedDescription)
                }
            } receiveValue: { validationURL in
                self.validationURL = validationURL
            }
            .store(in: &cancellables)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel

    @State var presentingSafariView: Bool = false
    
    var body: some View {
        VStack {
            Button {
                viewModel.accountValidation()
            } label: {
                Text("Payment Validation")
            }
            .sheet(
                isPresented: $presentingSafariView,
                content: {
                    SafariView(url: viewModel.validationURL!)
                }
            )
        }
        .onChange(of: viewModel.validationURL) { newValue in
            presentingSafariView = newValue != nil
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: .init())
    }
}
