//
//  InterfaceController.swift
//  Project6 WatchKit Extension
//
//  Created by Paul Hudson on 24/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import Foundation
import WatchKit

class InterfaceController: WKInterfaceController {    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        // Configure interface objects here.
    }

    @IBAction func dictationTapped() {
        presentTextInputController(withSuggestions: nil, allowedInputMode: .plain) { result in
            guard let result = result?.first as? String else { return }
            print(result)
        }
    }

    @IBAction func multiInputTapped() {
        presentTextInputController(withSuggestions: ["Hacking with Swift", "Hacking with macOS", "Server-Side Swift"], allowedInputMode: .allowEmoji) { result in
            guard let result = result?.first as? String else { return }
            print(result)
        }
    }

    @IBAction func recordingTapped() {
        let saveURL = getDocumentsDirectory().appendingPathComponent("recording.wav")

        if FileManager.default.fileExists(atPath: saveURL.path) {
            let options = [WKMediaPlayerControllerOptionsAutoplayKey: "true"]

            presentMediaPlayerController(with: saveURL, options: options) { didPlayToEnd, endTime, error in
                // do nothing here
            }
        } else {
            let options: [String: Any] =
                [WKAudioRecorderControllerOptionsMaximumDurationKey : 60,
                 WKAudioRecorderControllerOptionsActionTitleKey: "Done"]

            presentAudioRecorderController(withOutputURL: saveURL, preset: .narrowBandSpeech, options: options) { success, error in
                if success {
                    print("Saved successfully!")
                } else {
                    print(error?.localizedDescription ?? "Unknown error")
                }
            }
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
