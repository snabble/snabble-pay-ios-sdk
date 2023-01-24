//
//  AccountSuccessView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import SnabblePayNetwork
import Combine

class AccountSuccessViewModel: ObservableObject {
    @Injected(\.networkManager) var networkManager: NetworkManager

    @Published var mandateState: Account.Mandate.State?

    private var cancellables = Set<AnyCancellable>()

    func acceptMandate() {
        let endpoint = Endpoints.Account.Mandate.accept(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .map { _ in Account.Mandate.State.accepted }
            .replaceError(with: nil)
            .weakAssign(to: \.mandateState, on: self)
            .store(in: &cancellables)
    }

    func declineMandate() {
        let endpoint = Endpoints.Account.Mandate.decline(onEnvironment: .development)
        networkManager.publisher(for: endpoint)
            .receive(on: DispatchQueue.main)
            .map { _ in Account.Mandate.State.accepted }
            .replaceError(with: nil)
            .weakAssign(to: \.mandateState, on: self)
            .store(in: &cancellables)
    }
}

struct AccountSuccessView: View {
    var credentials: Account.Credentials
    var mandate: Account.Mandate?

    var onDestructiveAction: (() -> Void)?
    var onAcceptMandate: (() -> Void)?
    var onDeclineMandate: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            Spacer()
            Text("Account Success View")
            Text(credentials.holderName)
            Text(credentials.iban.rawValue)
            Spacer()
            Text(mandate?.text ?? "Mandate Text")
            HStack(spacing: 16) {
                Button {
                    onAcceptMandate?()
                } label: {
                    Text("Accept Mandate")
                }
                Button {
                    onDeclineMandate?()
                } label: {
                    Text("Decline Mandate")
                }
            }
            Spacer()
            Button {
                onDestructiveAction?()
            } label: {
                Text("Remove AppId")
            }

        }
    }
}
