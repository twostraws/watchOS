//
//  ContentView.swift
//  Project11 Watch App
//
//  Created by Paul Hudson on 09/10/2022.
//

import SpriteKit
import SwiftUI

struct ContentView: View {
    @State private var rotation = 0.0
    @State private var title = "Woo"
    
    @State private var scene: GameScene = {
        let scene = GameScene()
        scene.size = CGSize(width: 300, height: 400)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.scaleMode = .resizeFill
        
        return scene
    }()
    
    var body: some View {
        NavigationStack {
            SpriteView(scene: scene)
                .ignoresSafeArea()
                .focusable()
                .digitalCrownRotation($rotation, from: -1_000_000_000, through: 1_000_000_000, sensitivity: .low, isContinuous: true)
                .onChange(of: rotation) {
                    scene.rotate(to: rotation)
                }
                .onTapGesture(perform: scene.reset)
                .navigationTitle("Score \(scene.score)")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
