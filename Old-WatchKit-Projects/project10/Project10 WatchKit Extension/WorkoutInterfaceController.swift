//
//  WorkoutInterfaceController.swift
//  Project10
//
//  Created by Paul Hudson on 29/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit

enum DisplayMode {
    case distance, energy, heartRate
}

class WorkoutInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    @IBOutlet var quantityLabel: WKInterfaceLabel!
    @IBOutlet var unitLabel: WKInterfaceLabel!

    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var resumeButton: WKInterfaceButton!
    @IBOutlet var endButton: WKInterfaceButton!

    var healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    var workoutBuilder: HKLiveWorkoutBuilder?

    var distanceType = HKQuantityTypeIdentifier.distanceCycling
    var displayMode = DisplayMode.distance
    var workoutIsActive = true

    var totalEnergyBurned = 0.0
    var totalDistance = 0.0
    var lastHeartRate = 0.0
    let countPerMinuteUnit = HKUnit(from: "count/min")

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        guard let activity = context as? HKWorkoutActivityType else { return }

        switch activity {
        case .cycling:
            distanceType = .distanceCycling
        case .running:
            distanceType = .distanceWalkingRunning
        case .swimming:
            distanceType = .distanceSwimming
        default:
            distanceType = .distanceWheelchair
        }

        let sampleTypes: Set<HKSampleType> = [
            .workoutType(),
            .quantityType(forIdentifier: .heartRate)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .distanceCycling)!,
            .quantityType(forIdentifier: .distanceWalkingRunning)!,
            .quantityType(forIdentifier: .distanceSwimming)!,
            .quantityType(forIdentifier: .distanceWheelchair)!
        ]

        healthStore.requestAuthorization(toShare: sampleTypes, read: sampleTypes) { success, error in
            if success {
                self.startWorkout(type: activity)
            }
        }
    }

    @IBAction func changeDisplayMode() {
        switch displayMode {
        case .distance:
            displayMode = .energy
        case .energy:
            displayMode = .heartRate
        case .heartRate:
            displayMode = .distance
        }

        updateLabels()
    }

    func startWorkout(type: HKWorkoutActivityType) {
        let config = HKWorkoutConfiguration()
        config.activityType = type
        config.locationType = .outdoor

        do {
            workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
            workoutBuilder = workoutSession?.associatedWorkoutBuilder()

            workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

            workoutSession?.delegate = self
            workoutBuilder?.delegate = self

            workoutSession?.startActivity(with: Date())
            workoutBuilder?.beginCollection(withStart: Date()) { (success, error) in
                guard success else {
                    // Handle errors.
                    return
                }

                // Indicate that the session has started.
            }
        } catch {
            // Handle failure here.
            return
        }
    }

    @IBAction func stopWorkout() {
        guard let workoutSession = workoutSession else { return }

        stopButton.setHidden(true)
        resumeButton.setHidden(false)
        endButton.setHidden(false)

        workoutSession.pause()
    }

    @IBAction func resumeWorkout() {
        guard let workoutSession = workoutSession else { return }

        stopButton.setHidden(false)
        resumeButton.setHidden(true)
        endButton.setHidden(true)

        workoutSession.resume()
    }

    @IBAction func endWorkout() {
        guard let workoutSession = workoutSession else { return }
        workoutSession.end()
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            if fromState == .notStarted {
                if distanceType == .distanceSwimming {
                    WKInterfaceDevice.current().enableWaterLock()
                }
            } else {
                workoutIsActive = true
            }

        case .paused:
            workoutIsActive = false

        case .ended:
            workoutIsActive = false
            save(workoutSession)

        default:
            break
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }

            // Calculate statistics for the type.
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { continue }

            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
                let roundedValue = Double(round(1 * value!) / 1)
                lastHeartRate = roundedValue

            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                let value = statistics.sumQuantity()?.doubleValue(for: .kilocalorie())
                totalEnergyBurned = Double(round(1 * value!) / 1)

            default:
                let value = statistics.sumQuantity()?.doubleValue(for: .meter())
                totalDistance = Double(round(1 * value!) / 1)
            }

            DispatchQueue.main.async(execute: updateLabels)
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func updateLabels() {
        switch displayMode {
        case .distance:
            let kilometers = totalDistance / 1000
            let formattedKilometers = String(format: "%.2f", kilometers)
            quantityLabel.setText(formattedKilometers)
            unitLabel.setText("KILOMETERS")

        case .energy:
            let formatterKilocalories = String(format: "%.0f", totalEnergyBurned)
            quantityLabel.setText(formatterKilocalories)
            unitLabel.setText("CALORIES")

        case .heartRate:
            let heartRate = String(Int(lastHeartRate))
            quantityLabel.setText(heartRate)
            unitLabel.setText("BEATS / MINUTE")
        }
    }

    func save(_ workoutSession: HKWorkoutSession) {
        workoutBuilder?.endCollection(withEnd: Date()) { [weak self] success, error in
            guard success else {
                // Handle errors.
                return
            }

            self?.workoutBuilder?.finishWorkout { (workout, error) in
                guard workout != nil else {
                    // Handle errors.
                    return
                }

                DispatchQueue.main.async() {
                    WKInterfaceController.reloadRootPageControllers(withNames: ["InterfaceController"], contexts: nil, orientation: .horizontal, pageIndex: 0)
                }
            }
        }
    }
}
