//
//  CardView.swift
//  
//
//  Created by Uwe Tilemann on 23.02.23.
//

import SwiftUI
import SnabblePay

struct AddFirstAccount: View {
    @ObservedObject var viewModel: AccountsViewModel
    @ObservedObject var motionManager = MotionManager()

    var body: some View {
        VStack(spacing: 10) {
            Text("Add yout first account now!")
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
        .frame(width: 320, height: 220)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .rotation3DEffect(.degrees(motionManager.x * 20), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardView: View {
    @ObservedObject private var model: AccountViewModel
    @ObservedObject var motionManager = MotionManager()
    @Environment(\.scenePhase) var scenePhase

    @State private var alternateSize = false

    init(account: Account) {
        self.model = AccountViewModel(account: account)
        self.model.startSession()
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
            HStack(alignment: .top) {
                qrImage
                    .padding()
                    .frame(width: alternateSize ? 160 : 80)
                    .onTapGesture {
                        withAnimation {
                            alternateSize.toggle()
                        }
                    }
                Spacer()
                Text(model.account.bank)
                    .padding([.top, .trailing])
            }
            Spacer()
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(model.account.holderName)
                    Text(model.account.iban.rawValue.replacingOccurrences(of: "*", with: "•"))
                        .font(.custom("Menlo", size: 16))
                        .fontWeight(.bold)
                }
                .onChange(of: scenePhase) { newPhase in
                    if newPhase == .active {
                        model.refresh()
                    }
                }
                .padding([.leading, .bottom], 20)
                .foregroundColor(.white)
                .shadow(radius: 2)

                Spacer()
            }
        }
        .onAppear {
            print("Account did appear")
        }
        .onChange(of: model.sessionUpdated) { newUpdate in
            withAnimation {
                alternateSize = true
            }
        }
        .frame(width: 320, height: 220)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        .rotation3DEffect(.degrees(motionManager.x * 20), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardView_Previews: PreviewProvider {
    static func loadJSON<T: Decodable>(_ string: String) -> T {
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: string.data(using: .utf8) ?? Data())
        } catch {
            fatalError("Couldn't parse \(string) as \(T.self):\n\(error)")
        }
    }
    static let mockAccount: Account = {
        let token: Account = loadJSON("""
    { "id": "4711", "name": "John Doe's Account", "holderName": "John Doe", "currencyCode": "EUR", "bank": "Commerzbank", "createdAt": 0, "mandateState": "ACCEPTED", "iban": "DE83123400070123030300" }
    """)
        return token
    }()

    static var previews: some View {
        CardView(account: Self.mockAccount)
    }
}
