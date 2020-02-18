//
//  InterfaceController.swift
//  Project11 WatchKit Extension
//
//  Created by Paul Hudson on 31/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import Foundation
import SpriteKit
import WatchKit


class InterfaceController: WKInterfaceController {
    @IBOutlet var gameInterface: WKInterfaceSKScene!
    var gameScene: GameScene!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)

        startGame(self)
    }
    
    @IBAction func startGame(_ sender: Any) {
        if gameScene != nil {
            guard gameScene.isPlayerAlive == false else { return }
        }

        gameScene = GameScene(size: CGSize(width: 154, height: 174))
        gameScene.parentInterfaceController = self
        gameScene.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        let transition = SKTransition.doorway(withDuration: 1)
        gameInterface.presentScene(gameScene, transition: transition)
    }

    override func didAppear() {
        crownSequencer.focus()
        crownSequencer.delegate = gameScene
    }
}
