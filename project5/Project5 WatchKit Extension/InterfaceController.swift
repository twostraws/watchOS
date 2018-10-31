//
//  InterfaceController.swift
//  Project5 WatchKit Extension
//
//  Created by Paul Hudson on 23/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import WatchKit
import Foundation
import UserNotifications


class InterfaceController: WKInterfaceController {
    @IBOutlet var tlButton: WKInterfaceButton!
    @IBOutlet var trButton: WKInterfaceButton!
    @IBOutlet var blButton: WKInterfaceButton!
    @IBOutlet var brButton: WKInterfaceButton!

    var buttons = [WKInterfaceButton]()
    var startTime = Date()

    var colors = [
        "Red": UIColor.red,
        "Green": UIColor(red: 0, green: 0.5, blue: 0, alpha: 1),
        "Blue": UIColor.blue,
        "Orange": UIColor.orange,
        "Purple": UIColor.purple,
        "Black": UIColor.black
    ]

    var currentLevel = 0

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        buttons += [tlButton, trButton, blButton, brButton]
        startNewGame()
    }

    @IBAction func startNewGame() {
        startTime = Date()
        currentLevel = 0
        levelUp()
    }

    func levelUp() {
        currentLevel += 1

        if currentLevel == 10 {
            let playAgain = WKAlertAction(title: "Play Again", style: .default) {
                self.startNewGame()
            }

            let timePassed = Date().timeIntervalSince(startTime)
            presentAlert(withTitle: "You win!", message: "You finished in \(Int(timePassed)) seconds.", preferredStyle: .alert, actions: [playAgain])
            return
        }

        var colorKeys = Array(colors.keys)
        colorKeys.shuffle()
        buttons.shuffle()

        for (index, button) in buttons.enumerated() {
            button.setBackgroundColor(colors[colorKeys[index]])
            button.setEnabled(true)

            if index == 0 {
                button.setTitle(colorKeys[colorKeys.count - 1])
            } else {
                button.setTitle(colorKeys[index])
            }
        }
    }

    func buttonTapped(_ button: WKInterfaceButton) {
        if button == buttons[0] {
            levelUp()
        } else {
            button.setEnabled(false)
        }
    }

    @IBAction func tlButtonTapped() {
        buttonTapped(tlButton)
    }

    @IBAction func trButtonTapped() {
        buttonTapped(trButton)
    }

    @IBAction func blButtonTapped() {
        buttonTapped(blButton)
    }

    @IBAction func brButtonTapped() {
        buttonTapped(brButton)
    }
    
}
