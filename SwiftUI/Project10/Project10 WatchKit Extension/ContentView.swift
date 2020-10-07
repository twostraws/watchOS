//
//  ContentView.swift
//  Project10 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import HealthKit
import SwiftUI

struct ContentView: View {
    let activities: [(name: String, type: HKWorkoutActivityType)] = [
        ("Cycling", .cycling),
        ("Running", .running),
        ("Wheelchair", .wheelchairRunPace)
    ]

    @StateObject var dataManager = DataManager()
    @State private var selectedActivity = 0

    var body: some View {
        if dataManager.state == .inactive {
            VStack {
                Picker("Choose an activity", selection: $selectedActivity) {
                    ForEach(0..<activities.count) { index in
                        Text(activities[index].name)
                    }
                }

                Button("Start Workout") {
                    guard HKHealthStore.isHealthDataAvailable() else { return }

                    dataManager.activity = activities[selectedActivity].type
                    dataManager.start()
                }
            }
        } else {
            WorkoutView(dataManager: dataManager)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
