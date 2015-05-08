//
//  GameScene.swift
//  SpriteKit1
//
//  Created by Fernando on 5/4/15.
//  Copyright (c) 2015 Fernando. All rights reserved.
//

import SpriteKit
import AVFoundation
import CoreMotion

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}



struct PhysicsCategory {
    static let None      : UInt32 = 0
    static let All       : UInt32 = UInt32.max
    static let Monster   : UInt32 = 0b1       // 1
    static let Projectile: UInt32 = 0b10      // 2
    static let asteroid  : UInt32 = 0b100
    static let player    : UInt32 = 0b1000
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

#if !(arch(x86_64) || arch(arm64))
    func sqrt(a: CGFloat) -> CGFloat {
    return CGFloat(sqrtf(Float(a)))
    }
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    
    func normalized() -> CGPoint {
        return self / length()
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    // 1
    let player = SKSpriteNode(imageNamed: "playerr")
    var monstersDestroyed = 0
    let motionManager: CMMotionManager = CMMotionManager()
    let sky1 = SKSpriteNode(imageNamed: "espaco")
    let sky2 = SKSpriteNode(imageNamed: "espaco")
    var score = String()
    var labelScore = SKLabelNode(text: "score: ")
    var cont = Int()
    
    override func didMoveToView(view: SKView) {

        cont = 0
        
        sky1.size = CGSizeMake(size.width, size.height)
        
        sky2.size = CGSizeMake(size.width, size.height)
        
        sky1.position = CGPointMake(size.width/2, size.height/2)
        // 2
        sky2.position = CGPointMake(sky1.position.x + sky1.frame.width, size.height/2)
        //backgroundColor = SKColor.whiteColor()
        // 3
        addChild(sky1)
        addChild(sky2)
        
        score = "score: "
        labelScore.text = score
        labelScore.fontName = "Helvetica-Neue"
        labelScore.fontSize = 50
        labelScore.position = CGPointMake(size.width - 180, size.height - 100)
        labelScore.zRotation = -1.57
        labelScore.color = UIColor.whiteColor()
        labelScore.zPosition = 10
        
        
        addChild(labelScore)
        
        
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.name = "player"
        player.physicsBody = SKPhysicsBody(rectangleOfSize: player.size)
        player.physicsBody?.dynamic = true
        player.physicsBody?.categoryBitMask = PhysicsCategory.player
        player.physicsBody?.contactTestBitMask = PhysicsCategory.asteroid
        player.physicsBody?.collisionBitMask = PhysicsCategory.None
        // 4
        addChild(player)
        
        physicsWorld.gravity = CGVectorMake(0, 0)
        physicsWorld.contactDelegate = self
        
        motionManager.startAccelerometerUpdates()
        
        
        runAction (SKAction .repeatActionForever (
            SKAction .sequence ([
                SKAction .runBlock (addMonster),
                //SKAction .runBlock(addAsteroid),
                SKAction .waitForDuration (1.5,withRange: 0)
                ])
            ))
        
        runAction (SKAction .repeatActionForever (
            SKAction .sequence ([
                //SKAction .runBlock (addMonster),
                SKAction .runBlock(addAsteroid),
                SKAction .waitForDuration (3.0,withRange: 0)
                ])
            ))
        playBackgroundMusic("Sounds/background-music-aac.caf")
    }
    
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        
        runAction(SKAction.playSoundFileNamed("Sounds/pew-pew-lei.caf", waitForCompletion: false))
        
        // 1 - Choose one of the touches to work with
        //        let touch = touches.first as! UITouch
        //        let touchLocation = touch.locationInNode(self)
        
        // 2 - Set up initial location of projectile
        let projectile = SKSpriteNode(imageNamed: "projectille")
        projectile.position = player.position
        
        
        // 3 - Determine offset of location to projectile
        //let offset = projectile.position + CGPointMake(player.position.x + 200, projectile.position.y)
        
        // 4 - Bail out if you are shooting down or backwards
        //if (offset.x < 0) { return }
        
        // 5 - OK to add now - you've double checked position
        addChild(projectile)
        
        // 6 - Get the direction of where to shoot
        let direction = CGPointMake(500, player.position.y)
        
        // 7 - Make it shoot far enough to be guaranteed off screen
        let shootAmount = CGPointMake(direction.x * 5, 0)
        
        // 8 - Add the shoot amount to the current position
        let realDest = shootAmount + projectile.position
        
        // 9 - Create the actions
        let actionMove = SKAction.moveTo(realDest, duration: 5.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.dynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.Projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.Monster
        projectile.physicsBody?.collisionBitMask = PhysicsCategory.None
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        
        println(projectile.position)
        
        
    }
    
    override func update(currentTime: NSTimeInterval) {
        
        
        processUserMotionForUpdate(currentTime)
        
        var tomove = 8
        sky1.position.x -= CGFloat(tomove)
        sky2.position.x -= CGFloat(tomove)
        
        if((sky1.position.x + size.width) < size.width/2)
        {
            sky1.position = CGPointMake(sky2.position.x + sky2.frame.width, sky2.position.y)
        }
        
        if((sky2.position.x + size.width) < size.width/2)
        {
            sky2.position = CGPointMake(sky1.position.x + sky2.frame.width, sky1.position.y)
        }
    }
    
    
    func processUserMotionForUpdate(currentTime: CFTimeInterval) {
        
        // 1
        // let ship = childNodeWithName(player) as! SKSpriteNode
        
        // 2
        if let data = motionManager.accelerometerData {
            
            // 3
            if ((data.acceleration.x) < 0.04) {
                
                // 4 How do you move the ship?
                if (player.position.y < size.height - 10){
                    player.position = player.position + CGPointMake(0, 7)
                }
            }
            if ((data.acceleration.x) > -0.04) {
                
                // 4 How do you move the ship?
                if (player.position.y > 10){
                    player.position = player.position - CGPointMake(0, 7)
                }
            }
            
        }
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(#min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    func addAsteroid() {
        
        // Create sprite
        
        let asteroid = SKSpriteNode(imageNamed: "asteroid")
        
        asteroid.physicsBody = SKPhysicsBody(circleOfRadius: asteroid.size.width/2)
        asteroid.physicsBody?.dynamic = true // 2
        asteroid.physicsBody?.categoryBitMask = PhysicsCategory.asteroid // 3
        asteroid.physicsBody?.contactTestBitMask = PhysicsCategory.player // 4
        asteroid.physicsBody?.collisionBitMask = PhysicsCategory.Projectile // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: asteroid.size.height/2, max: size.height - asteroid.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        asteroid.position = CGPoint(x: size.width + asteroid.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(asteroid)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(3.0), max: CGFloat(5.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -asteroid.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        asteroid.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        var acao = SKAction.rotateToAngle(100, duration: 5)
        asteroid.runAction(acao)
        
        
        asteroid.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
    func addMonster() {
        
        // Create sprite
        
        let monster = SKSpriteNode(imageNamed: "alien")
        
        monster.physicsBody = SKPhysicsBody(rectangleOfSize: monster.size) // 1
        monster.physicsBody?.dynamic = true // 2
        monster.physicsBody?.categoryBitMask = PhysicsCategory.Monster // 3
        monster.physicsBody?.contactTestBitMask = PhysicsCategory.Projectile // 4
        monster.physicsBody?.collisionBitMask = PhysicsCategory.None // 5
        
        // Determine where to spawn the monster along the Y axis
        let actualY = random(min: monster.size.height/2, max: size.height - monster.size.height/2)
        
        // Position the monster slightly off-screen along the right edge,
        // and along a random position along the Y axis as calculated above
        monster.position = CGPoint(x: size.width + monster.size.width/2, y: actualY)
        
        // Add the monster to the scene
        addChild(monster)
        
        // Determine speed of the monster
        let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
        
        // Create the actions
        let actionMove = SKAction.moveTo(CGPoint(x: -monster.size.width/2, y: actualY), duration: NSTimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        monster.runAction(SKAction.sequence([actionMove, actionMoveDone]))
        
        let loseAction = SKAction.runBlock() {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
            gameOverScene.gameWon = false
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
        monster.runAction(SKAction.sequence([actionMove, loseAction, actionMoveDone]))
        
    }
    
    
    func chamaView()
    {
        let reveal = SKTransition.flipHorizontalWithDuration(0.5)
        let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
        gameOverScene.gameWon = false
        self.view?.presentScene(gameOverScene, transition: reveal)
        
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        // 1
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }

        
        // 2
        if ((firstBody.categoryBitMask & PhysicsCategory.asteroid != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.player != 0)) {
                
                let sparkEmmitterPath:NSString = NSBundle.mainBundle().pathForResource("explosao", ofType: "sks")!
                
                let sparkEmmiter = NSKeyedUnarchiver.unarchiveObjectWithFile(sparkEmmitterPath as String) as! SKEmitterNode
                
                //sparkEmmiter.particleLifetime = 1
                sparkEmmiter.position = player.position
                sparkEmmiter.name = "explosao"
                sparkEmmiter.zPosition = 10
                //sparkEmmiter.targetNode = self
                
                self.addChild(sparkEmmiter)
                player.removeFromParent()
                NSTimer.scheduledTimerWithTimeInterval(0.5, target:self, selector: Selector("chamaView"), userInfo: nil, repeats: false)
                
//                let reveal = SKTransition.flipHorizontalWithDuration(0.5)
//                let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
//                gameOverScene.gameWon = false
//                self.view?.presentScene(gameOverScene, transition: reveal)
//                

                
//                NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("pausar:"), userInfo: nil, repeats: false)
//                
//                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
                
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.Monster != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Projectile != 0)) {
                projectileDidCollideWithMonster(firstBody.node as! SKSpriteNode, monster: secondBody.node as! SKSpriteNode)
        }
        
    }
    
    func projectileDidCollideWithMonster(projectile:SKSpriteNode, monster:SKSpriteNode) {
        println("Hit")
        cont++
        aux = score + cont as! String
        labelScore.text = aux
        // contagem de pontos
        
        projectile.removeFromParent()
        monster.removeFromParent()
        monstersDestroyed++
        if (monstersDestroyed > 30) {
            let reveal = SKTransition.flipHorizontalWithDuration(0.5)
            let gameOverScene = GameOverScene.unarchiveFromFile("GameOverScene") as! GameOverScene
            gameOverScene.gameWon = true
            self.view?.presentScene(gameOverScene, transition: reveal)
        }
    }
    
}
