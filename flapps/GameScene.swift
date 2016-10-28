//
//  GameScene.swift
//  flapps
//
//  Created by Mahmoud Khwaiter on 2016-10-26.
//  Copyright © 2016 Mahmoud Khwaiter. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation

struct PhysicsCategory {
    static let Ghost: UInt32 = 0x1 << 1
    static let Ground: UInt32 = 0x1 << 2
    static let Wall: UInt32 = 0x1 << 3
    static let Score: UInt32 = 0x1 << 4
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var effectPlayer = AVAudioPlayer()
    var musicPlayer = AVAudioPlayer()
    
    var textureAtlas = SKTextureAtlas()
    var textureArray = [SKTexture]()
    
    var Ground = SKSpriteNode()
    var Ghost = SKSpriteNode()
    var wallPair = SKNode()
    
    var gameStarted = Bool()
    var died = Bool()
    
    var moveAndRemove = SKAction()
    var zoomInAndThenOut = SKAction()
    
    var score = Int()
    let scoreLabel = SKLabelNode()
    
    var restartButton = SKSpriteNode()
    
    func restartScene(){
    
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0
        createScene()
    
    
    }
    
    func createScene(){
    
        IdlePadSound()
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
        
            let background = SKSpriteNode(imageNamed: "beachFun")
            background.position = CGPoint(x: CGFloat(i) * self.frame.width, y: 0)
            background.size = CGSize(width: ((self.view?.frame.width)! * 2), height: ((self.view?.frame.height)! * 2)
            )
            background.name = "background"
            self.addChild(background)
        
        }
        
        scoreLabel.position = CGPoint(x: 0, y: (self.view?.frame.height)! - 200)
        scoreLabel.text = "\(score)"
        scoreLabel.fontSize = 140
        
        
        scoreLabel.zPosition = 5
        
        self.addChild(scoreLabel)
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(1.5)
        
        Ground.position = CGPoint(x: self.frame.width / 2, y: -self.frame.height / 2 + Ground.frame.height / 2)
        
        Ground.physicsBody = SKPhysicsBody(rectangleOf: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.isDynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        Ghost = SKSpriteNode(imageNamed: textureAtlas.textureNames[0] as String!)
        Ghost.size = CGSize(width: 90, height: 75)
        Ghost.position = CGPoint(x: -50 - Ghost.frame.size.width, y: 0)
        
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height / 2)
        Ghost.physicsBody?.categoryBitMask = PhysicsCategory.Ghost
        Ghost.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Ghost.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.isDynamic = true
        
