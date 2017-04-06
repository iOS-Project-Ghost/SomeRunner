//
//  MainMenuScene.swift
//  Cowboy Runner
//
//  Created by Ryan Stoppler on 2017-03-30.
//  Copyright © 2017 stoppler. All rights reserved.
//

import SpriteKit

class MainMenuScene: SKScene {
    
    var playBtn = SKSpriteNode()
    
    var scoreBtn = SKSpriteNode()
    
    var title = SKLabelNode()
    
    var scoreLabel = SKLabelNode()
    
    override func didMove(to view: SKView) {
        
        initialize()
        
    }
    
    override func update(_ currentTime: TimeInterval) {
        infiniteScrollBackgrounds()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            //run game
            if atPoint(location) == playBtn{
                let gameplay = GameplayScene(fileNamed: "GameplayScene")
                gameplay!.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
            }
            //show high score
            if atPoint(location) == scoreBtn{
                showScore()
            }
        }
    }
    
    func initialize(){
        
        createBG()
        createGrounds()
        getButtons()
        getLabel()
        
    }
    
    //create background of scene
    func createBG(){
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG2")
            bg.name = "BG2"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: 0)
            bg.zPosition = 0
            self.addChild(bg)
        }
    }
    
    //create ground for the scene
    func createGrounds(){
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "Ground")
            bg.name = "Ground"
            bg.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            bg.position = CGPoint(x: CGFloat(i) * bg.size.width, y: -(self.frame.size.height / 2))
            bg.zPosition = 3
            self.addChild(bg)
        }
    }
    
    //infinite scroll for background and grounds
    func infiniteScrollBackgrounds(){
        //scrolling for the main background
        enumerateChildNodes(withName: "BG2", using: ({
            (node, error) in
            let bgNode = node as! SKSpriteNode
            //move backgrounds by 4 pixels to the left
            node.position.x -= 4
            //reposition background so it doesn't run out when scrolling
            if bgNode.position.x < -(self.frame.width){
                bgNode.position.x += bgNode.frame.width * 3
            }
        }))
        //scrolling for the ground portion of the background
        enumerateChildNodes(withName: "Ground", using: ({
            (node, error) in
            
            let bgNode = node as! SKSpriteNode
            //move backgrounds by 4 pixels to the left
            node.position.x -= 2
            //reposition background so it doesn't run out when scrolling
            if bgNode.position.x < -(self.frame.width){
                bgNode.position.x += bgNode.frame.width * 3
            }
        }))
    }
    
    //get buttons for main menu
    func getButtons(){
        playBtn = self.childNode(withName: "Play") as! SKSpriteNode
        playBtn.zPosition = 5
        scoreBtn = self.childNode(withName: "Score") as! SKSpriteNode
        scoreBtn.zPosition = 5
    }
    
    //get the title label from the main menu and animate it up and down
    func getLabel(){
        
        title = self.childNode(withName: "Title") as! SKLabelNode
        title.fontName = "Noteworthy"
        title.fontSize = 120
        title.text = "Dude Runner"
        title.zPosition = 5
        title.fontColor = UIColor.darkGray
        
        let moveUp = SKAction.moveTo(y: title.position.y + 50, duration: TimeInterval(1.3))
        
        let moveDown = SKAction.moveTo(y: title.position.y - 50, duration: TimeInterval(1.3))
        
        let sequence = SKAction.sequence([moveUp, moveDown])
        //animate menu as long as menu is visible
        title.run(SKAction.repeatForever(sequence))
        
    }
    
    func showScore(){
        
        scoreLabel.removeFromParent()
        scoreLabel = SKLabelNode(fontNamed: "Noteworthy")
        scoreLabel.fontSize = 180;
        scoreLabel.text = "\(UserDefaults.standard.integer(forKey: "Highscore"))"
        scoreLabel.position = CGPoint(x: 0, y: -200)
        scoreLabel.zPosition = 9
        self.addChild(scoreLabel)
        
        
    }


    
}
