//
//  ContentView.swift
//  SnabblePayExample
//
//  Created by Andreas Osberghaus on 2022-12-08.
//

import SwiftUI
import SnabblePayCore

struct ContentView: View {
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
        ContentView()
    }
}
