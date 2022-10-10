//
//  GameScene.swift
//  Project11 Watch App
//
//  Created by Paul Hudson on 09/10/2022.
//

import SpriteKit
import WatchKit

class GameScene: SKScene, SKPhysicsContactDelegate, ObservableObject {
    let player = SKNode()
    
    let leftEdge = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 150))
    let rightEdge = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 150))
    let topEdge = SKSpriteNode(color: .white, size: CGSize(width: 150, height: 10))
    let bottomEdge = SKSpriteNode(color: .white, size: CGSize(width: 150, height: 10))
    
    var isPlayerAlive = true
    let colorNames = ["Red", "Blue", "Green", "Yellow"]
    let colorValues: [UIColor] = [.red, .blue, .green, .yellow]
    var alertDelay = 1.0
    var moveSpeed = 70.0
    
    var createDelay = 500
    
    @Published var score = 0
    
    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 100 else { return }
        guard player.children.isEmpty else { return }
        
        setUp()
    }
    
    func setUp() {
        physicsWorld.contactDelegate = self
        backgroundColor = .black

        let red = createPlayer(color: "Red")
        red.position = CGPoint(x: -8, y: 8)

        let blue = createPlayer(color: "Blue")
        blue.position = CGPoint(x: 8, y: 8)

        let green = createPlayer(color: "Green")
        green.position = CGPoint(x: -8, y: -8)

        let yellow = createPlayer(color: "Yellow")
        yellow.position = CGPoint(x: 8, y: -8)

        addChild(player)
        
        leftEdge.position = CGPoint(x: -50, y: 0)
        rightEdge.position = CGPoint(x: 50, y: 0)
        topEdge.position = CGPoint(x: 0, y: 50)
        bottomEdge.position = CGPoint(x: 0, y: -50)
        
        for edge in [leftEdge, rightEdge, topEdge, bottomEdge] {
            edge.colorBlendFactor = 1
            edge.alpha = 0
            addChild(edge)
        }
        
        Task { @MainActor in
            try await Task.sleep(until: .now + .milliseconds(createDelay), clock: .continuous)
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
    
    func rotate(to newRotation: Double) {
        player.zRotation = newRotation
    }
    
    func pickEdge() -> (position: CGPoint, force: CGVector, edge: SKSpriteNode) {
        let direction = Int.random(in: 0...3)

        switch direction {
        case 0:
            return (CGPoint(x: -110, y: 0), CGVector(dx: moveSpeed, dy: 0), leftEdge)
        case 1:
            return (CGPoint(x: 110, y: 0), CGVector(dx: -moveSpeed, dy: 0), rightEdge)
        case 2:
            return (CGPoint(x: 0, y: -120), CGVector(dx: 0, dy: moveSpeed), bottomEdge)
        default:
            return (CGPoint(x: 0, y: 120), CGVector(dx: 0, dy: -moveSpeed), topEdge)
        }
    }
    
    func launchBall() {
        // bail out if the game is over
        guard isPlayerAlive else { return }

        // pick a random ball color
        let ballType = Int.random(in: 0 ..< colorNames.count - 1)

        // create a ball from that random color
        let ball = createBall(color: colorNames[ballType])
        
        // get a random edge to launch from, plus position and force to apply
        let (position, force, edge) = pickEdge()
        
        // place the ball at its starting position
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
        ball.physicsBody?.linearDamping = 0
        ball.physicsBody?.affectedByGravity = false
        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
        
        addChild(ball)
        return ball
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.parent == self {
            ball(nodeA, hit: nodeB)
        } else if nodeB.parent == self {
            ball(nodeB, hit: nodeA)
        } else {
            // neither? Just exit!
            return
        }
        
        Task { @MainActor in
            try await Task.sleep(until: .now + .milliseconds(createDelay), clock: .continuous)
            self.launchBall()
        }
    }
    
    func ball(_ ball: SKNode, hit color: SKNode) {
        // don't run this more than once
        guard isPlayerAlive else { return }
        
        // destroy the ball no matter what
        ball.removeFromParent()

        if ball.name == color.name {
            // player scored a point!
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
    
    func reset() {
        guard isPlayerAlive == false else { return }
        
        removeAllChildren()
        isPlayerAlive = true
        score = 0
        
        setUp()
    }
}
