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
        
        if autostart, let refreshAt = session?.token.refreshAt {
            self.refreshTimer = Timer.scheduledTimer(withTimeInterval: refreshAt.timeIntervalSince(.now), repeats: false) { _ in
                self.refreshToken()
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

    @Published var mandate: Account.Mandate? {
        didSet {
            if let mandateID = mandate?.id.rawValue, let html = mandate?.htmlText {
                UserDefaults.standard.set(html, forKey: mandateID)
            }
        }
    }

    var mandateState: Account.Mandate.State {
        guard let mandate = mandate else {
            return account.mandateState
        }
        return mandate.state
    }
    
    private var session: Session?
    @Published var token: Session.Token? {
        didSet {
            resetTimer()
            sessionUpdated.toggle()
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

    private func startSession() {
        guard self.autostart else {
            return
        }
        guard self.mandateState == .accepted else {
            return
        }
        
        isLoading = true
        
        snabblePay.startSession(withAccountId: account.id) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let session):
                self?.session = session
                self?.token = session.token
                
            case .failure(let error):
                ErrorHandler.shared.error = ErrorInfo(error: error, action: "Start Session")
            }
        }
    }
    private func refreshToken() {
        guard let session = self.session else {
            return
        }
        isLoading = true
        
        snabblePay.refreshToken(withSessionId: session.id) { [weak self] result in
            self?.isLoading = false
            
            switch result {
            case .success(let token):
                print("token refreshed \(token)")
                self?.token = token

            case .failure(let error):
                ErrorHandler.shared.error = ErrorInfo(error: error, action: "Refresh Token")
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
        return session.token.refreshAt.timeIntervalSince(.now) <= 0
    }
    
    func sleep() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }
    
    func refresh() {
        if needsRefresh {
            if self.session != nil {
                refreshToken()
            } else {
                startSession()
            }
        }
    }
}
