//
//  InterfaceController.swift
//  Project8 WatchKit Extension
//
//  Created by Paul Hudson on 27/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController, WKCrownDelegate {
    @IBOutlet var numbersLabel: WKInterfaceLabel!
    @IBOutlet var safeValue: WKInterfaceSlider!
    @IBOutlet var nextButton: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!

    var currentSafeValue: Float = 50
    var targetSafeValue = 0
    var correctValues = [String]()
    var allSafeNumbers = [Int]()

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        startNewGame()
    }

    override func didAppear() {
        crownSequencer.focus()
        crownSequencer.delegate = self
    }

    func startNewGame() {
        // reset and start the timer
        timer.setDate(Date())
        timer.start()

        // create an array of random numbers from 0 to 100
        allSafeNumbers = Array(0...100)
        allSafeNumbers.shuffle()

        // reset the current value
        currentSafeValue = 50
        safeValue.setValue(50)

        // remove all their previous answers and reset the text
        correctValues.removeAll()
        numbersLabel.setText("Safe Crack")

        // pick the first number to guess
        pickNumber()
    }

    func pickNumber() {
        targetSafeValue = allSafeNumbers.removeFirst()
        print(targetSafeValue)
        numberIsWrong()
    }

    func numberIsWrong() {
        safeValue.setColor(UIColor.red)
        numbersLabel.setTextColor(UIColor.white)
        nextButton.setEnabled(false)
    }

    @IBAction func nextTapped() {
        guard Int(currentSafeValue) == targetSafeValue else { return }

        correctValues.append(String(targetSafeValue))
        numbersLabel.setText(correctValues.joined(separator: ", "))

        if correctValues.count == 4 {
            timer.stop()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                let playAgain = WKAlertAction(title: "Play again", style: .default) { self.startNewGame() }
                self.presentAlert(withTitle: "You win!", message: nil, preferredStyle: .alert, actions: [playAgain])
            }
        } else {
            pickNumber()
        }
    }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        currentSafeValue += Float(rotationalDelta)
        currentSafeValue = min(max(0, currentSafeValue), 100)
        safeValue.setValue(currentSafeValue)
        nextButton.setTitle("Enter \(Int(currentSafeValue))")

        if Int(currentSafeValue) == targetSafeValue {
            WKInterfaceDevice.current().play(.click)
            safeValue.setColor(UIColor.green)
            numbersLabel.setTextColor(UIColor.green)
            nextButton.setEnabled(true)
        } else {
            numberIsWrong()
        }
    }
}
