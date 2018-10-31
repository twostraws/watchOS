//
//  InterfaceController.swift
//  Project2 WatchKit Extension
//
//  Created by Paul Hudson on 21/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {
    @IBOutlet var result: WKInterfaceLabel!
    @IBOutlet var question: WKInterfaceImage!

    @IBOutlet var answers: WKInterfaceGroup!
    @IBOutlet var rock: WKInterfaceButton!
    @IBOutlet var paper: WKInterfaceButton!
    @IBOutlet var scissors: WKInterfaceButton!

    @IBOutlet var levelCounter: WKInterfaceLabel!
    @IBOutlet var timer: WKInterfaceTimer!

    var allMoves = ["rock", "paper", "scissors"]
    var shouldWin = true
    var level = 1

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        rock.setBackgroundImage(UIImage(named: "rock"))
        paper.setBackgroundImage(UIImage(named: "paper"))
        scissors.setBackgroundImage(UIImage(named: "scissors"))

        timer.start()
        newLevel()
    }

    func newLevel() {
        if level == 21 {
            result.setHidden(false)
            question.setHidden(true)
            answers.setHidden(true)
            timer.stop()
            return
        }

        levelCounter.setText("\(level)/20")

        if Bool.random() {
            setTitle("Win!")
            shouldWin = true
        } else {
            setTitle("Lose!")
            shouldWin = false
        }

        allMoves.shuffle()
        question.setImage(UIImage(named: allMoves[0]))
    }

    func check(for answer: String) {
        if allMoves[0] == answer {
            level += 1
            newLevel()
        } else {
            level -= 1
            if level < 1 { level = 1 }
            newLevel()
        }
    }

    @IBAction func rockTapped() {
        if shouldWin {
            check(for: "scissors")
        } else {
            check(for: "paper")
        }
    }

    @IBAction func paperTapped() {
        if shouldWin {
            check(for: "rock")
        } else {
            check(for: "scissors")
        }
    }

    @IBAction func scissorsTapped() {
        if shouldWin {
            check(for: "paper")
        } else {
            check(for: "rock")
        }
    }
}
