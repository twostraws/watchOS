//
//  ContentView.swift
//  Project5 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    let colors = [
        "Red": Color(red: 1, green: 0, blue: 0),
        "Green": Color(red: 0, green: 0.5, blue: 0),
        "Blue": Color(red: 0, green: 0, blue: 1),
        "Orange": Color(red: 1, green: 0.6, blue: 0),
        "Purple": Color(red: 0.5, green: 0, blue: 0.5),
        "Black": Color.black
    ]

    @State private var colorKeys = ["Red", "Green", "Blue", "Orange", "Purple", "Black"]

    @State private var correctAnswer = 0
    @State private var currentLevel = 0
    @State private var gameOver = false
    @State private var title = ""

    @State private var startTime = Date()

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                text(for: 0)
                text(for: 1)
            }

            HStack(spacing: 10) {
                text(for: 2)
                text(for: 3)
            }
        }
        .navigationTitle(title)
        .onAppear(perform: startNewGame)
        .sheet(isPresented: $gameOver) {
            VStack {
                Text("You win!")
                    .font(.largeTitle)
                Text("You finished in \(Int(Date().timeIntervalSince(startTime))) seconds.")
                Button("Play Again", action: startNewGame)
            }
        }
    }

    func text(for index: Int) -> some View {
        let title: String

        if index == correctAnswer {
            title = colorKeys[colorKeys.count - 1]
        } else {
            title = colorKeys[index]
        }

        return Text(title)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colors[colorKeys[index]])
            .cornerRadius(20)
            .onTapGesture {
                tapped(index)
            }
    }

    func createLevel() {
        title = "Level \(currentLevel)/10"

        correctAnswer = Int.random(in: 0...3)
        colorKeys.shuffle()
    }

    func startNewGame() {
        setPlayReminder()
        
        currentLevel = 1
        gameOver = false
        createLevel()
        startTime = Date()
    }

    func tapped(_ index: Int) {
        if index == correctAnswer {
            currentLevel += 1
        } else {
            if currentLevel > 1 {
                currentLevel -= 1
            }
        }

        createLevel()
    }

    func registerCategories() {
        let center = UNUserNotificationCenter.current()

        let play = UNNotificationAction(identifier: "play", title: "Play Now", options: .foreground)
        let category = UNNotificationCategory(identifier: "play_reminder", actions: [play], intentIdentifiers: [])

        center.setNotificationCategories([category])
    }


    func setPlayReminder() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .sound]) { success, error in
            if success {
                registerCategories()

                center.removeAllPendingNotificationRequests()
                createNotification()
            }
        }
    }

    func createNotification() {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "We miss you!"
        content.body = "Come back and play the game some more!"
        content.categoryIdentifier = "play_reminder"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
