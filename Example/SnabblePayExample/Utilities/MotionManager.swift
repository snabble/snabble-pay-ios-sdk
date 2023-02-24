//
//  MotionManager.swift
//  SnabblePayExample
//
//  Created by Uwe Tilemann on 23.02.23.
//
import SwiftUI
import CoreMotion

struct ParallaxMotionModifier: ViewModifier {
    @ObservedObject var manager: MotionManager
    var magnitude: Double
    
    func body(content: Content) -> some View {
        content
            .offset(x: CGFloat(manager.x * magnitude), y: CGFloat(manager.y * magnitude))
    }
}

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    private let manager: CMMotionManager
    let formatter: NumberFormatter
    
    @Published var x = 0.0
    @Published var y = 0.0

    init() {
        self.formatter = NumberFormatter()
        self.formatter.maximumFractionDigits = 2
        
        self.manager = CMMotionManager()
        self.manager.deviceMotionUpdateInterval = 1 / 30
        self.manager.startDeviceMotionUpdates(to: .main) { [weak self] (data, error) in
            guard let motion = data?.attitude else { return }
            
            self?.x = motion.roll
            self?.y = motion.pitch
        }
    }
}
