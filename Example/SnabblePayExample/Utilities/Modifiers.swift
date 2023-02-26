//
//  Modifiers.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 25.02.23.
//

import SwiftUI

struct SlideEffect: AnimatableModifier {
    var offset: CGFloat = 0

    var animatableData: CGFloat {
        get {
            offset
        }
        set {
            offset = newValue
        }
    }

    func body(content: Content) -> some View {
        content
            .offset(y: offset)
    }
}

struct CardStyle: ViewModifier {
    let top: Bool
    @ObservedObject var motionManager = MotionManager.shared

    init(top: Bool = true) {
        self.top = top
    }
    func body(content: Content) -> some View {
        content
            .frame(minWidth: 320, minHeight: 220, maxHeight: 220)
            .background(self.top ? .ultraThinMaterial : .ultraThickMaterial, in: RoundedRectangle(cornerRadius: 12))
            .rotation3DEffect(.degrees(motionManager.xCoordinate * 20), axis: (x: 0, y: 1, z: 0))
            .padding([.leading, .trailing])
            .shadow(radius: 4, y: 2)
    }
}

extension View {
    func cardStyle(top: Bool = true) -> some View {
        modifier(CardStyle(top: top))
    }
}
