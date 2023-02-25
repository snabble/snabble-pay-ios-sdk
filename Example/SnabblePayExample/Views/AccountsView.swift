//
//  CredentialsView.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 23.02.23.
//

import SwiftUI
import SnabblePay
import Combine
import BetterSafariView

struct AccountsView: View {
    @ObservedObject var viewModel: AccountsViewModel = .init()
    @State private var offset: CGFloat = 60
    @State private var animationOffset: CGFloat = 0
    @State private var zIndex: Double = 0
    @State private var reset: Bool = false
    @State private var animationStarted = false
    let inTime = 0.35
    let outTime = 0.25
    
    private func tapGesture(account: Account) -> some Gesture {
        LongPressGesture(minimumDuration: 0.05)
                .onChanged { change in
                    if viewModel.canSelect, !animationStarted {
                        withAnimation(.easeIn(duration: inTime)) {
                            animationStarted = true
                            animationOffset = -60
                            zIndex = 300
                            viewModel.selectedAccount = account
                        }
                    }
                }
    }

    @ViewBuilder
    private func cardView(account: Account, index: Int) -> some View {
        if viewModel.selectedAccount == account, let model = viewModel.selectedAccountModel {
                NavigationLink {
                    AccountView(viewModel: model)
                } label: {
                    CardView(model: model)
                }
        } else {
            CardView(account: account, expand: false)
        }
    }

    @ViewBuilder
    var header: some View {
        VStack {
            Image("Title")
            Text("The Future of Mobile Payment")
                .foregroundColor(.accentColor)
        }
        .offset(y: -280)
        .shadow(radius: 3)
        .shadow(radius: 3)
    }

    var body: some View {
        NavigationStack {
            if let ordered = viewModel.ordered, !ordered.isEmpty {
                ZStack {
                    BackgroundView()
                    
                    header
                    
                    ForEach(Array(ordered.enumerated()), id: \.offset) { index, account in
                        cardView(account: account, index: index)
                            .modifier(SlideEffect(offset: (offset * CGFloat(index) * -1) - CGFloat(viewModel.isSelected(index: index) ? animationOffset : 0)))
                            .gesture(tapGesture(account: account))
                            .zIndex(viewModel.isSelected(index: index) ? 200 : zIndex)
                    }
                }
                .confirmationDialog("Reset all accounts", isPresented: $reset, titleVisibility: .visible) {
                    Button("Reset", role: .destructive) {
                        SnabblePay.reset()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.viewModel.loadAccounts()
                        }
                    }
                }
                .onChange(of: animationStarted) { value in
                    if value == true {
                        DispatchQueue.main.asyncAfter(deadline: .now() + inTime + 0.1) {
                            withAnimation(.easeIn(duration: outTime)) {
                                animationOffset = 0
                                animationStarted = false
                                zIndex = 0
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                                    viewModel.selectedAccountModel?.startSession()
                                }
                            }
                        }
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            viewModel.startAccountCheck()
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            reset.toggle()
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                }
            } else {
                ZStack {
                    BackgroundView()
                    header
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
                // User: u98235448, Password: cdz248
                // User: u86382190, Password: gmg612
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
