//
//  ContentView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2022-12-08.
//

import SwiftUI
import SnabblePayCore
import SnabblePayNetwork

struct ContentView: View {
    var networkManager: NetworkManager
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello World!")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(networkManager: .init(config: .init(customUrlScheme: "snabble-pay", apiKey: "12345")))
    }
}
