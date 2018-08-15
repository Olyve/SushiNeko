//
//  GameScene.swift
//  SushiNeko
//
//  Created by Sam Galizia on 8/13/18.
//  Copyright © 2018 Sam Galizia. All rights reserved.
//

import SpriteKit

// Tracking enum for use with the character and sushi side
enum Side {
  case left, right, none
}

// Enum to track state of the game
enum GameState {
  case title, ready, playing, gameOver
}

class GameScene: SKScene {
  // Game Objects
  var sushiBasePiece: SushiPiece!
  var character: Character!
  var sushiTower: [SushiPiece] = []
  var playButton: MSButtonNode!
  var healthBar: SKSpriteNode!
  var scoreLabel: SKLabelNode!
  
  // Game Management
  var state: GameState = .title
  var health: CGFloat = 1.0 {
    didSet {
      // Cap health at 100%
      if health > 1.0 { health = 1.0 }
      
      // Scale health bar between 0.0 & 1.0
      healthBar.xScale = health
    }
  }
  var score: Int = 0 {
    didSet {
      scoreLabel.text = String(score)
    }
  }
  
  override func didMove(to view: SKView) {
    super.didMove(to: view)
    
    // Connect Game Objects
    sushiBasePiece = childNode(withName: "sushiBasePiece") as! SushiPiece
    character = childNode(withName: "character") as! Character
    playButton = childNode(withName: "playButton") as! MSButtonNode
    healthBar = childNode(withName: "healthBar") as! SKSpriteNode
    scoreLabel = childNode(withName: "scoreLabel") as! SKLabelNode
    
    // Setup chopsticks connection
    sushiBasePiece.connectChopsticks()
    
    // Manually stack the start of the tower
    addTowerPiece(side: .none)
    addTowerPiece(side: .right)
    addRandomPieces(total: 10)
    
    // Setup play button selection handler
    playButton.selectedHandler = {
      // Start game
      self.state = .ready
    }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    // Game not ready to play
    if state == .gameOver || state == .title { return }
    
    // Game begins on first touch
    if state == .ready { state = .playing }
    
    let touch = touches.first!
    let location = touch.location(in: self)
    
    // Check if the touch was on the left or right side
    if location.x > size.width / 2 {
      character.side = .right
    } else {
      character.side = .left
    }
    
    // Grab sushi piece on top of base piece, it will always be first
    if let firstPiece = sushiTower.first as SushiPiece? {
      // Check character side against sushi piece side (death check)
      if character.side  == firstPiece.side {
        gameOver()
        
        // No need to continue, player is dead
        return
      }
      
      // Increment health and score
      health += 0.1
      score += 1
      
      // Remove from sushi tower array
      sushiTower.removeFirst()
      firstPiece.flip(character.side)
      
      // Add new sushi piece to top of tower
      addRandomPieces(total: 1)
    }
  }
  
  override func update(_ currentTime: TimeInterval) {
    // Called before each frame is rendered
    if state != .playing { return }
    
    // Decrease Health
    health -= 0.01
    
    if health < 0 {
      gameOver()
    }
    
    // Move Tower Down
    moveTowerDown()
  }

  // MARK - Game Management
  func gameOver() {
    state = .gameOver
    
    // Create turnRed SKAction
    let turnRed = SKAction.colorize(with: .red, colorBlendFactor: 1.0, duration: 0.5)
    
    // Turn all the sushi pieces red
    sushiBasePiece.run(turnRed)
    for sushiPiece in sushiTower {
      sushiPiece.run(turnRed)
    }
    
    // Turn player red
    character.run(turnRed)
    
    // Change playButton selection handler
    playButton.selectedHandler = {
      let skView = self.view as SKView?
      
      guard let scene = GameScene(fileNamed: "GameScene") as GameScene? else {
        return
      }
      
      // Ensure correct aspect mode
      scene.scaleMode = .aspectFill
      
      // Restart Game Scene
      skView?.presentScene(scene)
    }
  }

  // MARK - Tower Helpers
  func addTowerPiece(side: Side) {
    // Copy original piece
    let newPiece = sushiBasePiece.copy() as! SushiPiece
    newPiece.connectChopsticks()
    
    // Access last piece properties
    let lastPiece = sushiTower.last
    
    // Add on top of last piece, default on base piece
    let lastPosition = lastPiece?.position ?? sushiBasePiece.position
    newPiece.position.x = lastPosition.x
    newPiece.position.y = lastPosition.y + 55
    
    // Increment Z Position to ensure its on top of last piece
    let lastZPosition = lastPiece?.zPosition ?? sushiBasePiece.zPosition
    newPiece.zPosition = lastZPosition + 1
    
    // Set side
    newPiece.side = side
    
    // Add sushi to scene
    addChild(newPiece)
    
    // Add sushi piece to the tower
    sushiTower.append(newPiece)
  }
  
  func addRandomPieces(total: Int) {
    for _ in 1...total {
      // Need to access last sushi piece
      let lastPiece = sushiTower.last!
      
      // Make sure we don't create an impossible tower
      if lastPiece.side != .none {
        addTowerPiece(side: .none)
      } else {
        // Random number generator
        let rand = arc4random_uniform(100)
        
        if rand < 45 {
          // 45% chance of left piece
          addTowerPiece(side: .left)
        } else if rand < 90 {
          // 45% chance of right piece
          addTowerPiece(side: .right)
        } else {
          // 10% chance of no sides
          addTowerPiece(side: .none)
        }
      }
    }
  }
  
  func moveTowerDown() {
    var n: CGFloat = 0
    for piece in sushiTower {
      let y = (n * 55) + 215
      piece.position.y -= (piece.position.y - y) * 0.5
      n += 1
    }
  }
}
