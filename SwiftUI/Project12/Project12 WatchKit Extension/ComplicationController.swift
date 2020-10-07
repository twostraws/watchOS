//
//  ComplicationController.swift
//  Project12 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import ClockKit

class ComplicationController: NSObject, CLKComplicationDataSource {
        func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Project12", supportedFamilies: [.modularSmall])
        ]

        handler(descriptors)
    }

    func handleSharedComplicationDescriptors(_ complicationDescriptors: [CLKComplicationDescriptor]) {
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
