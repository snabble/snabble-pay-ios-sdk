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
    var mandateState: some View {
        if !self.expand, model.mandateState != .accepted {
            HStack {
                model.mandateStateImage
                    .foregroundStyle(.white, model.mandateStateColor, model.mandateStateColor)
                Text(model.mandateStateString)
            }
        }
    }
    
    @ViewBuilder
    var qrImage: some View {
        if let qrCode = model.token?.value {
            QRCodeView(code: qrCode)
        } else {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .foregroundColor(colorScheme == .dark ? .white : .black)
        }
    }
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            Spacer(minLength: 0)
            mandateState
            qrImage
                .padding([.top])
                .frame(width: toggleSize ? 160 : 60)
            Spacer()
            
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(model.account.holderName)
                    Spacer()
                    Text(model.account.bank)
                }
                Text(model.ibanString)
                    .font(.custom("Menlo", size: 16))
                    .fontWeight(.bold)
            }
            .padding([.leading, .trailing])
            .padding([.bottom], model.autostart ? 20 : 10)
            .foregroundColor(model.autostart ? .primary : .secondary)
        }
        .cardStyle(top: model.autostart)
        .onChange(of: scenePhase) { newPhase in
            guard model.autostart else {
                return
            }
            if newPhase == .active {
                model.refresh()
            } else if newPhase == .background {
                model.sleep()
            }
        }
        .onAppear {
            withAnimation {
                self.toggleSize = self.expand || self.model.token != nil
            }
        }
        .onChange(of: model.sessionUpdated) { _ in
            withAnimation {
                toggleSize = model.autostart
            }
        }
    }
}
