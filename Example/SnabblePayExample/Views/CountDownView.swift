//
//  CountDownView.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 04.04.23.
//

import SwiftUI

struct CountDownView: View {
    let from: Date
    let to: Date
    let height: CGFloat
    
    init(from: Date, to: Date, height: CGFloat = 2.0) {
        self.from = from
        self.to = to
        self.height = height
    }
    
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 20)) { _ in
            Canvas { context, size in
                let interval = to.timeIntervalSinceReferenceDate - from.timeIntervalSinceReferenceDate
                let width = size.width / interval * to.timeIntervalSinceNow
                
                let bgRect = Capsule().path(in: CGRect(x: 0, y: (size.height / 2) / 2, width: size.width, height: size.height / 2))
                context.fill(bgRect, with: .color(.secondary))

                let fdRect = Capsule().path(in: CGRect(x: 0, y: 0, width: width, height: size.height))
                context.fill(fdRect, with: .color(.primary))
            }
        }
        .frame(height: height)
    }
}
