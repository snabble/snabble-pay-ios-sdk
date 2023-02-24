//
//  BackgroundView.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 24.02.23.
//

import SwiftUI

struct BackgroundView: View {
    @ObservedObject var motionManager = MotionManager.shared
    
    var body: some View {
        GeometryReader { geom in
            Image("Background")
                .resizable()
                .scaledToFit()
                .offset(x: -90, y: -120)
                .frame(width: geom.size.width + 180, height: geom.size.height + 180)
                .modifier(ParallaxMotionModifier(manager: motionManager, magnitude: 20))
        }
    }
}

struct BackgroundView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundView()
    }
}
