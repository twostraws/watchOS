//
//  DataManager.swift
//  Project10 Watch App
//
//  Created by Paul Hudson on 09/10/2022.
//

import Foundation
import HealthKit

@Observable
class DataManager: NSObject, HKWorkoutSessionDelegate, HKLiveWorkoutBuilderDelegate {
    enum WorkoutState {
        case inactive, active, paused
    }

    var healthStore = HKHealthStore()
    var workoutSession: HKWorkoutSession?
    var workoutBuilder: HKLiveWorkoutBuilder?

    var activity = HKWorkoutActivityType.cycling
    
    var state = WorkoutState.inactive
    
    var totalEnergyBurned = 0.0
    var totalDistance = 0.0
    var lastHeartRate = 0.0

    func start() async throws {
        totalEnergyBurned = 0
        totalDistance = 0
        lastHeartRate = 0

        let sampleTypes: Set<HKSampleType> = [
            .workoutType(),
            .quantityType(forIdentifier: .heartRate)!,
            .quantityType(forIdentifier: .activeEnergyBurned)!,
            .quantityType(forIdentifier: .distanceCycling)!,
            .quantityType(forIdentifier: .distanceWalkingRunning)!,
            .quantityType(forIdentifier: .distanceWheelchair)!
        ]

        try await healthStore.requestAuthorization(toShare: sampleTypes, read: sampleTypes)
        try await self.beginWorkout()
    }

    @MainActor
    private func beginWorkout() async throws {
        let config = HKWorkoutConfiguration()
        config.activityType = activity
        config.locationType = .outdoor
        
        workoutSession = try HKWorkoutSession(healthStore: healthStore, configuration: config)
        workoutBuilder = workoutSession?.associatedWorkoutBuilder()
        workoutBuilder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: config)

        workoutSession?.delegate = self
        workoutBuilder?.delegate = self

        workoutSession?.startActivity(with: .now)
        try await workoutBuilder?.beginCollection(at: .now)

        state = .active
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            switch toState {
            case .running:
                self.state = .active

            case .paused:
                self.state = .paused

            case .ended:
                try await self.save()

            default:
                break
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else { continue }
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { continue }

            Task { @MainActor in
                switch statistics.quantityType {
                case HKQuantityType.quantityType(forIdentifier: .heartRate):
                    let heartRateUnit = HKUnit.count().unitDivided(by: .minute())
                    self.lastHeartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0
                    
                case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                    let value = statistics.sumQuantity()?.doubleValue(for: .kilocalorie()) ?? 0
                    self.totalEnergyBurned = value
                    
                default:
                    let value = statistics.sumQuantity()?.doubleValue(for: .meter())
                    self.totalDistance = value ?? 0
                }

            }
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }
    
    func pause() {
        workoutSession?.pause()
    }

    func resume() {
        workoutSession?.resume()
    }

    func end() {
        workoutSession?.end()
    }

    @MainActor
    private func save() async throws {
        try await workoutBuilder?.endCollection(at: .now)
        try await workoutBuilder?.finishWorkout()

        state = .inactive
    }
}

