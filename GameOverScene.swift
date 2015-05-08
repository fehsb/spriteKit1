//
//  GameOverScene.swift
//  SpriteKit1
//
//  Created by Fernando on 5/4/15.
//  Copyright (c) 2015 Fernando. All rights reserved.
//

import Foundation
import SpriteKit

let GameOverLabelCategoryName = "gameOver"
let GameOverTap = "tap"


class GameOverScene: SKScene {
    var gameWon : Bool = false {
        // 1.
        didSet {
            let gameOverLabel = childNodeWithName(GameOverLabelCategoryName) as! SKLabelNode
            gameOverLabel.text = gameWon ? "You Won" : "Game Over"
            
            let gameOvertapLabel = childNodeWithName(GameOverTap) as! SKLabelNode
            gameOvertapLabel.text = gameWon ? "Replay?" : "Try Again?"
        }
    }
    
    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
      
        let scene:GameScene = GameScene(size: self.size)
        let transation = SKTransition.revealWithDirection(SKTransitionDirection.Right, duration: 1.5)
        scene.scaleMode = SKSceneScaleMode.AspectFill
        self.view!.presentScene(scene, transition: transation)
        
    }
    
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
  //      if let view = view {
            // 2.
    //        let gameScene = GameScene.unarchiveFromFile("GameScene") as! GameScene
      //      view.presentScene(gameScene)
        //}
    //}
    
}
    

    
    //init(size: CGSize, won:Bool) {
        
        
        
      //  super.init(size: size)
        
        // 1
        //backgroundColor = SKColor.whiteColor()
        
        // 2
        //var message = won ? "You Won!" : "You Lose :["
        
        // 3
        //let label = SKLabelNode(fontNamed: "Chalkduster")
        //label.text = message
        //label.fontSize = 40
        //label.fontColor = SKColor.blackColor()
        //label.position = CGPoint(x: size.width/2, y: size.height/2)
        //addChild(label)
        
        // 4
        //runAction(SKAction.sequence([
          //  SKAction.waitForDuration(3.0),
            //SKAction.runBlock() {
                // 5
              //  let reveal = SKTransition.flipHorizontalWithDuration(0.5)
                //let scene = GameScene(size: size)
                //self.view?.presentScene(scene, transition:reveal)
            //}
            //]))
        
    //}
    
    // 6
    //required init(coder aDecoder: NSCoder) {
      //  fatalError("init(coder:) has not been implemented")
    //}
