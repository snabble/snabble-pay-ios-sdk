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
    private let snabblePay: SnabblePay = .shared

    let account: Account
    var autostart: Bool {
        didSet {
            if autostart == false {
                resetTimer()
            }
        }
    }

    private var refreshTimer: Timer?
    
    private func resetTimer() {
        refreshTimer?.invalidate()
        refreshTimer = nil
        
        if autostart, let refreshAt = session?.refreshAt {
            self.refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshAt.timeIntervalSince(.now), repeats: false) { _ in
                self.startSession()
            }
        }
    }

    init(account: Account, autostart: Bool = true) {
        self.account = account
        self.autostart = autostart
        
        if let name = UserDefaults.standard.string(forKey: account.id.rawValue) {
            self.customName = name
        } else {
            self.customName = account.name
        }
    }

    @Published var mandate: Account.Mandate?
    @Published var session: Session? {
        didSet {
            resetTimer()
        }
    }
    @Published var sessionUpdated = false
    @Published var isLoading = false
    @Published var customName: String {
        didSet {
            if !customName.isEmpty {
                UserDefaults.standard.set(customName, forKey: account.id.rawValue)
            } else {
                UserDefaults.standard.set(nil, forKey: account.id.rawValue)
            }
        }
    }
    
    func createMandate() {
        snabblePay.createMandate(forAccountId: account.id) { [weak self] result in
            switch result {
            case .success(let mandate):
                self?.mandate = mandate

            case .failure(let error):
                ErrorHandler.shared.error = ErrorInfo(error: error, action: "Create Mandate")
            }
        }
    }

    func decline(mandateId: Account.Mandate.ID) {
        snabblePay.declineMandate(withId: mandateId, forAccountId: account.id) { [weak self] result in
            switch result {
            case .success(let mandate):
                self?.mandate = mandate

            case .failure(let error):
                ErrorHandler.shared.error = ErrorInfo(error: error, action: "Decline Mandate")
            }
       }
    }

    func accept(mandateId: Account.Mandate.ID) {
        snabblePay.acceptMandate(withId: mandateId, forAccountId: account.id) { [weak self] result in
            switch result {
            case .success(let mandate):
                self?.mandate = mandate

            case .failure(let error):
                ErrorHandler.shared.error = ErrorInfo(error: error, action: "Accept Mandate")
            }
        }
    }

    func startSession() {
        guard self.autostart else {
            return
        }
        isLoading = true
        
        snabblePay.startSession(withAccountId: account.id) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let session):
                self?.session = session
                self?.sessionUpdated.toggle()

            case .failure(let error):
                ErrorHandler.shared.error = ErrorInfo(error: error, action: "Start Session")
            }
        }
    }
}

extension AccountViewModel {
    
    var canSelect: Bool {
        return isLoading == false
    }
    
    var needsRefresh: Bool {
        guard self.autostart else {
            return false
        }
        guard let session = self.session else {
            return true
        }
        return session.refreshAt.timeIntervalSince(.now) <= 0
    }
    
    func sleep() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func refresh() {
        if needsRefresh {
            startSession()
        }
    }
}
