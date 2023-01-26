//
//  AccountErrorView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-01-24.
//

import SwiftUI

struct AccountErrorView: View {
    var message: String
    var body: some View {
        VStack(spacing: 8) {
            Text("Account Error View")
            Text(message)
        }
    }
}

struct AccountErrorView_Previews: PreviewProvider {
    static var previews: some View {
        AccountErrorView(message: "Error message")
    }
}
