//
//  AccountViewModel.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 23.02.23.
//
import Foundation
import SnabblePay
import Combine

class AccountViewModel: ObservableObject {
    let snabblePay: SnabblePay = .shared

    let account: Account
    private var refreshTimer: Timer?

    init(account: Account) {
        self.account = account
    }

    @Published var mandate: Account.Mandate?
    @Published var session: Session? {
        didSet {
            refreshTimer?.invalidate()
            refreshTimer = nil
            if let refreshAt = session?.refreshAt {
                self.refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshAt.timeIntervalSince(.now), repeats: false) { _ in
                    self.startSession()
                }
            }

        }
    }
    @Published var sessionUpdated = false
    
    func createMandate() {
        snabblePay.createMandate(forAccountId: account.id) { [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func decline(mandateId: Account.Mandate.ID) {
        snabblePay.declineMandate(withId: mandateId, forAccountId: account.id) { [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func accept(mandateId: Account.Mandate.ID) {
        snabblePay.acceptMandate(withId: mandateId, forAccountId: account.id) { [weak self] result in
            self?.mandate = try? result.get()
        }
    }

    func startSession() {
        snabblePay.startSession(withAccountId: account.id) { [weak self] result in
            if let session = try? result.get() {
                self?.session = session
                self?.sessionUpdated.toggle()
            } else {
                self?.session = nil
            }
        }
    }
}

extension AccountViewModel {
    var needsRefresh: Bool {
        guard let session = self.session else {
            return true
        }
        return session.refreshAt.timeIntervalSince(.now) <= 0
    }
    
    func refresh() {
        if needsRefresh {
            startSession()
        }
    }
}
