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

struct AccountsView: View {
    @ObservedObject var viewModel: AccountsViewModel = .init()
    @State private var offset: CGFloat = 60
    @State private var animationOffset: CGFloat = 0
    @State private var opacity: CGFloat = 1.0
    @State private var reset: Bool = false
    
    func card(account: Account, index: Int) -> some View {
        if viewModel.selectedAccount == account, let model = viewModel.selectedAccountModel {
            return AnyView(
                NavigationLink {
                    AccountView(viewModel: model)
                } label: {
                    CardView(model: model, index: index)
                })
        } else {
            return AnyView(CardView(account: account, expand: false, index: index))
        }
    }
    
    func slideOffset(index: Int) -> CGFloat {
        let selectedOffset: CGFloat = viewModel.isSelected(index: index) ? animationOffset : 0
        return (offset * CGFloat(index) * -1) + selectedOffset
    }
    func zIndex(index: Int) -> Double {
        return viewModel.isSelected(index: index) ? 200 : 100
    }
    func opacity(index: Int) -> Double {
        return viewModel.isSelected(index: index) ? 1 : opacity
    }
    
    func tapGesture(account: Account) -> some Gesture {
        LongPressGesture(minimumDuration: 0.05)
                .onChanged { _ in
                        withAnimation {
                            animationOffset = 60
                            opacity = 0
                            viewModel.selectedAccount = account
                        }
                }
                .onEnded { finished in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            withAnimation {
                                animationOffset = 0
                                opacity = 1
                            }
                        }
                }
    }
    
    var body: some View {
        NavigationStack {
            if let ordered = viewModel.ordered, !ordered.isEmpty {
                ZStack {
                    BackgroundView()

                    VStack {
                        Image("Title")
                        Text("The Future of Mobile Payment")
                            .foregroundColor(.accentColor)
                    }
                    .offset(y: -280)
                    .shadow(radius: 3)
                    .shadow(radius: 3)
                    
                    ForEach(Array(ordered.enumerated()), id: \.offset) { index, account in
                        card(account: account, index: index)
                            .modifier(SlideEffect(offset: slideOffset(index: index)))
                            .gesture( tapGesture(account: account)
//                                LongPressGesture(minimumDuration: 0.05)
//                                    .onChanged { _ in
//                                        if viewModel.session != nil {
//                                            withAnimation {
//                                                animationOffset = 60
//                                                opacity = 0
//                                                viewModel.selectedAccount = account
//                                            }
//                                        }
//                                    }
//                                    .onEnded { finished in
//                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                            withAnimation {
//                                                animationOffset = 0
//                                                opacity = 1
//                                            }
//                                        }
//                                    }
//
                            )
                            .opacity(opacity(index: index))
                            .zIndex(zIndex(index: index))
                    }
                }
                .confirmationDialog("Reset all accounts", isPresented: $reset, titleVisibility: .visible) {
                    Button("Reset", role: .destructive) {
                        SnabblePay.reset()
                        viewModel.loadAccounts()
                    }
                }
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
                            reset.toggle()
                        }) {
                            Image(systemName: "trash")
                        }
                    }
                }
            } else {
                ZStack {
                    BackgroundView()
                    
                    VStack {
                        Image("Title")
                        Text("The Future of Mobile Payment")
                    }
                    .offset(y: -300)
                    .shadow(radius: 3)
                    .shadow(radius: 3)

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
