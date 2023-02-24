//
//  CredentialsView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import SnabblePay
import Combine
import BetterSafariView

struct BackgroundView: View {
    @ObservedObject var motionManager = MotionManager()
    
    var body: some View {
        GeometryReader { geom in
            Image("Background")
                .resizable()
                .scaledToFit()
                .offset(x: -80, y: -120)
                .frame(width: geom.size.width+160, height: geom.size.height+160)
                .modifier(ParallaxMotionModifier(manager: motionManager, magnitude: 20))
        }
    }
}

struct AccountsView: View {
    @ObservedObject var viewModel: AccountsViewModel = .init()
    
    var body: some View {
        NavigationStack {
            if let accounts = viewModel.accounts, !accounts.isEmpty {
                    if accounts.count == 1, let account = accounts.first {
                        ZStack {
                            BackgroundView()
                            NavigationLink {
                                AccountView(account: account)
                            } label: {
                                CardView(account: account)
                            }
                        }
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    viewModel.loadAccountCheck()
                                }) {
                                    Image(systemName: "plus")
                                        .foregroundColor(.white)
                                }
                            }
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    SnabblePay.reset()
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.white)
                                }
                            }
                       }
                    } else {
                        List(accounts) { account in
                            NavigationLink {
                                AccountView(account: account)
                            } label: {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(account.holderName)
                                    Text(account.iban.rawValue)
                                }
                            }
                        }
                        .padding()
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    viewModel.loadAccountCheck()
                                }) {
                                    Image(systemName: "plus")
                                }
                            }
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button(action: {
                                    SnabblePay.reset()
                                }) {
                                    Image(systemName: "trash")
                                }
                            }
                       }
                        .navigationTitle("Bank accounts")
                    }
            } else {
                ZStack {
                    BackgroundView()
                    AddFirstAccount(viewModel: viewModel)
                }
                .onAppear {
                    viewModel.loadAccounts()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .sheet(
            item: $viewModel.accountCheck,
            content: { accountCheck in
                SafariView(url: accountCheck.validationURL)
            }
        )
        .onOpenURL {
            guard viewModel.accountCheck?.validate(url: $0) ?? false else {
                #warning("do something")
                return
            }
            viewModel.accountCheck = nil
            viewModel.loadAccounts()
        }
    }
}
