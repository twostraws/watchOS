//
//  ContentView.swift
//  Project9 Watch App
//
//  Created by Paul Hudson on 09/10/2022.
//

import SwiftUI

//struct ContentView: View {
//    @State private var animationAmount = 1.0
//
//    var body: some View {
//        Button("Tap Me") {
//            animationAmount += 0.25
//        }
//        .buttonStyle(.plain)
//        .padding(50)
//        .background(.red)
//        .foregroundColor(.white)
//        .clipShape(Circle())
//        .scaleEffect(animationAmount)
//        .blur(radius: (animationAmount - 1) * 3)
//        .animation(.default, value: animationAmount)
//    }
//}

//struct ContentView: View {
//    @State private var animationAmount = 1.0
//
//    var body: some View {
//        Button("Tap Me") {
//            // animationAmount += 0.25
//        }
//        .buttonStyle(.plain)
//        .padding(50)
//        .background(.red)
//        .foregroundColor(.white)
//        .clipShape(Circle())
//        .overlay(
//            Circle()
//                .strokeBorder(Color.red)
//                .scaleEffect(animationAmount)
//                .opacity(2 - animationAmount)
//                .animation(.easeOut(duration: 1).repeatForever(autoreverses: false), value: animationAmount)
//        )
//        .onAppear {
//            animationAmount = 2
//        }
//    }
//}

//struct ContentView: View {
//    @State private var animationAmount = 1.0
//
//    var body: some View {
//        VStack {
//            Slider(value: $animationAmount.animation(
//                .easeInOut(duration: 1)
//                    .repeatCount(3, autoreverses: true)
//            ), in: 1...2, step: 0.2)
//
//            Spacer()
//
//            Button("Tap Me") {
//                animationAmount = 1
//            }
//            .buttonStyle(.plain)
//            .padding(40)
//            .background(.red)
//            .foregroundColor(.white)
//            .clipShape(Circle())
//            .scaleEffect(animationAmount)
//        }
//    }
//}

//struct ContentView: View {
//    @State private var animationAmount = 0.0
//
//    var body: some View {
//        Button("Tap Me") {
//            withAnimation(.interpolatingSpring(stiffness: 5, damping: 1)) {
//                animationAmount += 360
//            }
//        }
//        .buttonStyle(.plain)
//        .padding(40)
//        .background(.red)
//        .foregroundColor(.white)
//        .clipShape(Circle())
//        .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
//    }
//}

struct ContentView: View {
    @State private var isShowingRed = false
    
    var body: some View {
        VStack {
            Button("Tap Me") {
                withAnimation {
                    isShowingRed.toggle()
                }
            }

            if isShowingRed {
                Color.red
                    .frame(width: 100, height: 100)
                    .transition(.asymmetric(insertion: .scale, removal: .opacity))
            }
        }
    }
}

#Preview {
    ContentView()
}
