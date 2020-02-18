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

class WorkoutInterfaceController: WKInterfaceController, HKWorkoutSessionDelegate {
    @IBOutlet var quantityLabel: WKInterfaceLabel!
    @IBOutlet var unitLabel: WKInterfaceLabel!

    @IBOutlet var stopButton: WKInterfaceButton!
    @IBOutlet var resumeButton: WKInterfaceButton!
    @IBOutlet var endButton: WKInterfaceButton!

    var healthStore: HKHealthStore?
    var workoutSession: HKWorkoutSession?

    var distanceType = HKQuantityTypeIdentifier.distanceCycling
    var displayMode = DisplayMode.distance    

    var workoutIsActive = true
    var workoutStartDate = Date()
    var workoutEndDate = Date()
    var activeDataQueries = [HKQuery]()

    var totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: 0)
    var totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: 0)
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
            HKSampleType.quantityType(forIdentifier: .heartRate)!,
            HKSampleType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKSampleType.quantityType(forIdentifier: .distanceCycling)!,
            HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKSampleType.quantityType(forIdentifier: .distanceSwimming)!,
            HKSampleType.quantityType(forIdentifier: .distanceWheelchair)!
        ]

        healthStore = HKHealthStore()
        healthStore?.requestAuthorization(toShare: sampleTypes, read: sampleTypes) { success, error in
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

        if let session = try? HKWorkoutSession(configuration: config) {
            workoutSession = session
            healthStore?.start(session)
            workoutStartDate = Date()
            session.delegate = self
        }
    }

    func startQueries() {
        startQuery(quantityTypeIdentifier: distanceType)
        startQuery(quantityTypeIdentifier: .activeEnergyBurned)
        startQuery(quantityTypeIdentifier: .heartRate)
        WKInterfaceDevice.current().play(.start)
    }

    func startQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        let datePredicate = HKQuery.predicateForSamples(withStart: workoutStartDate, end: nil, options: .strictStartDate)
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        let queryPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [datePredicate, devicePredicate])

        let updateHandler = { (query: HKAnchoredObjectQuery, samples: [HKSample]?, deletedObjects: [HKDeletedObject]?, queryAnchor: HKQueryAnchor?, error: Error?) in
            guard let samples = samples as? [HKQuantitySample] else { return }
            self.process(samples, type: quantityTypeIdentifier)
        }

        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: queryPredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        query.updateHandler = updateHandler
        healthStore?.execute(query)

        activeDataQueries.append(query)
    }

    @IBAction func stopWorkout() {
        guard let workoutSession = workoutSession else { return }

        stopButton.setHidden(true)
        resumeButton.setHidden(false)
        endButton.setHidden(false)

        healthStore?.pause(workoutSession)
    }

    @IBAction func resumeWorkout() {
        guard let workoutSession = workoutSession else { return }

        stopButton.setHidden(false)
        resumeButton.setHidden(true)
        endButton.setHidden(true)

        healthStore?.resumeWorkoutSession(workoutSession)
    }

    @IBAction func endWorkout() {
        guard let workoutSession = workoutSession else { return }
        workoutEndDate = Date()

        healthStore?.end(workoutSession)
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        switch toState {
        case .running:
            if fromState == .notStarted {
                startQueries()

                if distanceType == .distanceSwimming {
                    WKExtension.shared().enableWaterLock()
                }
            } else {
                workoutIsActive = true
            }

        case .paused:
            workoutIsActive = false

        case .ended:
            workoutIsActive = false

            cleanUpQueries()
            save(workoutSession)

        default:
            break
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
    }

    func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        // ignore updates while we are paused
        guard workoutIsActive else { return }

        for sample in samples {
            if type == .activeEnergyBurned {
                let newEnergy = sample.quantity.doubleValue(for: HKUnit.kilocalorie())
                let currentEnergy = totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
                totalEnergyBurned = HKQuantity(unit: HKUnit.kilocalorie(), doubleValue: currentEnergy + newEnergy)
                print("Total energy: \(totalEnergyBurned)")
            } else if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: countPerMinuteUnit)
                print("Last heart rate: \(lastHeartRate)")
            } else if type == distanceType {
                let newDistance = sample.quantity.doubleValue(for: HKUnit.meter())
                let currentDistance = totalDistance.doubleValue(for: HKUnit.meter())
                totalDistance = HKQuantity(unit: HKUnit.meter(), doubleValue: currentDistance + newDistance)
                print("Total distance: \(totalDistance)")
            }
        }

        updateLabels()
    }

    func updateLabels() {
        switch displayMode {
        case .distance:
            let meters = totalDistance.doubleValue(for: HKUnit.meter())
            let kilometers = meters / 1000
            let formattedKilometers = String(format: "%.2f", kilometers)

            quantityLabel.setText(formattedKilometers)
            unitLabel.setText("KILOMETERS")

        case .energy:
            let kilocalories = totalEnergyBurned.doubleValue(for: HKUnit.kilocalorie())
            let formatterKilocalories = String(format: "%.0f", kilocalories)
            quantityLabel.setText(formatterKilocalories)
            unitLabel.setText("CALORIES")

        case .heartRate:
            let heartRate = String(Int(lastHeartRate))
            quantityLabel.setText(heartRate)
            unitLabel.setText("BEATS / MINUTE")
        }
    }

    func cleanUpQueries() {
        for query in activeDataQueries {
            healthStore?.stop(query)
        }

        activeDataQueries.removeAll()
    }

    func save(_ workoutSession: HKWorkoutSession) {
        let config = workoutSession.workoutConfiguration
        let workout = HKWorkout(activityType: config.activityType, start: workoutStartDate, end: workoutEndDate, workoutEvents: nil, totalEnergyBurned: totalEnergyBurned, totalDistance: totalDistance, metadata: [HKMetadataKeyIndoorWorkout: false])

        healthStore?.save(workout) { (success, error) in
            if success {
                DispatchQueue.main.async {
                    WKInterfaceController.reloadRootPageControllers(withNames: ["InterfaceController"], contexts: nil, orientation: .horizontal, pageIndex: 0)
                }
            }
        }
    }
}
