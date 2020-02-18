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

    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let template = CLKComplicationTemplateModularSmallSimpleText()

        let currentText = UserDefaults.standard.string(forKey: "complication_number") ?? "?"
        template.textProvider = CLKSimpleTextProvider(text: currentText)

        let entry = CLKComplicationTimelineEntry(date: Date(), complicationTemplate: template)
        handler(entry)
    }

    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        let template = CLKComplicationTemplateModularSmallSimpleText()
        template.textProvider = CLKSimpleTextProvider(text: "?")
        handler(template)
    }
}
