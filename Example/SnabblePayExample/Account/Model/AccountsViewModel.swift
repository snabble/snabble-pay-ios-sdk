//
//  AccountsViewModel.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 23.02.23.
//
import Foundation
import SnabblePay
import Combine

extension UserDefaults {
    private enum Keys {
        static let selectedAccount = "account"
    }

    class var selectedAccount: String? {
        get {
            return UserDefaults.standard.string(forKey: Keys.selectedAccount)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.selectedAccount)
        }
    }
}

class AccountsViewModel: ObservableObject {
    let snabblePay: SnabblePay = .shared

    @Published var accounts: [Account]? {
        didSet {
            if let selectedID = UserDefaults.selectedAccount, let account = accounts?.first(where: { $0.name == selectedID }) {
                selectedAccount = account
            } else if let first = accounts?.first {
                selectedAccount = first
            } else {
                selectedAccount = nil
            }
        }
    }
    @Published var accountCheck: Account.Check?
    @Published var session: Session?
    @Published var ordered: [Account]?
    
    func accountStack() -> [Account]? {
        guard let selected = selectedAccount else {
            return accounts
        }
        var array = [Account]()
        array.append(selected)
        if let unselected = self.unselected {
            array.append(contentsOf: unselected)
        }
        return array.reversed()
    }

    @Published var selectedAccountModel: AccountViewModel? {
        willSet {
            if let model = selectedAccountModel {
                model.autostart = false
            }
        }
        didSet {
            if let model = selectedAccountModel {
                UserDefaults.selectedAccount = model.account.name
                model.autostart = true
                model.refresh()
            }
            self.ordered = accountStack()
        }
    }
    
    var selectedAccount: Account? {
        didSet {
            if let account = selectedAccount {
                self.selectedAccountModel = AccountViewModel(account: account)
            } else {
                self.selectedAccountModel = nil
            }
        }
    }
    func isSelected(index: Int) -> Bool {
        guard let account = selectedAccount, let first = ordered?.firstIndex(where: { $0 == account }) else {
            return false
        }
        return index == first
    }
    
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
}

extension AccountsViewModel {    
    var unselected: [Account]? {
        guard let selected = selectedAccount else {
            return accounts
        }
        return accounts?.filter({ $0 != selected })
    }
}
