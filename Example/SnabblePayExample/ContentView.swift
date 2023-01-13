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

class ViewModel: ObservableObject {
    let networkManager: NetworkManager = .init(config: .init(customUrlScheme: "snabble-pay", apiKey: "IO2wX69CsqZUQ3HshOnRkO4y5Gy/kRar6Fnvkp94piA2ivUun7TC7MjukrgUKlu7g8W8/enVsPDT7Kvq28ycw=="))

    private var cancellables = Set<AnyCancellable>()

    func accountValidation() {
        let endpoint = Endpoints.account(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .sink { completion in
                switch completion {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("error: ", error.localizedDescription)
                }
            } receiveValue: { validation in
                print("validation: ", validation)
            }
            .store(in: &self.cancellables)
    }
}

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        VStack {
            Button {
                viewModel.accountValidation()
            } label: {
                Text("Payment Validation")
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
