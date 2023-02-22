//
//  AccountView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2023-02-22.
//

import SwiftUI
import SnabblePay

struct AccountView: View {
    let account: Account

    var body: some View {
        Text(account.holderName)
    }
}
