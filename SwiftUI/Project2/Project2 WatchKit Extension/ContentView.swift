//
//  ContentView.swift
//  Project2 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import SwiftUI

struct ContentView: View {
    @State private var gameOver = false

    @State private var question = "rock"
    @State private var title = "Win!"

    @State private var shouldWin = true
    @State private var level = 1

    @State private var currentTime = Date()
    @State private var startTime = Date()

    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()

    let moves = ["rock", "paper", "scissors"]

    var time: String {
        let difference = currentTime.timeIntervalSince(startTime)
        return String(Int(difference))
    }

    var body: some View {
        VStack {
            if gameOver {
                Text("You win!")
                    .font(.largeTitle)
                Text("Your time: \(time) seconds")

                Button("Play Again") {
                    startTime = Date()
                    gameOver = false
                    level = 1
                    newLevel()
                }
                .buttonStyle(BorderedButtonStyle(tint: .green))
            } else {
                Image(question)
                    .resizable()
                    .scaledToFit()

                Divider()
                    .padding(.vertical)

                HStack {
                    ForEach(moves, id: \.self) { type in
                        Button {
                            select(move: type)
                        } label: {
                            Image(type)
                                .resizable()
                                .scaledToFit()
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                HStack {
                    Text("\(level)/20")
                    Spacer()
                    Text("Time: \(time)")
                }
                .padding([.top, .horizontal])
            }
        }
        .navigationTitle(title)
        .onAppear(perform: newLevel)
        .onReceive(timer) { newTime in
            guard gameOver == false else { return }
            currentTime = newTime
        }
    }

    func select(move: String) {
        let solutions = [
            "rock": (win: "paper", lose: "scissors"),
            "paper": (win: "scissors", lose: "rock"),
            "scissors": (win: "rock", lose: "paper")
        ]

        guard let answer = solutions[question] else {
            fatalError("Unknown question: \(question)")
        }

        let isCorrect: Bool

        if shouldWin {
            isCorrect = move == answer.win
        } else {
            isCorrect = move == answer.lose
        }

        if isCorrect {
            level += 1
        } else {
            level -= 1
            if level < 1 { level = 1 }
        }

        newLevel()
    }

    func newLevel() {
        if level == 21 {
            gameOver = true
            return
        }

        if Bool.random() {
            title = "Win!"
            shouldWin = true
        } else {
            title = "Lose!"
            shouldWin = false
        }

        question = moves.randomElement()!
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
