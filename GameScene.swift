//
//  GameScene.swift
//  Coin Man
//
//  Created by Karol Chmiel on 12/09/2017.
//  Copyright © 2017 Karol Chmiel. All rights reserved.
//

import SpriteKit
import GameplayKit
import AudioToolbox.AudioServices
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var coinMan: SKSpriteNode?
    var coinTimer: Timer?
    var bombTimer: Timer?
    var ceiling: SKSpriteNode?
    var scoreLabel: SKLabelNode?
    var yourScoreValueLabel: SKLabelNode?
    var yourScoreLabel: SKLabelNode?
    var explosionNode: SKSpriteNode?
    var gamespeed = 4.0
    var score = 0
    
    let coinManCategory: UInt32 = 0x1 << 1
    let coinCategory: UInt32 = 0x1 << 2
    let bombCategory: UInt32 = 0x1 << 3
    let groundAndCeilingCategory: UInt32 = 0x1 << 4
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        
        scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode
        
        coinMan = childNode(withName: "coin_man") as? SKSpriteNode
        coinMan?.physicsBody?.categoryBitMask = coinManCategory
        coinMan?.physicsBody?.contactTestBitMask = coinCategory | bombCategory
        coinMan?.physicsBody?.collisionBitMask = groundAndCeilingCategory
        var coinManRun: [SKTexture] = []
        for number in 1...5 {
            coinManRun.append(SKTexture(imageNamed: "frame-\(number)"))
        }
        coinMan?.run(SKAction.repeatForever(SKAction.animate(with: coinManRun, timePerFrame: 0.1)))
        
        ceiling = childNode(withName: "ceiling") as? SKSpriteNode
        ceiling?.physicsBody?.categoryBitMask = groundAndCeilingCategory
        
        self.coinMan = self.childNode(withName: "coin_man") as? SKSpriteNode
        
        coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
            (timer) in
            self.createCoin()
        })

        bombTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {
            (timer) in
            self.createBomb()
        })
        
        createGrass()
    }
    
    func createGrass() {
        let sizingGrass = SKSpriteNode(imageNamed: "grass")
        let numberOfGrass = Int(size.width/sizingGrass.size.width + 1)
        for number in 0...numberOfGrass {
            let grass = SKSpriteNode(imageNamed: "grass")
            grass.physicsBody = SKPhysicsBody(rectangleOf: grass.size)
            grass.physicsBody?.categoryBitMask = coinManCategory
            grass.physicsBody?.collisionBitMask = 0
            grass.physicsBody?.affectedByGravity = false
            grass.physicsBody?.isDynamic = false
            grass.zPosition = 0.9
            addChild(grass)
            
            let grassX = -size.width/2 + grass.size.width/2 + grass.size.width * CGFloat(number)
            grass.position = CGPoint(x: grassX, y: -size.height/2 + grass.size.height/2 - 20)
            
            let speed = 100.0
            let moveLeft = SKAction.moveBy(x: -grass.size.width - grass.size.width * CGFloat(number), y: 0, duration: TimeInterval(grass.size.width + grass.size.width * CGFloat(number))/speed)
            
            let resetGrass = SKAction.moveBy(x: size.width + grass.size.width, y: 0, duration: 0)
            let grassFullMove = SKAction.moveBy(x: -size.width - grass.size.width, y: 0, duration: TimeInterval(size.width + grass.size.width)/speed)
            let grassMoveForever = SKAction.repeatForever(SKAction.sequence([grassFullMove, resetGrass]))
            
            grass.run(SKAction.sequence([moveLeft, resetGrass, grassMoveForever]))
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !((scene?.isPaused)!) {
            coinMan?.physicsBody?.applyForce(CGVector(dx: 0, dy: 70000))
        }
        
        let touch = touches.first
        if let location = touch?.location(in: self) {
            let theNodes = nodes(at: location)
            for node in theNodes {
                if node.name == "play" {
                    score = 0
                    node.removeFromParent()
                    yourScoreValueLabel?.removeFromParent()
                    yourScoreLabel?.removeFromParent()
                    explosionNode?.removeFromParent()
                    scene?.isPaused = false
                    scoreLabel?.text = "Score: \(score)"
                    gamespeed = 4.0
                    coinTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {
                        (timer) in
                        self.createCoin()
                    })
                    
                    bombTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true, block: {
                        (timer) in
                        self.createBomb()
                    })
                }
            }
        }
    }
    
    func createCoin() {
        let coin = SKSpriteNode(imageNamed: "coin")
        
        coin.physicsBody = SKPhysicsBody(rectangleOf: coin.size)
        coin.physicsBody?.affectedByGravity = false
        coin.physicsBody?.categoryBitMask = coinCategory
        coin.physicsBody?.contactTestBitMask = coinManCategory
        coin.physicsBody?.collisionBitMask = 0
        
        addChild(coin)
        
        
        let maxY = (size.height - coin.size.height)/2
        let minY: CGFloat = -size.height/2 + 100 + coin.size.height
        let heightRange = maxY - minY
        let randomHeight  = maxY - CGFloat(arc4random_uniform(UInt32(heightRange)))
        
        coin.position = CGPoint(x: (size.width - coin.size.width)/2, y: randomHeight)
        
        let moveLeft = SKAction.moveBy(x: -(size.width + coin.size.width), y: 0, duration: self.gamespeed-1)
        
        coin.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    func createBomb() {
        let bomb = SKSpriteNode(imageNamed: "bomb")
        
        bomb.physicsBody = SKPhysicsBody(rectangleOf: bomb.size)
        bomb.physicsBody?.affectedByGravity = false
        bomb.physicsBody?.categoryBitMask = bombCategory
        bomb.physicsBody?.contactTestBitMask = coinManCategory
        bomb.physicsBody?.collisionBitMask = 0
        
        addChild(bomb)
        
        let maxY = (size.height - bomb.size.height)/2
        let minY: CGFloat = -size.height/2 + 100 + bomb.size.height
        let heightRange = maxY - minY
        let randomHeight  = maxY - CGFloat(arc4random_uniform(UInt32(heightRange)))
        
        bomb.position = CGPoint(x: (size.width - bomb.size.width)/2, y: randomHeight)
        
        let moveLeft = SKAction.moveBy(x: -(size.width + bomb.size.width), y: 0, duration: self.gamespeed)
        
        bomb.run(SKAction.sequence([moveLeft, SKAction.removeFromParent()]))
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        if contact.bodyA.categoryBitMask == coinCategory {
            score += 1
            if self.score > 9 && self.score < 139{
                self.gamespeed = 4 - log(Double(self.score/10))
                print(self.gamespeed)
            }
            contact.bodyA.node?.removeFromParent()
        } else if contact.bodyB.categoryBitMask == coinCategory {
            score += 1
            if self.score > 9 && self.score < 139 {
                self.gamespeed = 4 - log(Double(self.score/10))
                print(self.gamespeed)
            }
            contact.bodyB.node?.removeFromParent()
        } else if contact.bodyA.categoryBitMask == bombCategory {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            explosionNode = SKSpriteNode(imageNamed: "explosion")
            explosionNode?.position = (contact.bodyA.node?.position)!
            contact.bodyA.node?.removeFromParent()
            addChild(explosionNode!)
            gameOver()
        } else if contact.bodyB.categoryBitMask == bombCategory {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
            explosionNode = SKSpriteNode(imageNamed: "explosion")
            explosionNode?.position = (contact.bodyB.node?.position)!
            contact.bodyB.node?.removeFromParent()
            addChild(explosionNode!)
            gameOver()
        }
        
        scoreLabel?.text = "Score: \(score)"
    }
    
    func gameOver() {
        scene?.isPaused = true
        yourScoreLabel = SKLabelNode(text: "You're Score:")
        yourScoreLabel?.position = CGPoint(x: 0, y: 200)
        yourScoreLabel?.fontSize = 100
        yourScoreLabel?.zPosition = 1
        if yourScoreLabel != nil {
            addChild(yourScoreLabel!)
        }
        
        yourScoreValueLabel = SKLabelNode(text: "\(score)")
        yourScoreValueLabel?.position = CGPoint(x: 0, y: 40)
        yourScoreValueLabel?.fontSize = 130
        yourScoreValueLabel?.zPosition = 1
        if yourScoreValueLabel != nil {
            addChild(yourScoreValueLabel!)
        }
        
        let playButton = SKSpriteNode(imageNamed: "play-button")
        playButton.position = CGPoint(x: 0, y: -160)
        playButton.name = "play"
        playButton.zPosition = 1
        addChild(playButton)
        
        bombTimer?.invalidate()
        coinTimer?.invalidate()
    }
}
