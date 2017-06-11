//
//  GameScene.swift
//  Flappy
//
//  Created by 李文慈 on 2017/5/22.
//  Copyright © 2017年 lulu. All rights reserved.
//

import SpriteKit
import GameplayKit

struct Localscore {
    static let keyOne = "Highscore stored in local"
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var leftCar = SKSpriteNode()
    var rightCar = SKSpriteNode()
    
    var canMove = true
    var leftCarToMoveleft = true
    var rightCarToMoveright = true
    var leftCarAtright = false
    var rightCarAtleft = false
    var CenterPoint: CGFloat!
    
    let leftCarminimumX: CGFloat = -280
    let leftCarmaximumX:CGFloat = -100
    let rightCarminimumX: CGFloat = 100
    let rightCarmaximumX:CGFloat = 280
    
    var stopEverything = false
    var score = 0
    var scoreText = SKLabelNode()
    var gameSetting = Setting.sharedInstance
    
    var backgroundmusic: SKAudioNode!
    var stop: Bool!
    
    var GasLabel = SKLabelNode()
    var Gas = 10
    var fullGas : Bool = false
    var gasTimer: Timer?
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint (x: 0.5, y: 0.5)
        setup()
        physicsWorld.contactDelegate = self
        Timer.scheduledTimer(timeInterval: TimeInterval(0.1), target: self, selector: #selector(GameScene.createline), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.leftItems), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(Helper().randomBetweenTwoNumbers(firstNumber: 0.8, secondNumber: 1.8)), target: self, selector: #selector(GameScene.rightItems), userInfo: nil, repeats: true)
        Timer.scheduledTimer(timeInterval: TimeInterval(0.5), target: self, selector: #selector(GameScene.remove), userInfo: nil, repeats: true)
        let deadTime = DispatchTime.now() + 1
        DispatchQueue.main.asyncAfter(deadline: deadTime)
        {
            Timer.scheduledTimer(timeInterval:  TimeInterval(1),target: self, selector: #selector(GameScene.increaseScore), userInfo: nil, repeats: true)
        }
        startGasTimer()
        
        stop = false
        if let musicURL = Bundle.main.url(forResource: "music", withExtension: "mp3")
        {
            backgroundmusic = SKAudioNode(url: musicURL)
            addChild(backgroundmusic)
        }
        //print("-----initial stopEverything-----")
        //print(stopEverything)
        //print("--------------------------------")
    }
    
    override func update(_ currentTime: TimeInterval) {
        if canMove
        {
            moveleftCar(leftSide: leftCarToMoveleft)
            moverightCar(rightSide: rightCarToMoveright)
        }
        showline()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody = SKPhysicsBody()
        var secondBody = SKPhysicsBody()
      
        if contact.bodyA.node?.name == "leftCar" || contact.bodyA.node?.name == "rightCar"
        {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        }
        else
        {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
    
        if firstBody.node?.name == "leftCar" && secondBody.node?.name == "orangeCar"
        {
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            afterCollision()
        }
        else if firstBody.node?.name == "rightCar" && secondBody.node?.name == "orangeCar"
        {
            firstBody.node?.removeFromParent()
            secondBody.node?.removeFromParent()
            afterCollision()
        }
        else if firstBody.node?.name == "leftCar" && secondBody.node?.name == "greenCar"
        {
            if Gas >= 10
            {
                Gas = 10
                gasTimer?.invalidate()
                startGasTimer()
            }
            else
            {
                Gas += 1
            }
            GasLabel.text = String(Gas)
            secondBody.node?.removeFromParent()
        }
        else if firstBody.node?.name == "rightCar" && secondBody.node?.name == "greenCar"
        {
            if Gas >= 10
            {
                Gas = 10
                gasTimer?.invalidate()
                startGasTimer()
            }
            else
            {
                Gas += 1
            }
            GasLabel.text = String(Gas)
            secondBody.node?.removeFromParent()
        }
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            if touchLocation.x > CenterPoint
            {
                if rightCarAtleft
                {
                    rightCarAtleft = false
                    rightCarToMoveright = true
                }
                else
                {
                    rightCarAtleft = true
                    rightCarToMoveright = false
                }
            }
            else
            {
                if leftCarAtright
                {
                    leftCarAtright = false
                    leftCarToMoveleft = true
                }
                else
                {
                    leftCarAtright = true
                    leftCarToMoveleft = false
                }

            }
        canMove = true
        }
    }
    
    func setup()
    {
        leftCar = self.childNode(withName: "leftCar") as! SKSpriteNode
        rightCar = self.childNode(withName: "rightCar") as! SKSpriteNode
        CenterPoint = self.frame.size.width / self.frame.size.height
        
        leftCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        leftCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER
        leftCar.physicsBody?.collisionBitMask = 0
        
        rightCar.physicsBody?.categoryBitMask = ColliderType.CAR_COLLIDER
        rightCar.physicsBody?.contactTestBitMask = ColliderType.ITEM_COLLIDER_1
        rightCar.physicsBody?.collisionBitMask = 0
        
        let scoreBackGround = SKShapeNode(rect: CGRect(x: -self.size.width/2 + 70, y: self.size.height/2 - 130, width: 180, height: 80), cornerRadius: 20)
        scoreBackGround.zPosition = 4
        scoreBackGround.fillColor = SKColor.black.withAlphaComponent(0.3)
        scoreBackGround.strokeColor = SKColor.black.withAlphaComponent(0.3)
        addChild(scoreBackGround)
        
        scoreText.name = "score"
        scoreText.fontName = "AvenirNext-Bold"
        scoreText.text = "0"
        scoreText.fontColor = SKColor.white
        scoreText.position = CGPoint(x: -self.size.width/2 + 160, y:self.size.height/2 - 110)
        scoreText.fontSize = 60
        scoreText.zPosition = 4
        addChild(scoreText)
        
        GasLabel = childNode(withName: "GasLabel") as! SKLabelNode!
        
    }
    //中間的線
    func createline()
    {
        let leftline = SKShapeNode(rectOf: CGSize(width: 10,height: 40))
        leftline.strokeColor = SKColor.white
        leftline.fillColor = SKColor.white
        leftline.alpha = 0.4
        leftline.name = "leftline"
        leftline.zPosition = 10
        leftline.position.x = -187.5
        leftline.position.y = 700
        addChild(leftline)
        
        let rightline = SKShapeNode(rectOf: CGSize(width: 10,height: 40))
        rightline.strokeColor = SKColor.white
        rightline.fillColor = SKColor.white
        rightline.alpha = 0.4
        rightline.name = "rightline"
        rightline.zPosition = 10
        rightline.position.x = 187.5
        rightline.position.y = 700
        addChild(rightline)
    }
    
    func showline()
    {
        enumerateChildNodes(withName: "leftline", using: {(roadline, stop) in
        let line = roadline as! SKShapeNode
        line.position.y -= 30
        })
        enumerateChildNodes(withName: "rightline", using: {(roadline, stop) in
            let line = roadline as! SKShapeNode
            line.position.y -= 30
        })
        enumerateChildNodes(withName: "orangeCar", using: {(leftCar, stop) in
            let car = leftCar as! SKSpriteNode
            if self.score < 15 {
                car.position.y -= 15
            }
            else if self.score >= 15 && self.score < 30 {
                car.position.y -= 20
            }
            else if self.score >= 30 && self.score < 60 {
                car.position.y -= 25
            }
            else {
                car.position.y -= 30
            }
        })
        enumerateChildNodes(withName: "greenCar", using: {(rightCar, stop) in
            let car = rightCar as! SKSpriteNode
            if self.score < 15 {
                car.position.y -= 15
            }
            else if self.score >= 15 && self.score < 30 {
                car.position.y -= 20
            }
            else if self.score >= 30 && self.score < 60 {
                car.position.y -= 25
            }
            else {
                car.position.y -= 30
            }
        })
    }
    
    func remove()
    {
        for child in children
        {
            if child.position.y < -self.size.height - 100
            {
                child.removeFromParent()
            }
        }
    }
    //leftcar wont get out of screen
    func moveleftCar(leftSide: Bool)
    {
        if leftSide
        {
            leftCar.position.x -= 20
            if leftCar.position.x < leftCarminimumX
            {
                leftCar.position.x = leftCarminimumX
            }
        }
        else
        {
            leftCar.position.x += 20
            if leftCar.position.x > leftCarmaximumX
            {
                leftCar.position.x = leftCarmaximumX
            }
        }
    }
    //rightcar wont get out of screen
    func moverightCar(rightSide: Bool)
    {
        if rightSide
        {
            rightCar.position.x -= 20
            if rightCar.position.x < rightCarminimumX
            {
                rightCar.position.x = rightCarminimumX
            }
        }
        else
        {
            rightCar.position.x += 20
            if rightCar.position.x > rightCarmaximumX
            {
                rightCar.position.x = rightCarmaximumX
            }
        }
    }
    //左障礙車
    func leftItems()
    {
        let leftitem: SKSpriteNode
        let randomNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
        switch Int(randomNumber)
        {
            case 1...6:
                leftitem = SKSpriteNode(imageNamed: "orangeCar")
                leftitem.name = "orangeCar"
            break
            case 7...10:
            leftitem = SKSpriteNode(imageNamed: "greenCar")
            leftitem.name = "greenCar"
            break

            default:
                leftitem = SKSpriteNode(imageNamed: "orangeCar")
                leftitem.name = "orangeCar"
        }
        leftitem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        leftitem.zPosition = 10
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 4)
        switch Int(randomNum)
        {
            case 1...2:
            leftitem.position.x = -280
            break
            case 3...4:
            leftitem.position.x = -100
            break
            default:
            leftitem.position.x = -280
            break
        }
        leftitem.position.y = 700
        leftitem.physicsBody = SKPhysicsBody(circleOfRadius: leftitem.size.height / 2)
        leftitem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER
        leftitem.physicsBody?.collisionBitMask = 0
        leftitem.physicsBody?.affectedByGravity = false
        addChild(leftitem)
    }
    //右障礙車
    func rightItems()
    {
        let rightitem: SKSpriteNode
        let randomNumber = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 10)
        switch Int(randomNumber)
        {
        case 1...6:
            rightitem = SKSpriteNode(imageNamed: "orangeCar")
            rightitem.name = "orangeCar"
            break
        case 7...10:
            rightitem = SKSpriteNode(imageNamed: "greenCar")
            rightitem.name = "greenCar"
            break

        default:
            rightitem = SKSpriteNode(imageNamed: "orangeCar")
            rightitem.name = "orangeCar"
        }
        rightitem.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        rightitem.zPosition = 10
        let randomNum = Helper().randomBetweenTwoNumbers(firstNumber: 1, secondNumber: 4)
        switch Int(randomNum)
        {
        case 1...2:
            rightitem.position.x = 280
            break
        case 3...4:
            rightitem.position.x = 100
            break
        default:
            rightitem.position.x = 280
            break
        }
        rightitem.position.y = 700
        rightitem.physicsBody = SKPhysicsBody(circleOfRadius: rightitem.size.height / 2)
        rightitem.physicsBody?.categoryBitMask = ColliderType.ITEM_COLLIDER_1
        rightitem.physicsBody?.collisionBitMask = 0
        rightitem.physicsBody?.affectedByGravity = false
        addChild(rightitem)
    }
    
    func afterCollision()
    {
        stopEverything = true
        if gameSetting.highScore < score
        {
            gameSetting.highScore = score
        }
        //print("-----afterCollision stopeverything----")
        //print(stopEverything)
        //print("-------------------")
        print("-----highscore-----")
        print(gameSetting.highScore)
        print("-------------------")
        let defaults = UserDefaults.standard
        defaults.set(gameSetting.highScore, forKey: Localscore.keyOne)
        
        let menuScene = SKScene(fileNamed: "GameMenu")!
        menuScene.scaleMode = .aspectFill
        view?.presentScene(menuScene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(2)))
        //print(score)
        //print(gameSetting.highScore)
    }
    
    func increaseScore()
    {
        if !stopEverything
        {
            score += 1
            scoreText.text = String(score)
        }
    }
    
    func startGasTimer(){
        gasTimer = Timer.scheduledTimer(timeInterval: TimeInterval(3), target: self, selector: #selector(GameScene.gaslimit), userInfo: nil, repeats: true)
    }
    
    func gaslimit()
    {
        if !stopEverything
        {
            Gas -= 1
            GasLabel.text = String(Gas)
        }
        if Gas == 0
        {
            afterCollision()
        }
    }
}
