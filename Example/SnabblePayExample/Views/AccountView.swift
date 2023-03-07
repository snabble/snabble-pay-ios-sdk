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
        return NSLocalizedString(account.mandateState.rawValue, comment: "")
    }
    var mandateStateColor: Color {
        switch account.mandateState {
        case .pending:
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
        switch account.mandateState {
        case .pending:
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
       return viewModel.account.mandateState == .accepted && viewModel.htmlText != nil
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
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Spacer()
                mandateState
                    .font(.headline)
                    .padding([.top])
                Spacer()
            }
            if viewModel.mandate != nil {
                Text(viewModel.mandateIDString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding([.top, .bottom], 8)
                if showMandate, let markup = viewModel.markup {
                    HTMLView(string: markup)
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
        if let mandate = viewModel.mandate {
            if mandate.state == .pending {
                mandatePending
            } else {
                mandateInfo
            }
        } else {
            HStack {
                Text("No Mandate")
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.red)
                    .padding()
            }
            .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding([.leading, .trailing])
        }
    }
}

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel
    @State private var edit = false
    @State private var name: String = ""
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 24) {
                CardView(model: viewModel, expand: true)
                AccountStateView(viewModel: viewModel)
                Spacer()
            }
            .padding([.top], 100)
            .padding([.bottom], 40)
            .onAppear {
                viewModel.createMandate()
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