        Ghost.zPosition = 2
        
        
        self.addChild(Ghost)

    
    }
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    override func didMove(to view: SKView) {
        
        textureAtlas = SKTextureAtlas(named: "Ghost")
        
        for i in 0...textureAtlas.textureNames.count - 1 {
        
            let name = "Ghost\(i).png"
            textureArray.append(SKTexture(imageNamed: name))
        
        
        }
        
        createScene()
        
    }
    
    func createButton() {
    
        restartButton = SKSpriteNode(imageNamed: "playAgain")
        
        restartButton.position = CGPoint(x: 0, y: -250)
        restartButton.zPosition = 6
        restartButton.setScale(0)
        restartButton.run(SKAction.scale(to: 1.0, duration: 0.3))
        
        
        self.addChild(restartButton)
    
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secondBody.categoryBitMask == PhysicsCategory.Ghost || firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Score {
        
        score += 1
            scoreLabel.text = "\(score)"
        
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Wall || firstBody.categoryBitMask == PhysicsCategory.Wall && secondBody.categoryBitMask == PhysicsCategory.Ghost {
            
            enumerateChildNodes(withName: "wallPair", using: ({
            
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
            
            }) )
            
            if died == false {
            
                died = true
                CrashSoundEffect()
                IdlePadSound()
                createButton() }
        
        
        }
        
        if firstBody.categoryBitMask == PhysicsCategory.Ghost && secondBody.categoryBitMask == PhysicsCategory.Ground || firstBody.categoryBitMask == PhysicsCategory.Ground && secondBody.categoryBitMask == PhysicsCategory.Ghost {
            
            enumerateChildNodes(withName: "wallPair", using: ({
                
                (node, error) in
                
                node.speed = 0
                self.removeAllActions()
                
            }) )
            
            if died == false {
                
                died = true
                createButton() }
            
            
        }
        
    }
   
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if gameStarted == false {
        
            PelicanMusic()
            
            gameStarted = true
            
            Ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.run({
                
                ()in
                
                self.createWalls()
                
            })
            
            let delay = SKAction.wait(forDuration: 1.3)
            let SpawnSequece = SKAction.sequence([spawn, delay])
            let spawnDelayForever = SKAction.repeatForever(SpawnSequece)
            self.run(spawnDelayForever)
            
            let distance = CGFloat(self.frame.width + wallPair.frame.width + 250)
            let movePipes = SKAction.moveBy(x: -distance, y: 0, duration: TimeInterval(0.003 * distance))
            let removePipes = SKAction.removeFromParent()
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
        
        }
        
        else {
        
            if died == true {
            
            
            }
            else {
                Ghost.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                Ghost.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 120))
                
                Ghost.run(SKAction.animate(with: textureArray, timePerFrame: 0.3))
                
                flappySoundEffect()
                
            }
        
        }
        
        for touch in touches {
        
            let location = touch.location(in: self)
            
            if died == true {
            
                if restartButton.contains(location) {
                
                    restartScene()
                }
            
            }
        
        }
        
        
    }
    
    func flappySoundEffect() {
    
        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "flapSound", ofType: "wav")!)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! effectPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
        
        effectPlayer.prepareToPlay()
        effectPlayer.play()
    
    
    }
    
    func CrashSoundEffect() {
        
        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "crashSound", ofType: "wav")!)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! effectPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
        effectPlayer.prepareToPlay()
        effectPlayer.play()
        
        
    }
    
    func IdlePadSound() {
        
        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "idlePads", ofType: "wav")!)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! musicPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
        musicPlayer.prepareToPlay()
        musicPlayer.play()
        
        
    }
    
    func PelicanMusic() {
        
        let alertSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "pelicanMusic", ofType: "wav")!)
        
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        
        try! musicPlayer = AVAudioPlayer(contentsOf: alertSound as URL)
        musicPlayer.prepareToPlay()
        musicPlayer.play()
        
        
    }
    
    func createWalls() {
        
        let scoreNode = SKSpriteNode()
        
        scoreNode.size = CGSize(width: 1, height: 1000)
        scoreNode.position = CGPoint(x: 620, y: 0)
        
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        // scoreNode.color = SKColor.blue
        
        
        wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let bottomWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x:600, y: 590)
        bottomWall.position = CGPoint(x: 600, y: -590)
        
        topWall.setScale(0.9)
        bottomWall.setScale(0.9)
        
        topWall.zRotation = CGFloat(M_PI)
        
        topWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.isDynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        bottomWall.physicsBody = SKPhysicsBody(rectangleOf: topWall.size)
        bottomWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        bottomWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        bottomWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        bottomWall.physicsBody?.isDynamic = false
        bottomWall.physicsBody?.affectedByGravity = false
        
        wallPair.addChild(topWall)
        wallPair.addChild(bottomWall)
        wallPair.run(moveAndRemove)
        
        wallPair.zPosition = 1
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        wallPair.addChild(scoreNode)
        
        self.addChild(wallPair)
    
    
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        //
        
        if gameStarted == true {
        
            if died == false {
            
                enumerateChildNodes(withName: "background", using: ({
                    
                    (node, error) in
                    
                    let bg = node as! SKSpriteNode
                    
                    
                                               ////Ändra här👇🏿 för scroll speed of background////
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                    
                        bg.position = CGPoint(x: bg.position.x + bg.size.width * 2, y: bg.position.y)
                        
                    }
                
                
                }))
            }
        
        }
        
    }
    
    
}
