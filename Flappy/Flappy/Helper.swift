//
//  Helper.swift
//  Flappy
//
//  Created by 李文慈 on 2017/5/22.
//  Copyright © 2017年 lulu. All rights reserved.
//

import Foundation
import UIKit

struct ColliderType {
    static let CAR_COLLIDER: UInt32 = 0
    static let ITEM_COLLIDER: UInt32 = 1
    static let ITEM_COLLIDER_1: UInt32 = 2
    
}
class Helper: NSObject
{
    func randomBetweenTwoNumbers(firstNumber: CGFloat, secondNumber: CGFloat) -> CGFloat{
        return CGFloat(arc4random())/CGFloat(UINT32_MAX) * abs(firstNumber - secondNumber) + min(firstNumber, secondNumber)
    }
}
class Setting
{
    static let sharedInstance = Setting()
    private init()
    {
        
    }
    var highScore = 0
}

