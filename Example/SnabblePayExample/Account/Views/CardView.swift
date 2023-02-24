//
//  CardView.swift
//  
//
//  Created by Uwe Tilemann on 23.02.23.
//

import SwiftUI
import SnabblePay

struct SlideEffect: AnimatableModifier {
    var offset: CGFloat = 0

    var animatableData: CGFloat {
        get {
            offset
        } set {
            offset = newValue
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
    }
}

struct AddFirstAccount: View {
    @ObservedObject var viewModel: AccountsViewModel
    @ObservedObject var motionManager = MotionManager.shared

    var body: some View {
        VStack(spacing: 10) {
            Text("Add your first account now!")
                .font(.title3)
                .foregroundColor(.white)
                .shadow(radius: 2)
            Button(action: {
                viewModel.loadAccountCheck()
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 64))
            }
        }
        .frame(minWidth: 320, maxHeight: 220)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .rotation3DEffect(.degrees(motionManager.xCoordinate * 20), axis: (x: 0, y: 1, z: 0))
        .padding([.leading, .trailing])
    }
}

struct CardView: View {

    @ObservedObject var model: AccountViewModel
    @ObservedObject var motionManager = MotionManager.shared
    
    private let expand: Bool
    private var index: Int = 0
    
    @State private var toggleSize = false
    
    @Environment(\.scenePhase) var scenePhase

    init(model: AccountViewModel, expand: Bool = false, index: Int = 0) {
        self.model = model
        self.expand = expand
        self.index = index
    }
    init(account: Account, expand: Bool = false, index: Int = 0) {
        self.model = AccountViewModel(account: account, autostart: false)
        self.expand = expand
        self.index = index
    }
    
    @ViewBuilder
    var qrImage: some View {
        if let session = model.session {
            QRCodeView(code: session.token.rawValue)
        } else {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
        }
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Spacer()
                qrImage
                    .padding([.top])
                    .frame(width: toggleSize ? 150 : 80)
                    .onTapGesture {
                        withAnimation {
                            toggleSize.toggle()
                        }
                    }
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
            self.toggleSize = self.expand || self.model.session != nil
        }
        .onChange(of: model.sessionUpdated) { _ in
            withAnimation {
                toggleSize = true
            }
        }
        .frame(minWidth: 320, maxHeight: 220)
        .background(model.autostart ? .ultraThinMaterial : .regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .rotation3DEffect(.degrees(motionManager.xCoordinate * 20), axis: (x: 0, y: 1, z: 0))
        .padding([.leading, .trailing])
    }
}
