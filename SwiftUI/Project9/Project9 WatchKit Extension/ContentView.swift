//
//  ContentView.swift
//  Project9 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import SwiftUI

//struct ContentView: View {
//    @State private var animationAmount: CGFloat = 1
//
//    var body: some View {
//        Button("Tap Me") {
////            animationAmount += 0.25
//        }
//        .buttonStyle(PlainButtonStyle())
//        .padding(50)
//        .background(Color.red)
//        .foregroundColor(.white)
//        .clipShape(Circle())
//        .overlay(
//            Circle()
//                .strokeBorder(Color.red)
//                .scaleEffect(animationAmount)
//                .opacity(Double(2 - animationAmount))
//                .animation(
//                    Animation.easeInOut(duration: 1)
//                        .repeatForever(autoreverses: false)
//                )
//        )
//        .onAppear {
//            animationAmount = 2
//        }
//    }
//}

//struct ContentView: View {
//    @State private var animationAmount: CGFloat = 1
//
//    var body: some View {
//        print(animationAmount)
//
//        return VStack {
//            Slider(value: $animationAmount.animation(
//                Animation.easeInOut(duration: 1)
//                    .repeatCount(3, autoreverses: true)
//            ), in: 1...2, step: 0.2)
//
//            Spacer()
//
//            Button("Tap Me") {
//                animationAmount = 1
//            }
//            .buttonStyle(PlainButtonStyle())
//            .padding(40)
//            .background(Color.red)
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
//        .buttonStyle(PlainButtonStyle())
//        .padding(40)
//        .background(Color.red)
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
