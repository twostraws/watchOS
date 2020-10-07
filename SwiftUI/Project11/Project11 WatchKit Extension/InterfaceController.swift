//
//  InterfaceController.swift
//  Project11 WatchKit Extension
//
//  Created by Paul Hudson on 07/10/2020.
//

import SpriteKit
import WatchKit

class InterfaceController: WKInterfaceController {
    @IBOutlet var gameInterface: WKInterfaceSKScene!
    var gameScene: GameScene!
    
    override func awake(withContext context: Any?) {
        // Configure interface objects here.
        startGame(self)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
    }

    @IBAction func startGame(_ sender: Any) {
        if gameScene != nil {
            guard gameScene.isPlayerAlive == false else { return }
        }

        gameScene = GameScene()
        gameScene.scaleMode = .resizeFill
        gameScene.parentInterfaceController = self
        gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let transition = SKTransition.doorway(withDuration: 1)
        gameInterface.presentScene(gameScene, transition: transition)

        crownSequencer.delegate = gameScene
    }

    override func didAppear() {
        crownSequencer.focus()
    }
}
