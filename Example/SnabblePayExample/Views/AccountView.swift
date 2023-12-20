//
//  AccountView.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 23.02.23.
//

import SwiftUI
import SnabblePay

extension AccountViewModel {
    var backgroundMaterial: Material {
        return autostart ? CardStyle.topMaterial : CardStyle.regularMaterial
    }
}

struct AccountView: View {
    @ObservedObject var accountsModel: AccountsViewModel
    @ObservedObject var viewModel: AccountViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var edit = false
    @State private var delete = false
    @State private var name: String = ""

    init(accountsModel: AccountsViewModel) {
        self.accountsModel = accountsModel
        self.viewModel = accountsModel.selectedAccountModel!
    }

    var body: some View {
        ZStack {
            BackgroundView()
            VStack(spacing: 16) {
                Spacer()
                CardView(model: viewModel, expand: true)
                AccountStateView(viewModel: viewModel)
                Spacer()
                Button {
                    name = viewModel.customName
                    edit.toggle()
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit name")
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
                }
                Button {
                    delete.toggle()
                } label: {
                    HStack {
                        Image(systemName: "trash")
                        Text("Delete account")
                    }
                }
            }
            .onAppear {
                viewModel.createMandate()
            }
            .onChange(of: viewModel.needsReload) { newReload in
                if newReload {
                    accountsModel.loadAccounts()
                }
            }
        }
        .padding(.bottom, 16)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(viewModel.customName)
        .alert("Your account", isPresented: $edit) {
            TextField("Account Name", text: $name)
            Button("OK", action: submit)
        } message: {
            Text("Give this account a name.")
        }
        .confirmationDialog("Delete account", isPresented: $delete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                accountsModel.delete(account: viewModel.account)
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }

    func submit() {
        viewModel.customName = !name.isEmpty ? name : viewModel.account.name
    }
}
