//
//  GameScene.swift
//  Project11
//
//  Created by Paul Hudson on 31/03/2017.
//  Copyright © 2017 Paul Hudson. All rights reserved.
//

import SpriteKit
import WatchKit

class GameScene: SKScene, WKCrownDelegate, SKPhysicsContactDelegate {
    weak var parentInterfaceController: InterfaceController!
    
    var player = SKNode()

    var leftEdge = SKSpriteNode(color: UIColor.white, size: CGSize(width: 10, height: 174))
    var rightEdge = SKSpriteNode(color: UIColor.white, size: CGSize(width: 10, height: 174))
    var topEdge = SKSpriteNode(color: UIColor.white, size: CGSize(width: 154, height: 10))
    var bottomEdge = SKSpriteNode(color: UIColor.white, size: CGSize(width: 154, height: 10))

    var isPlayerAlive = true
    let colorNames = ["Red", "Blue", "Green", "Yellow"]
    let colorValues: [UIColor] = [.red, .blue, .green, .yellow]
    var alertDelay = 1.0
    var moveSpeed = 70.0
    var createDelay = 0.5

    var score = 0 {
        didSet {
            parentInterfaceController?.setTitle("Score: \(score)")
        }
    }

    override func sceneDidLoad() {
        physicsWorld.contactDelegate = self
        backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1)

        let red = createPlayer(color: "Red")
        red.position = CGPoint(x: -8, y: 8)

        let blue = createPlayer(color: "Blue")
        blue.position = CGPoint(x: 8, y: 8)

        let green = createPlayer(color: "Green")
        green.position = CGPoint(x: -8, y: -8)

        let yellow = createPlayer(color: "Yellow")
        yellow.position = CGPoint(x: 8, y: -8)

        addChild(player)

        leftEdge.position = CGPoint(x: -77, y: 0)
        rightEdge.position = CGPoint(x: 77, y: 0)
        topEdge.position = CGPoint(x: 0, y: 87)
        bottomEdge.position = CGPoint(x: 0, y: -87)

        for edge in [leftEdge, rightEdge, topEdge, bottomEdge] {
            edge.colorBlendFactor = 1
            edge.alpha = 0
            addChild(edge)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + createDelay) {
            self.launchBall()
        }
    }

    func createPlayer(color: String) -> SKSpriteNode {
        let component = SKSpriteNode(imageNamed: "player\(color)")
        component.physicsBody = SKPhysicsBody(texture: component.texture!, size: component.size)
        component.physicsBody?.isDynamic = false

        component.name = color
        player.addChild(component)

        return component
    }

    func crownDidRotate(_ crownSequencer: WKCrownSequencer?, rotationalDelta: Double) {
        player.zRotation -= CGFloat(rotationalDelta) * 20
    }

    func launchBall() {
        guard isPlayerAlive else { return }

        let ballType = Int.random(in: 0 ..< colorNames.count - 1)

        let ball = createBall(color: colorNames[ballType])
        let (position, force, edge) = pickEdge()
        ball.position = position

        let flashEdge = SKAction.run {
            edge.color = self.colorValues[ballType]
            edge.alpha = 1
        }

        let resetEdge = SKAction.run {
            edge.alpha = 0
        }

        let launchBall = SKAction.run {
            ball.physicsBody!.velocity = force
        }

        let sequence = SKAction.sequence([flashEdge, SKAction.wait(forDuration: alertDelay), resetEdge, launchBall])
        run(sequence)
        alertDelay *= 0.98
    }

    func createBall(color: String) -> SKSpriteNode {
        let ball = SKSpriteNode(imageNamed: "ball\(color)")
        ball.name = color

        ball.physicsBody = SKPhysicsBody(circleOfRadius: 12)
        ball.physicsBody!.linearDamping = 0
        ball.physicsBody!.affectedByGravity = false
        ball.physicsBody!.contactTestBitMask = ball.physicsBody!.collisionBitMask
        addChild(ball)

        return ball
    }

    func pickEdge() -> (position: CGPoint, force: CGVector, edge: SKSpriteNode) {
        let direction = Int.random(in: 0...3)

        switch direction {
        case 0:
            return (CGPoint(x: -90, y: 0), CGVector(dx: moveSpeed, dy: 0), leftEdge)
        case 1:
            return (CGPoint(x: 90, y: 0), CGVector(dx: -moveSpeed, dy: 0), rightEdge)
        case 2:
            return (CGPoint(x: 0, y: -100), CGVector(dx: 0, dy: moveSpeed), bottomEdge)
        default:
            return (CGPoint(x: 0, y: 100), CGVector(dx: 0, dy: -moveSpeed), topEdge)
        }
    }

    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }

        if nodeA.parent == self {
            ball(nodeA, hit: nodeB)
        } else if nodeB.parent == self {
            ball(nodeB, hit: nodeA)
        } else {
            return
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + createDelay) {
            self.launchBall()
        }
    }

    func ball(_ ball: SKNode, hit color: SKNode) {
        guard isPlayerAlive else { return }

        ball.removeFromParent()

        if ball.name == color.name {
            score += 1
        } else {
            isPlayerAlive = false

            let gameOver = SKSpriteNode(imageNamed: "gameOver")
            gameOver.xScale = 2.0
            gameOver.yScale = 2.0
            gameOver.alpha = 0
            addChild(gameOver)

            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let scaleDown = SKAction.scale(to: 1, duration: 0.5)
            let group = SKAction.group([fadeIn, scaleDown])
            gameOver.run(group)
        }
    }
}
