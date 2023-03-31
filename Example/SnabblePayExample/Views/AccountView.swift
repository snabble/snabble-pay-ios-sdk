//
//  AccountView.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 23.02.23.
//

import SwiftUI
import SnabblePay

extension String {
    func prettyPrint(template placeholder: String) -> String {
        let normalized = self.replacingOccurrences(of: " ", with: "")
        
        guard placeholder.replacingOccurrences(of: " ", with: "").count == normalized.count else {
            return self
        }
        
        var offset: Int = 0
        let start = placeholder.index(placeholder.startIndex, offsetBy: 0)
        var result = String()
        
        for char in String(placeholder[start...]) {
            if char == " " {
                result.append(" ")
            } else {
                let currentIndex = normalized.index(normalized.startIndex, offsetBy: offset)
                result.append(String(normalized[currentIndex]))
                offset += 1
            }
        }
        return result
    }
}

extension AccountViewModel {
    var mandateIDString: String {
        return mandate?.id.rawValue ?? ""
    }
    var mandateStateString: String {
        return NSLocalizedString(mandateState.rawValue, comment: "")
    }
    var mandateStateColor: Color {
        switch self.mandateState {
        case .missing, .pending:
            return Color.yellow
        case .accepted:
            return Color.green
        case .declined:
            return Color.red
        }
    }
    var ibanString: String {
        let iban = account.iban.rawValue.replacingOccurrences(of: "*", with: "•")
        return iban.prettyPrint(template: "DEpp bbbb bbbb kkkk kkkk kk")
    }
    var mandateStateImage: Image {
        switch self.mandateState {
        case .missing, .pending:
            return Image(systemName: "questionmark.circle.fill")
        case .accepted:
            return Image(systemName: "checkmark.circle.fill")
        case .declined:
            return Image(systemName: "xmark.circle.fill")
        }
    }
    var backgroundMaterial: Material {
        return autostart ? CardStyle.topMaterial : CardStyle.regularMaterial
    }
}

extension AccountViewModel {
    var htmlText: String? {
        guard let mandateID = mandate?.id.rawValue,
              let html = UserDefaults.standard.object(forKey: mandateID) as? String else {
            return nil
        }
        return html
    }

    var markup: String? {
        guard let markup = htmlText,
              let body = markup.replacingOccurrences(of: "+", with: " ").removingPercentEncoding else {
            return nil
        }
        let head = """
<html>
    <head>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no" />
        <style type="text/css">
            pre { font-family: -apple-system, sans-serif; font-size: 15px; white-space: pre-wrap; }
            body { padding: 8px 8px }
            * { font-family: -apple-system, sans-serif; font-size: 15px; word-wrap: break-word }
            *, a { color: #000 }
            h1 { font-size: 22px }
            h2 { font-size: 17px }
            h4 { font-weight: normal; color: #3c3c43; opacity: 0.6 }
            @media (prefers-color-scheme: dark) {
                a, h4, * { color: #fff }
            }
        </style>
    </head>
    <body>
"""
        let trail = """
    </body>
</html>
"""
        return head + body + trail
    }
}

struct AccountStateView: View {
    @ObservedObject var viewModel: AccountViewModel
    @State private var showMandate = false
    
    var canToggleHTML: Bool {
       return viewModel.mandateState == .accepted && viewModel.htmlText != nil
    }

    @ViewBuilder
    var mandatePending: some View {
        if let mandate = viewModel.mandate {
            VStack {
                mandateState
                    .padding()
                
                if let markup = viewModel.markup {
                    HTMLView(string: markup)
                }
                VStack {
                    Button {
                        viewModel.accept(mandateId: mandate.id)
                    } label: {
                        Text("Accept")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding([.leading, .trailing])
                    Button {
                        viewModel.decline(mandateId: mandate.id)
                    } label: {
                        Text("Decline")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                    }
                    .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding([.leading, .trailing])
                }
                .padding(.bottom)
           }
            .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding([.leading, .trailing])
        }
    }
    
    @ViewBuilder
    var mandateState: some View {
        HStack {
            viewModel.mandateStateImage
                .foregroundStyle(.white, viewModel.mandateStateColor, viewModel.mandateStateColor)
            Text(viewModel.mandateStateString)
            if canToggleHTML {
                Button(action: {
                    withAnimation {
                        showMandate.toggle()
                    }
                }) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.white, viewModel.mandateStateColor, viewModel.mandateStateColor)
                }
            }
        }
    }
    
    @ViewBuilder
    var mandateInfo: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                HStack {
                    Spacer()
                    mandateState
                        .font(.headline)
                    Spacer()
                }
                .padding([.top, .leading, .trailing])
                .padding(.bottom, viewModel.mandate != nil ? 0 : 20)

                if viewModel.mandate != nil {
                    Text(viewModel.mandateIDString)
                        .foregroundColor(.secondary)
                        .font(.footnote)
                        .padding([.bottom], 8)
                    
                    if showMandate, let markup = viewModel.markup {
                        HTMLView(string: markup)
                    }
                }
            }
        }
        .onTapGesture {
            if canToggleHTML {
                withAnimation {
                    showMandate.toggle()
                }
            }
        }
        .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding([.leading, .trailing])
    }

    var body: some View {
        if viewModel.mandateState == .missing {
            HStack {
                Text("No Mandate")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                    .padding()
            }
            .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding([.leading, .trailing])
        } else {
            if viewModel.mandateState == .pending {
                mandatePending
            } else {
                mandateInfo
            }
        }
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
            
            VStack(spacing: 24) {
                ZStack(alignment: .topTrailing) {
                    CardView(model: viewModel, expand: true)
                    Button(action: {
                        delete.toggle()
                    }) {
                        Image(systemName: "trash")
                    }
                    .padding(.trailing, 30)
                    .padding(.top, 10)
                }
                AccountStateView(viewModel: viewModel)
                Spacer()
            }
            .padding([.top], 100)
            .padding([.bottom], 20)
            .onAppear {
                viewModel.createMandate()
            }
            .onChange(of: viewModel.needsReload) { newReload in
                if newReload {
                    accountsModel.loadAccounts()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
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
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    name = viewModel.customName
                    edit.toggle()
                }) {
                    Image(systemName: "square.and.pencil")
                }
            }
        }
    }
    func submit() {
        viewModel.customName = !name.isEmpty ? name : viewModel.account.name
    }
}
