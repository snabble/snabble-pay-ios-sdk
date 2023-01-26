//
//  AccountPendingView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI
import BetterSafariView

struct AccountPendingView: View {
    var url: URL
    var onDismiss: (() -> Void)?
    var onValidation: ((URL) -> Void)?

    @State private var showSheet: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Button {
                showSheet.toggle()
            } label: {
                Text("Verify Account")
            }
            .sheet(
                isPresented: $showSheet,
                content: {
                    SafariView(url: url)
                }
            )
            .onOpenURL {
                onValidation?($0)
            }
        }
    }
}

struct AccountPendingView_Previews: PreviewProvider {
    static var previews: some View {
        AccountPendingView(url: URL(string: "https://www.google.de")!)
    }
}
