//
//  GameScene.swift
//  CobaTulu
//
//  Created by Vanessa on 04/10/24.
//

import SpriteKit
import GameplayKit
protocol GameSceneDelegate: AnyObject {
    func updateHealthUI(newHealth: Int)
}
class GameScene: SKScene {
    
    private var tulu: SKSpriteNode!
    private var player: SKSpriteNode!
    private var health = 3
    weak var gameDelegate: GameSceneDelegate?
    private var isInCollision = false
    private var timeInCollision: TimeInterval = 0
    private let collisionThreshold: TimeInterval = 1.0
    
    override func didMove(to view: SKView) {
        
        tulu = SKSpriteNode(imageNamed: "tulu")
        tulu.size = CGSize(width: 100, height: 100)
        tulu.position = CGPoint(x: 100, y: 100)
        
        player = SKSpriteNode(imageNamed: "player")
        player.size = CGSize(width: 100, height: 100)
        player.position = CGPoint(x: 300, y: 300)

        addChild(tulu)
        addChild(player)

        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.wait(forDuration: 2.0),
            SKAction.run { [weak self] in
                self?.moveTuluTowardsPlayer()
            }
        ])))
    }
    
    // Pindahkan pengecekan collision ke dalam fungsi update
    override func update(_ currentTime: TimeInterval) {
        checkCollision(currentTime)
    }
    
    private func moveTuluTowardsPlayer() {
        guard let tulu = tulu, let player = player else { return }
        
        // Implementasi A* Search
        let path = aStarSearch(start: tulu.position, goal: player.position)
        
        if let targetPosition = path.first {
            let moveAction = SKAction.move(to: targetPosition, duration: 1.0)
            tulu.run(moveAction)
        }
    }
    
    private func aStarSearch(start: CGPoint, goal: CGPoint) -> [CGPoint] {
        return [goal]
    }
    
    private func checkCollision(_ currentTime: TimeInterval) {
        if tulu.frame.intersects(player.frame) {
            // Jika mereka bertabrakan dan belum ada timer berjalan
            if !isInCollision {
                isInCollision = true
                timeInCollision = currentTime // Simpan waktu ketika collision dimulai
            } else {
                // Jika collision sudah terjadi, hitung durasi collision
                let timeElapsed = currentTime - timeInCollision
                if timeElapsed >= collisionThreshold {
                    reduceHealth()
                    timeInCollision = currentTime
                }
            }
        } else {
            isInCollision = false
        }
    }

    private func reduceHealth() {
        if health > 0 {
            health -= 1
            gameDelegate?.updateHealthUI(newHealth: health)
            
            if health == 0 {
                gameOver()
            }
        }
    }
    
    // Fungsi untuk menangani game over
    private func gameOver() {
        let gameOverLabel = SKLabelNode(text: "Game Over")
        gameOverLabel.fontSize = 50
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        addChild(gameOverLabel)
        
        isPaused = true // Berhenti game
    }
    
    // Fungsi untuk mendeteksi sentuhan di layar
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.location(in: self)
            let moveAction = SKAction.move(to: location, duration: 0.3)
            player.run(moveAction)
        }
    }
    
}







