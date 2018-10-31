//
//  InterfaceController.swift
//  Project10 WatchKit Extension
//
//  Created by Paul Hudson on 29/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit

class InterfaceController: WKInterfaceController {
    @IBOutlet var activityType: WKInterfacePicker!

    let activities: [(String, HKWorkoutActivityType)] = [("Cycling", .cycling), ("Running", .running), ("Swimming", .swimming), ("Wheelchair", .wheelchairRunPace)]
    var selectedActivity = HKWorkoutActivityType.cycling

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        var items = [WKPickerItem]()

        for activity in activities {
            let item = WKPickerItem()
            item.title = activity.0
            items.append(item)
        }

        activityType.setItems(items)
    }
    
    @IBAction func activityPickerChanged(_ value: Int) {
        selectedActivity = activities[value].1
    }

    @IBAction func startWorkoutTapped() {
        guard HKHealthStore.isHealthDataAvailable() else { return }

        WKInterfaceController.reloadRootPageControllers(withNames: ["WorkoutInterfaceController"], contexts: [selectedActivity], orientation: .horizontal, pageIndex: 0)
    }
}

