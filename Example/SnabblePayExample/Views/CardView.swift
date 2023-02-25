//
//  CardView.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 23.02.23.
//

import SwiftUI
import SnabblePay

struct AddFirstAccount: View {
    @ObservedObject var viewModel: AccountsViewModel

    var body: some View {
        VStack(spacing: 10) {
            Text("Add your first account now!")
                .frame(maxWidth: .infinity)
                .font(.title3)
                .foregroundColor(.white)
                .shadow(radius: 2)
            Button(action: {
                viewModel.startAccountCheck()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 64))
            }
        }
        .cardStyle()
    }
}

struct CardView: View {
    @ObservedObject var model: AccountViewModel
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.colorScheme) var colorScheme

    private let expand: Bool
    
    @State private var toggleSize = false

    init(model: AccountViewModel, expand: Bool = false) {
        self.model = model
        self.expand = expand
    }

    init(account: Account, expand: Bool = false) {
        self.model = AccountViewModel(account: account, autostart: false)
        self.expand = expand
    }
 
    @ViewBuilder
    var qrImage: some View {
        if let session = model.session {
            QRCodeView(code: session.token.rawValue)
        } else {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Spacer()
                qrImage
                    .padding([.top])
                    .frame(width: toggleSize ? 150 : 80)
                Spacer()
            }
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(model.account.holderName)
                    Spacer()
                    Text(model.account.bank)
                }
                Text(model.account.iban.rawValue.replacingOccurrences(of: "*", with: "•"))
                    .font(.custom("Menlo", size: 16))
                    .fontWeight(.bold)
            }
            .padding([.leading, .trailing])
            .padding([.bottom], model.autostart ? 20 : 10)
            .foregroundColor(model.autostart ? .primary : .secondary)
            
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                model.refresh()
            }
        }
        .onAppear {
            withAnimation {
                self.toggleSize = self.expand || self.model.session != nil
            }
        }
        .onChange(of: model.sessionUpdated) { _ in
            withAnimation {
                toggleSize = model.autostart
            }
        }
        .cardStyle(top: model.autostart)
    }
}
