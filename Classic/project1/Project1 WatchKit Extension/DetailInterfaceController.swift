//
//  DetailInterfaceController.swift
//  Project1
//
//  Created by Paul Hudson on 20/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import WatchKit
import Foundation


class DetailInterfaceController: WKInterfaceController {
    @IBOutlet var textLabel: WKInterfaceLabel!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        if let contextDictionary = context as? [String: String] {
            textLabel.setText(contextDictionary["note"] ?? "")

            let index = contextDictionary["index"] ?? "1"
            setTitle("Note \(index)")
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
