//
//  SushiPiece.swift
//  SushiNeko
//
//  Created by Sam Galizia on 8/14/18.
//  Copyright © 2018 Sam Galizia. All rights reserved.
//

import SpriteKit

class SushiPiece: SKSpriteNode {
  var rightChopstick: SKSpriteNode!
  var leftChopstick: SKSpriteNode!
  
  var side: Side = .none {
    didSet {
      switch side {
      case .left:
        // Show left chopstick
        leftChopstick.isHidden = false
      case .right:
        // Show right chopstick
        rightChopstick.isHidden = false
      case .none:
        leftChopstick.isHidden = true
        rightChopstick.isHidden = true
      }
    }
  }
  
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  func connectChopsticks() {
    rightChopstick = childNode(withName: "rightChopstick") as! SKSpriteNode
    leftChopstick = childNode(withName: "leftChopstick") as! SKSpriteNode
    
    // Set the default side
    side = .none
  }
  
  func flip(_ side: Side) {
    //Flip the sushi out of the screen
    var actionName = ""
    
    if side == .left {
      actionName = "flipRight"
    } else if side == .right {
      actionName = "flipLeft"
    }
    
    // Load the appropriate action
    let flip = SKAction(named: actionName)!
    let remove = SKAction.removeFromParent()
    let sequence = SKAction.sequence([flip, remove])
    run(sequence)
  }
}
