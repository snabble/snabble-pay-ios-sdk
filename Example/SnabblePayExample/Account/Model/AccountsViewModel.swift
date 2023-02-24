//
//  AccountsViewModel.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 23.02.23.
//

import SnabblePay
import Combine

class AccountsViewModel: ObservableObject {
    let snabblePay: SnabblePay = .shared

    @Published var accounts: [Account]?
    @Published var accountCheck: Account.Check?
    @Published var session: Session?
    @Published var selectedAccount: Account?
    
    var onDestructiveAction: (() -> Void)?

    private var cancellables = Set<AnyCancellable>()

    func loadAccountCheck() {
        snabblePay.accountCheck(withAppUri: "snabble-pay://account/check", city: "Bonn", countryCode: "DE") { [weak self] in
            self?.accountCheck = try? $0.get()
        }
    }

    func loadAccounts() {
        snabblePay.accounts { [weak self] in
            self?.accounts = try? $0.get()
        }
    }

    func acceptMandate(forAccount account: Account) {
        snabblePay.acceptMandate(withId: "1", forAccountId: account.id) { [weak self] _ in
            self?.loadAccounts()
        }
    }

    func declineMandate(forAccount account: Account) {
        snabblePay.declineMandate(withId: "1", forAccountId: account.id) { [weak self] _ in
            self?.loadAccounts()
        }
    }

    func startSession(withAccount account: Account) {
        snabblePay.startSession(withAccountId: account.id) { [weak self] in
            self?.session = try? $0.get()
        }
    }
}

extension AccountsViewModel {
    var unselected: [Account]? {
        guard let selected = selectedAccount else {
            return accounts
        }
        return accounts?.filter({ $0 != selected })
    }
}
