//
//  GameplayScene.swift
//  Cowboy Runner
//
//  Created by Ryan Stoppler on 2017-03-30.
//  Copyright © 2017 stoppler. All rights reserved.
//

import SpriteKit

class GameplayScene: SKScene, SKPhysicsContactDelegate{
    
    var player = Player()
    
    var obstacles = [SKSpriteNode]()
    
    var canJump = false
    
    var movePlayer = false
    
    var playerOnObstacle = false
    
    var isAlive = false
    
    var spawner = Timer()
    
    var counter = Timer()
    
    var scoreLabel = SKLabelNode()
    
    var score = Int(0)
    
    var pausePanel = SKSpriteNode()
    
    
    override func didMove(to view: SKView) {
        initialize()
        
        
    //end of did move func
    }
    
    //update scene everytime the frame refreshes
    override func update(_ currentTime: TimeInterval) {
        
        //move scene if the player is alive
        if isAlive{
            infiniteScrollBackgrounds()
        }
        
        //if player is on top of obstacle, move player with obstacle
        if movePlayer {
            player.position.x -= 9
        }
        
        //check where the player is on the screen
        checkPlayersbounds()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch in touches {
            
            let location = touch.location(in: self)
            //restart gameplay
            if atPoint(location).name == "Restart" {
                let gameplay = GameplayScene(fileNamed: "GameplayScene")
                gameplay!.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
            }
            //go to main menu
            if atPoint(location).name == "Quit" {
                let gameplay = MainMenuScene(fileNamed: "MainMenuScene")
                gameplay!.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
            }
            
            //open pause panel
            if atPoint(location).name == "Pause" {
                createPausePanel()
            }
            
            if atPoint(location).name == "Resume" {
                pausePanel.removeFromParent()
                self.scene?.isPaused = false;
                //infintly spawn obstacles every x amount of seconds
                spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(firstNumber: 2, secondNumber: 5)), target: self, selector: #selector(spawnObstacles), userInfo: nil, repeats: true)
                //increment score
                counter = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementScore), userInfo: nil, repeats: true)

                
            }
            
            if atPoint(location).name == "Quit" {
                let gameplay = MainMenuScene(fileNamed: "MainMenuScene")
                gameplay!.scaleMode = .aspectFill
                self.view?.presentScene(gameplay!, transition: SKTransition.doorway(withDuration: TimeInterval(1.5)))
            }

        }
        
        //check if player is able to jump prior to calling jump function
        if canJump{
            //set false so cant jump multiple times
            canJump = false
            player.jump()
        }
        //ensures player can jump off of obstacles
        if playerOnObstacle{
            player.jump()
        }
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody  = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        //check if firstbody is the player
        if contact.bodyA.node?.name == "Player"{
            
            firstBody  = contact.bodyA
            secondBody = contact.bodyB
            
        } else {
            
            firstBody  = contact.bodyB
            secondBody = contact.bodyA
        }
        
        //if player is in contact with the ground the player can jump
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Ground"{
            canJump = true
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle"{
            
            //if we are on top of obstacle and not the ground change jump condition
            //this enables us to jump off of obstacles so we arent dragged off the screen
            if !canJump {
                //enable player to "stick" to obstacles when jumping on top of them
                movePlayer       = true
                //enable player to jump off of obstacles
                playerOnObstacle = true
                
            }
            
        }
        
        if firstBody.node?.name == "Player" && secondBody.node?.name == "Cactus"{
            //kill the player and prompt buttons
            playerDied()
            
        }
        
            
    }
    
    //check if contact with obstacle has ended, reverse booleans to disable unwated actions
    func didEnd(_ contact: SKPhysicsContact) {
        var firstBody  = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
        
        //make sure firstbody is the player
        if contact.bodyA.node?.name == "Player"{
            firstBody  = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody  = contact.bodyB
            secondBody = contact.bodyA
        }

        if firstBody.node?.name == "Player" && secondBody.node?.name == "Obstacle"{
            movePlayer       = false
            playerOnObstacle = false
        }
    }
    

    
    //intialize scene components
    func initialize(){
        
        
        physicsWorld.contactDelegate = self;
        //set player condition to alive
        isAlive = true
        
        createPlayer()
        createBG()
        createGrounds()
        createObstacles()
        getLabel()
        //infintly spawn obstacles every x amount of seconds
        spawner = Timer.scheduledTimer(timeInterval: TimeInterval(randomBetweenNumbers(firstNumber: 2, secondNumber: 5)), target: self, selector: #selector(spawnObstacles), userInfo: nil, repeats: true)
        //increment score
        counter = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementScore), userInfo: nil, repeats: true)
    }
    
    //initialize a player
    func createPlayer(){
        player = Player(imageNamed: "Player 1")
        player.initialize()
        player.position = CGPoint(x: -10, y: 20)
        self.addChild(player)
    }
    
    //create background of scene
    func createBG(){
        for i in 0...2 {
            let bg = SKSpriteNode(imageNamed: "BG")
            bg.name = "BG"
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
            bg.physicsBody = SKPhysicsBody(rectangleOf: bg.size)
            bg.physicsBody?.affectedByGravity = false
            bg.physicsBody?.isDynamic = false
            bg.physicsBody?.categoryBitMask = ColliderType.Ground
            self.addChild(bg)
        }
    }
    
    //infinite scroll for background and grounds
    func infiniteScrollBackgrounds(){
        //scrolling for the main background
        enumerateChildNodes(withName: "BG", using: ({
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
    
    
    //create obstacles
    func createObstacles(){
        
        //loop through and create obstacles and append them to the obstacles array
        for i in 0...5{
            
            let obstacle = SKSpriteNode(imageNamed: "Obstacle \(i)");
            
            //if item is a cactus set name and scale differently
            if i == 0 {
                obstacle.name = "Cactus"
                obstacle.setScale(0.4)
                
            } else {
                
                obstacle.name = "Obstacle"
                obstacle.setScale(0.5)
            }
                obstacle.anchorPoint = CGPoint(x: 0.5, y: 0.5)
                obstacle.zPosition = 1
                
                obstacle.physicsBody = SKPhysicsBody(rectangleOf: obstacle.size)
                obstacle.physicsBody?.allowsRotation = false
                obstacle.physicsBody?.categoryBitMask = ColliderType.Obstacle
                
                obstacles.append(obstacle)
        }
    }
    
    //spawn obstacles randomly in scene
    func spawnObstacles(){
        
        //return random number from obstacles.count
        let index = Int(arc4random_uniform(UInt32(obstacles.count)))
        
        //create obstacle passing in random index from above
        //create a copy so we dont hav two of the same nodes on screen causing app to crash
        let obstacle = obstacles[index].copy() as! SKSpriteNode
        
        obstacle.position = CGPoint(x: self.frame.width + obstacle.size.width, y: 50)
        
        let move = SKAction.moveTo(x: -(self.frame.size.width * 2), duration: TimeInterval(15))
        
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([move, remove])
        
        obstacle.run(sequence)
        
        self.addChild(obstacle)
        
        
    }
    
    //called on obstacle spawn to randomize spawning times
    func randomBetweenNumbers(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat{
        
        //arc4random returns a number between 0 to (2*32) - 1
        return CGFloat(arc4random()) / CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
        
    }
    
    //check if player has moved off the screen
    func checkPlayersbounds(){
        //if player is alive check bounds
        if isAlive{
            if player.position.x < -(self.frame.size.width / 2) - 35 {
                playerDied()
            }
        }
        
    }
    
    func getLabel(){
        
        scoreLabel = self.childNode(withName: "Score Label") as! SKLabelNode
        scoreLabel.fontName = "RosewoodStd-Regular"
        scoreLabel.text = "0M"
        
    }
    
    func incrementScore(){
        score += 1
        scoreLabel.text = "\(score)M"
    }
    
    //player death
    func playerDied(){
        
        let highscore = UserDefaults.standard.integer(forKey: "Highscore")
        
        if highscore < score {
            UserDefaults.standard.set(score, forKey: "Highscore")
        }
        
        //remove player from the scene
        player.removeFromParent()
        
        //remove any obstacles left in the scene upon player death
        for child in children {
            
            if child.name == "Obstacle" || child.name == "Cactus"{
                child.removeFromParent()
            }
            
        }
        
        //turns of timer that spawns obstacles
        spawner.invalidate()
        //stop incrementing score upon death
        counter.invalidate()
        
        isAlive = false
        
        let restart = SKSpriteNode(imageNamed: "Restart")
        let quit    = SKSpriteNode(imageNamed: "Quit")
        
        restart.name = "Restart"
        restart.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        restart.position = CGPoint(x: -200, y: -150)
        restart.zPosition = 10
        restart.setScale(0)
        
        quit.name = "Quit"
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        quit.position = CGPoint(x: 200, y: -150)
        quit.zPosition = 10
        quit.setScale(0)
        
        let scaleUp = SKAction.scale(to: 1, duration: TimeInterval(0.5))
        restart.run(scaleUp)
        quit.run(scaleUp)
        
        self.addChild(restart)
        self.addChild(quit)
    }
    
    
    func createPausePanel(){
        
        //turns of timer that spawns obstacles
        spawner.invalidate()
        //stop incrementing score upon death
        counter.invalidate()
        
        self.scene?.isPaused = true
        
        pausePanel = SKSpriteNode(imageNamed: "Pause Panel")
        
        pausePanel.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        pausePanel.position = CGPoint(x: 0, y: 0)
        pausePanel.zPosition = 10
        
        let resume = SKSpriteNode(imageNamed: "Play")
        let quit = SKSpriteNode(imageNamed: "Quit")
        
        resume.name = "Resume"
        resume.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        resume.position = CGPoint(x: -155, y: 0)
        resume.zPosition = 9
        resume.setScale(0.75)
        
        quit.name = "Quit"
        quit.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        quit.position = CGPoint(x: 155, y: 0)
        quit.zPosition = 9
        quit.setScale(0.75)
        
        pausePanel.addChild(resume)
        pausePanel.addChild(quit)
        
        self.addChild(pausePanel)

    }
    
    
    
    
    
 
//end of class
}
