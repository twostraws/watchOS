//
//  ContentView.swift
//  Project8 Watch App
//
//  Created by Paul Hudson on 09/10/2022.
//

import SwiftUI

struct ContentView: View {
    @State private var currentSafeValue = 50.0
    @State private var targetSafeValue = 0
    @State private var correctValues = [String]()
    @State private var allSafeNumbers = [Int]()

    @State private var title = "Safe Crack"
    
    @State private var currentTime = Date.now
    @State private var startTime = Date.now
    
    @State private var gameOver = false
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    
    var answerIsCorrect: Bool {
        Int(currentSafeValue) == targetSafeValue
    }

    var answerColor: Color {
        if answerIsCorrect {
            return .green
        } else {
            return .red
        }
    }
    
    var time: Int {
        let difference = currentTime.timeIntervalSince(startTime)
        return Int(difference)
    }
    
    var body: some View {
        VStack {
            Text(title)
                .font(.title2)
                .foregroundColor(answerColor)

            Slider(value: $currentSafeValue, in: 1...100, step: 1)

            Button("Enter \(Int(currentSafeValue))", action: nextTapped)
            
            Text("Time: \(time)")
        }
        .onReceive(timer) { newTime in
            currentTime = newTime
        }
        .onAppear(perform: startNewGame)
        .alert("You win!", isPresented: $gameOver) {
            Button("Play Again", action: startNewGame)
        } message: {
            Text("You took \(time) seconds.")
        }
    }
    
    func startNewGame() {
        // reset the timer
        startTime = Date.now

        // create an array of random numbers from 1 to 100
        allSafeNumbers = Array(1...100)
        allSafeNumbers.shuffle()

        // reset the current value
        currentSafeValue = 50

        // remove all their previous answers and reset the text
        correctValues.removeAll()

        // pick the first number to guess
        pickNumber()
    }
    
    func pickNumber() {
        targetSafeValue = allSafeNumbers.removeFirst()
        print(targetSafeValue)
    }
    
    func nextTapped() {
        guard answerIsCorrect else { return }

        correctValues.append(String(targetSafeValue))
        title = correctValues.joined(separator: ", ")

        if correctValues.count == 4 {
            Task {
                try await Task.sleep(until: .now +  .milliseconds(500), clock: .continuous)
                gameOver = true
            }
        } else {
            pickNumber()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
