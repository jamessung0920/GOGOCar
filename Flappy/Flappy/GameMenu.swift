//
//  GameMenu.swift
//  Flappy
//
//  Created by 李文慈 on 2017/5/23.
//  Copyright © 2017年 lulu. All rights reserved.
//

import Foundation
import SpriteKit

class GameMenu: SKScene
{
    var startGame = SKLabelNode()
    var bestScore = SKLabelNode()
    var gameSetting = Setting.sharedInstance
    
    override func didMove(to view: SKView) {
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        startGame = self.childNode(withName: "startGame") as! SKLabelNode
        bestScore = self.childNode(withName: "bestScore") as! SKLabelNode
        bestScore.text = "Best : \(gameSetting.highScore)"

    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches
        {
            let touchLocation = touch.location(in: self)
            if atPoint(touchLocation).name == "startGame"
            {
                let gameScene = SKScene(fileNamed: "GameScene")!
                gameScene.scaleMode = .aspectFill
                view?.presentScene(gameScene, transition: SKTransition.doorsOpenHorizontal(withDuration: TimeInterval(2)))
            }
        }
    }
}
