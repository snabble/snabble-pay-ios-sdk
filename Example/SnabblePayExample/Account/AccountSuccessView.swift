//
//  AccountSuccessView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import SnabblePayNetwork
import Combine

class SessionViewModel: ObservableObject {
    @Injected(\.networkManager) var networkManager: NetworkManager

    @Published var session: Session?
    @Published var errorOccured: Bool = false

    private var cancellables = Set<AnyCancellable>()

    func startSession() {
        let endpoint = Endpoints.Session.post(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.errorOccured = true
                }
            }, receiveValue: { [weak self] in
                self?.session = $0
            })
            .store(in: &cancellables)
    }
}

class MandateViewModel: ObservableObject {
    @Injected(\.networkManager) var networkManager: NetworkManager

    @Published var mandate: Account.Mandate
    @Published var errorOccured: Bool = false

    init(mandate: Account.Mandate) {
        self.mandate = mandate
    }

    private var cancellables = Set<AnyCancellable>()

    func acceptMandate() {
        let endpoint = Endpoints.Account.Mandate.accept(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.errorOccured = true
                }
            }, receiveValue: { [weak self] mandate in
                self?.mandate = mandate
            })
            .store(in: &cancellables)
    }

    func declineMandate() {
        let endpoint = Endpoints.Account.Mandate.decline(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break
                case .failure:
                    self?.errorOccured = true
                }
            }, receiveValue: { [weak self] mandate in
                self?.mandate = mandate
            })
            .store(in: &cancellables)
    }
}

struct AccountSuccessView: View {
    let credentials: Account.Credentials

    @ObservedObject var mandateViewModel: MandateViewModel
    @ObservedObject var sessionViewModel: SessionViewModel

    init(credentials: Account.Credentials, mandate: Account.Mandate, onDestructiveAction: (() -> Void)? = nil) {
        self.credentials = credentials
        self.onDestructiveAction = onDestructiveAction
        self.mandateViewModel = .init(mandate: mandate)
        self.sessionViewModel = .init()
    }

    var onDestructiveAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Account Success View")
            Text(credentials.holderName)
            Text(credentials.iban.rawValue)
            Spacer()
            switch mandateViewModel.mandate.state {
            case .pending:
                Text(mandateViewModel.mandate.text ?? "Mandate Text")
                HStack(spacing: 16) {
                    Button {
                        mandateViewModel.acceptMandate()
                    } label: {
                        Text("Accept Mandate")
                    }
                    Button {
                        mandateViewModel.declineMandate()
                    } label: {
                        Text("Decline Mandate")
                    }
                }
            case .declined:
                Text("Mandate declined")
            case .accepted:
                if let session = sessionViewModel.session {
                    Text(session.token.rawValue)
                } else {
                    Button {
                        sessionViewModel.startSession()
                    } label: {
                        Text("Karte anzeigen")
                    }
                }
            }
            Spacer()
            Button {
                onDestructiveAction?()
            } label: {
                Text("Remove AppId")
            }
        }
        .sheet(isPresented: $mandateViewModel.errorOccured) {
            Text("Fehler passiert")
        }
    }
}
