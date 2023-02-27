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

struct AccountView: View {
    @ObservedObject var viewModel: AccountViewModel
        
    @ViewBuilder
    var mandateInfo: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack {
                Spacer()
                HStack {
                    viewModel.mandateStateImage
                        .foregroundStyle(.white, viewModel.mandateStateColor, viewModel.mandateStateColor)
                    Text(viewModel.mandateStateString)
                }
                .font(.title3)
                .padding()
                Spacer()
            }
            if viewModel.mandate != nil {
                Text(viewModel.mandateIDString)
                    .foregroundColor(.secondary)
                    .font(.footnote)
                    .padding([.bottom], 8)
            }
        }
        .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding([.leading, .trailing])
    }
    
    @ViewBuilder
    var mandateAction: some View {
        if let mandate = viewModel.mandate {
            if mandate.state == .pending {
                VStack {
                    HStack {
                        Button {
                            viewModel.accept(mandateId: mandate.id)
                        } label: {
                            Text("Accept")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding([.leading, .trailing])
                   
                    HStack {
                        Button {
                            viewModel.decline(mandateId: mandate.id)
                        } label: {
                            Text("Decline")
                                .fontWeight(.bold)
                                .frame(maxWidth: .infinity)
                                .padding()
                        }
                    }
                    .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding([.leading, .trailing])
              }
            }
        } else {
            HStack {
                Text("No Mandate")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(viewModel.backgroundMaterial, in: RoundedRectangle(cornerRadius: 12))
            .padding([.leading, .trailing])
        }
    }
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            VStack(spacing: 24) {
                CardView(model: viewModel, expand: true)
                mandateInfo
                mandateAction
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
        .navigationTitle(viewModel.account.name)
    }
}
