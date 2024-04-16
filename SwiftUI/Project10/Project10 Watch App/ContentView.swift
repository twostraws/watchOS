//
//  ContentView.swift
//  Project10 Watch App
//
//  Created by Paul Hudson on 09/10/2022.
//

import HealthKit
import SwiftUI

struct ContentView: View {
    let activities: [(name: String, type: HKWorkoutActivityType)] = [
        ("Cycling", .cycling),
        ("Running", .running),
        ("Wheelchair", .wheelchairRunPace)
    ]

    @State private var selectedActivity = 0
    
    @State private var dataManager = DataManager()
    
    var body: some View {
        if dataManager.state == .inactive {
            VStack {
                Picker("Choose an activity", selection: $selectedActivity) {
                    ForEach(0..<activities.count, id: \.self) { index in
                        Text(activities[index].name)
                    }
                }

                Button("Start Workout") {
                    guard HKHealthStore.isHealthDataAvailable() else { return }

                    Task {
                        dataManager.activity = activities[selectedActivity].type

                        do {
                            try await dataManager.start()
                        } catch {
                            // handle errors here
                        }
                    }
                }
            }
        } else {
            WorkoutView(dataManager: dataManager)
        }
    }
}

#Preview {
    ContentView()
}
