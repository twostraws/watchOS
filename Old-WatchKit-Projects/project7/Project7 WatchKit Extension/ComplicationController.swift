//
//  ComplicationController.swift
//  Project7 WatchKit Extension
//
//  Created by Paul Hudson on 24/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import ClockKit


class ComplicationController: NSObject, CLKComplicationDataSource {
    let positiveAnswers: Set<String> = ["It is certain", "It is decidedly so", "Without a doubt", "Yes definitely", "As I see it, yes", "Most likely", "Outlook good", "Yes", "Signs point to yes"]
    let uncertainAnswers: Set<String> = ["Reply hazy, try again", "Ask again later", "Better not tell you now", "Cannot predict now", "Concentrate and ask again"]
    let negativeAnswers: Set<String> = ["Don't count on it", "My reply is no", "My sources say no", "Outlook not so good", "Very doubtful"]
    var allAnswers = [String]()

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "complication", displayName: "Project7", supportedFamilies: [.modularSmall, .modularLarge])
            // Multiple complication support can be added here with more descriptors
        ]

        // Call the handler with the currently supported complication descriptors
        handler(descriptors)
    }

    func getTimelineEndDate(for complication: CLKComplication, withHandler handler: @escaping (Date?) -> Void) {
        let endDate = Date().addingTimeInterval(86400)
        handler(endDate)
    }
    
    func getPrivacyBehavior(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationPrivacyBehavior) -> Void) {
        handler(.showOnLockScreen)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        allAnswers = Array(positiveAnswers) + Array(uncertainAnswers) + Array(negativeAnswers)

        getTimelineEntries(for: complication, after: Date(), limit: 1) {
            handler($0?.first)
        }
    }

    func getTimelineEntries(for complication: CLKComplication, after date: Date, limit: Int, withHandler handler: @escaping ([CLKComplicationTimelineEntry]?) -> Void) {
        var entries = [CLKComplicationTimelineEntry]()

        for i in 0 ..< limit {
            let predictionDate = date.addingTimeInterval(Double(60 * 5 * i))
            let predictionTemplate = template(for: complication.family, date: predictionDate)
            let entry = CLKComplicationTimelineEntry(date: predictionDate, complicationTemplate: predictionTemplate)
            entries.append(entry)
        }

        handler(entries)
    }
    
    // MARK: - Placeholder Templates
    
    func getLocalizableSampleTemplate(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTemplate?) -> Void) {
        // This method will be called once per supported complication, and the results will be cached
        switch complication.family {
        case .modularLarge:
            let headerText = CLKSimpleTextProvider(text: "Magic 8-Ball", shortText: "8-Ball")
            let body1Text = CLKSimpleTextProvider(text: "Your Prediction", shortText: "Prediction")

            let template = CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: headerText, body1TextProvider: body1Text)

            handler(template)
        case .modularSmall:
            let text = CLKSimpleTextProvider(text: "🎱")
            let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: text)
            handler(template)
        default:
            handler(nil)
        }
    }

    func template(for family: CLKComplicationFamily, date: Date) -> CLKComplicationTemplate {
        let predictionNumber = Int(date.timeIntervalSince1970) % allAnswers.count
        let prediction = allAnswers[predictionNumber]

        switch family {
        case .modularLarge:
            let headerText = CLKSimpleTextProvider(text: "Magic 8-Ball")
            let body1Text = CLKSimpleTextProvider(text: prediction)
            let template = CLKComplicationTemplateModularLargeStandardBody(headerTextProvider: headerText, body1TextProvider: body1Text)

            return template

        default:
            let text: CLKSimpleTextProvider

            if positiveAnswers.contains(prediction) {
                text = CLKSimpleTextProvider(text: "😀")
            } else if uncertainAnswers.contains(prediction) {
                text = CLKSimpleTextProvider(text: "🤔")
            } else {
                text = CLKSimpleTextProvider(text: "😧")
            }


            let template = CLKComplicationTemplateModularSmallSimpleText(textProvider: text)

            return template
        }
    }
}
