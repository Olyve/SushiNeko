//
//  Character.swift
//  SushiNeko
//
//  Created by Sam Galizia on 8/14/18.
//  Copyright © 2018 Sam Galizia. All rights reserved.
//

import SpriteKit

class Character: SKSpriteNode {
  let punch = SKAction(named: "punch")!
  
  /* Character Side */
  var side: Side = .left {
    didSet {
      if side == .left {
        xScale = 1
        position.x = 70
      } else {
        xScale = -1
        position.x = 252
      }
      
      // Run the punch action
      run(punch)
    }
  }
  
  override init(texture: SKTexture?, color: UIColor, size: CGSize) {
    super.init(texture: texture, color: color, size: size)
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
}
