//
//  ComplicationController.swift
//  Project12 WatchKit Extension
//
//  Created by Paul Hudson on 03/04/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
    func getSupportedTimeTravelDirections(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimeTravelDirections) -> Void) {
        handler([])
    }

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Project7", supportedFamilies: [.modularSmall])
            // Multiple complication support can be added here with more descriptors
        ]

        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let currentText = UserDefaults.standard.string(forKey: "complication_number") ?? "?"
        let text = CLKSimpleTextProvider(text: currentText)
        let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: text)

        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let text = CLKSimpleTextProvider(text: "?")
        let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: text)

        handler(template)
    }
}
