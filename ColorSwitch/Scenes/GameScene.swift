//
//  GameScene.swift
//  ColorSwitch
//
//  Created by Allan Araujo on 8/9/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import SpriteKit

enum PlayColors {
    static let colors = [
        UIColor(red: 231/255, green: 76/255, blue: 60/255, alpha: 1.0),
        UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 1.0),
        UIColor(red: 46/255, green: 204/255, blue: 113/255, alpha: 1.0),
        UIColor(red: 52/255, green: 152/255, blue: 219/255, alpha: 1.0)
    ]
}

enum SwitchState: Int {
    case red, yellow, green, blue
}

class GameScene: SKScene {
    
    var colorSwitch: SKSpriteNode!
    var switchState = SwitchState.red
    var currentColorIndex: Int?
    
    let scoreLabel = SKLabelNode(text: "0")
    var score = 0
    
    override func didMove(to view: SKView) {
        setupPhysics()
        layoutScene()
    }
    
    func setupPhysics() {
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -1.0)
        physicsWorld.contactDelegate = self
    }
    
    func layoutScene() {
        backgroundColor = UIColor(red: 44/255, green: 62/255, blue: 80/255, alpha: 1.0)
        
        colorSwitch = SKSpriteNode(imageNamed: "ColorCircle")
        colorSwitch.size = CGSize(width: frame.size.width/3, height: frame.size.width/3)
        colorSwitch.position = CGPoint(x: frame.midX, y: frame.minY + colorSwitch.size.height)
        colorSwitch.zPosition = ZPositions.colorSwitch
        colorSwitch.physicsBody = SKPhysicsBody(circleOfRadius: colorSwitch.size.width/2)
        colorSwitch.physicsBody?.categoryBitMask = PhysicsCategories.switchCategory
        colorSwitch.physicsBody?.isDynamic = false
        addChild(colorSwitch)
        
        scoreLabel.fontName = "AvenirNext-Bold"
        scoreLabel.fontSize = 60.0
        scoreLabel.fontColor = UIColor.white
        scoreLabel.position = CGPoint(x: frame.midX, y: frame.midY)
        scoreLabel.zPosition = ZPositions.label
        addChild(scoreLabel)
        
        spawnBall()
        
    }
    
    func updateScoreLabel() {
        scoreLabel.text = "\(score)"
    }
    
    func spawnBall() {
        
        currentColorIndex = Int(arc4random_uniform(UInt32(4)))
        
        let ball = SKSpriteNode(texture: SKTexture(imageNamed: "ball"), color: PlayColors.colors[currentColorIndex!], size: CGSize(width: 30.0, height: 30.0))
        
        //applies color to ball
        ball.colorBlendFactor = 1.0
        ball.name = "Ball"
        ball.position = CGPoint(x: frame.midX, y: frame.maxY)
        ball.zPosition = ZPositions.ball
        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width/2)
        
        //sets category for this particular physics body
        ball.physicsBody?.categoryBitMask = PhysicsCategories.ballCategory
        //sets which collision should cause notification in app.
        ball.physicsBody?.contactTestBitMask = PhysicsCategories.switchCategory
        ball.physicsBody?.collisionBitMask = PhysicsCategories.none
        
        addChild(ball)
        
    }
    
    func turnWheel() {
        // Turns wheel
        if let newState = SwitchState(rawValue: switchState.rawValue + 1) {
            switchState = newState
        } else {
            //return to red if rawValue + > enum count
            switchState = .red
        }
        
        colorSwitch.run(SKAction.rotate(byAngle: CGFloat.pi/2, duration: 0.25))
    }
    
    func gameOver() {
        //Set recent score
        UserDefaults.standard.set(score, forKey: "RecentScore")
        
        if score > UserDefaults.standard.integer(forKey: "Highscore") {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        let menuScene = MenuScene(size: view!.bounds.size)
        view!.presentScene(menuScene)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        turnWheel()
    }

}

//needed bc we call physicsWorld.contactDelegate = self
extension GameScene: SKPhysicsContactDelegate {
    
    //Always called when contact is made in our scene
    func didBegin(_ contact: SKPhysicsContact) {
        // 01 - ball mask value
        // 10 - switch mask value
        // set contactMask to either the mask of ball or switch
        // This is a bitwise or which will combine them.
        // So with this the cotnact mask = 11
        let contactMask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        //Checks to see if contact mask is == 11
        //Can assume contact was between ball and a switch
        if contactMask == PhysicsCategories.ballCategory | PhysicsCategories.switchCategory {
            /*
             Complicated but this is doing:
             Check which node is our ball, and then assign it to constant ball.
             We do so by checking node's name.
             
             If we have this node, we can check to see if user selected correct color.
             */
            if let ball = contact.bodyA.node?.name == "Ball" ? contact.bodyA.node as? SKSpriteNode : contact.bodyB.node as? SKSpriteNode {
                
                //User has the correct color facing the ball.
                if currentColorIndex == switchState.rawValue {
                    run(SKAction.playSoundFileNamed("bling", waitForCompletion: false))
                    score += 1
                    self.updateScoreLabel()
                    ball.run(SKAction.fadeOut(withDuration: 0.25)) {
                        //remove old ball
                        ball.removeFromParent()
                        self.spawnBall()
                    }
                } else {
                    self.gameOver()
                }
            }
        }
    }
}
