//
//  WorkoutView.swift
//  Project10 Watch App
//
//  Created by Paul Hudson on 09/10/2022.
//

import SwiftUI

struct WorkoutView: View {
    enum DisplayMode {
        case distance, energy, heartRate
    }

    @State private var displayMode = DisplayMode.distance
    var dataManager: DataManager
    
    var quantity: String {
        switch displayMode {
        case .distance:
            let amount = Measurement(value: dataManager.totalDistance / 1000, unit: UnitLength.kilometers)
            return amount.formatted(.measurement(width: .abbreviated, usage: .road))

        case .energy:
            let amount = Measurement(value: dataManager.totalEnergyBurned, unit: UnitEnergy.kilocalories)
            return amount.formatted(.measurement(width: .abbreviated, usage: .workout))

        case .heartRate:
            return "\(Int(dataManager.lastHeartRate)) BPM"
        }
    }
    
    var body: some View {
        VStack {
            Text(quantity)
                .font(.largeTitle)
                .onTapGesture(perform: changeDisplayMode)

            if dataManager.state == .active {
                Button("Stop", action: dataManager.pause)
            } else {
                Button("Resume", action: dataManager.resume)
                Button("End", action: dataManager.end)
            }
        }
    }
    
    func changeDisplayMode() {
        switch displayMode {
        case .distance:
            displayMode = .energy
        case .energy:
            displayMode = .heartRate
        case .heartRate:
            displayMode = .distance
        }
    }
}

#Preview {
    WorkoutView(dataManager: DataManager())
}
