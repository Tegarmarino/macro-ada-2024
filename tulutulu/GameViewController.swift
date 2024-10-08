//
//  GameViewController.swift
//  CobaTulu
//
//  Created by Vanessa on 04/10/24.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController, GameSceneDelegate {
    
    private var healthLabel: UILabel!
    private var health = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as? SKView {
            if let scene = SKScene(fileNamed: "GameScene") {
                scene.scaleMode = .aspectFill
                (scene as? GameScene)?.gameDelegate = self
                view.presentScene(scene)
            } else {
                let scene = GameScene(size: view.bounds.size)
                scene.scaleMode = .aspectFill
                (scene as? GameScene)?.gameDelegate = self
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = true
            view.showsNodeCount = true
        }
        
        setupHealthLabel()
    }
    
    private func setupHealthLabel() {
        healthLabel = UILabel(frame: CGRect(x: 20, y: 40, width: 200, height: 40))
        healthLabel.font = UIFont.systemFont(ofSize: 24)
        healthLabel.textColor = .red
        healthLabel.text = "Health: \(health)"
        view.addSubview(healthLabel)
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func updateHealthUI(newHealth: Int) {
        healthLabel.text = "Health: \(newHealth)"
        
        if newHealth <= 0 {
            showGameOverAlert()
        }
    }
    
    private func showGameOverAlert() {
        let alert = UIAlertController(title: "Game Over", message: "Health Anda habis!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

