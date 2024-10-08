import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var player: SKSpriteNode!
    var tileMap: SKTileMapNode!
    var joystickBase: SKSpriteNode!
    var joystickThumb: SKSpriteNode!
    var joystickIsActive = false
    var playerVelocity = CGVector.zero
    var cameraNode: SKCameraNode!  // Tambahkan kamera node
    
    private var lastUpdateTime: TimeInterval = 0

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Konversi lokasi sentuhan relatif terhadap kamera
            let location = touch.location(in: cameraNode)
            
            // Activate joystick if touch is within the joystick base
            if joystickBase.contains(location) {
                joystickIsActive = true
                joystickThumb.position = joystickBase.position // Reset thumb position
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            // Konversi lokasi sentuhan relatif terhadap kamera
            let location = touch.location(in: cameraNode)

            if joystickIsActive {
                // Calculate vector from joystick base to touch point
                let vector = CGVector(dx: location.x - joystickBase.position.x, dy: location.y - joystickBase.position.y)
                let angle = atan2(vector.dy, vector.dx)  // Calculate the angle of the joystick movement
                let radius: CGFloat = joystickBase.frame.size.height / 2  // Radius within which the thumb can move

                let distance = min(sqrt(vector.dx * vector.dx + vector.dy * vector.dy), radius)  // Limit distance to joystick radius

                let xDist = cos(angle) * distance
                let yDist = sin(angle) * distance

                // Set joystick thumb position, limited by the joystick base radius
                joystickThumb.position = CGPoint(x: joystickBase.position.x + xDist, y: joystickBase.position.y + yDist)

                // Set velocity for player movement based on the joystick vector
                let normalizedVector = CGVector(dx: xDist / radius, dy: yDist / radius)  // Normalized for uniform speed
                let speedMultiplier: CGFloat = 200  // Adjust this value for speed
                playerVelocity = CGVector(dx: normalizedVector.dx * speedMultiplier, dy: normalizedVector.dy * speedMultiplier)
            }
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        joystickIsActive = false
        joystickThumb.position = joystickBase.position  // Reset joystick thumb position
        playerVelocity = CGVector.zero  // Stop movement
    }

    override func didMove(to view: SKView) {
        self.lastUpdateTime = 0

        // Referensi node dari GameScene.sks
        player = self.childNode(withName: "player") as? SKSpriteNode
        joystickBase = self.childNode(withName: "joystickBase") as? SKSpriteNode
        joystickThumb = self.childNode(withName: "joystickThumb") as? SKSpriteNode
        tileMap = self.childNode(withName: "tileMap") as? SKTileMapNode

        // Pastikan joystick, player, dan tile map ditemukan
        if joystickBase == nil || joystickThumb == nil || player == nil || tileMap == nil {
            print("Error: Joystick, player, atau tileMap tidak ditemukan di GameScene.sks")
            return
        }

        // Setup kamera
        cameraNode = SKCameraNode() // Buat SKCameraNode
        self.camera = cameraNode // Set kamera untuk scene
        addChild(cameraNode) // Tambahkan kamera ke scene
        
        // Remove joystickBase dan joystickThumb dari parent sebelumnya sebelum menambahkannya ke cameraNode
        joystickBase.removeFromParent()
        joystickThumb.removeFromParent()
        
        // Tambahkan joystick sebagai child dari cameraNode agar posisinya relatif terhadap kamera
        cameraNode.addChild(joystickBase)
        cameraNode.addChild(joystickThumb)

        // Set transparansi jika diperlukan
        joystickBase.alpha = 0.5
        joystickThumb.alpha = 0.7

        // Tempatkan player di tengah tile map
        player.position = CGPoint(x: tileMap.frame.midX, y: tileMap.frame.midY) // Posisikan player di tengah map

        joystickThumb.position = joystickBase.position // Mulai dari tengah base
    }

    override func update(_ currentTime: TimeInterval) {
        // Calculate delta time
        let deltaTime = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Calculate new player position
        let newPlayerX = player.position.x + playerVelocity.dx * CGFloat(deltaTime)
        let newPlayerY = player.position.y + playerVelocity.dy * CGFloat(deltaTime)
        
        // Calculate map boundaries based on tile map size
        let mapMinX = tileMap.frame.minX + player.size.width / 2
        let mapMaxX = tileMap.frame.maxX - player.size.width / 2
        let mapMinY = tileMap.frame.minY + player.size.height / 2
        let mapMaxY = tileMap.frame.maxY - player.size.height / 2

        // Clamp player position within the map boundaries
        player.position = CGPoint(x: clamp(value: newPlayerX, min: mapMinX, max: mapMaxX), y: clamp(value: newPlayerY, min: mapMinY, max: mapMaxY))
        
        // Flip the player based on direction
        if playerVelocity.dx > 0 {
            player.xScale = abs(player.xScale) // Gerakan ke kanan, pastikan xScale positif
        } else if playerVelocity.dx < 0 {
            player.xScale = -abs(player.xScale) // Gerakan ke kiri, pastikan xScale negatif
        }

        // Update the camera to follow the player with boundary limits
        updateCameraPosition()
    }
    
    // Function to update the camera's position and apply boundaries
    func updateCameraPosition() {
        // Calculate camera boundaries
        let mapMinX = tileMap.frame.minX + self.size.width / 2
        let mapMaxX = tileMap.frame.maxX - self.size.width / 2
        let mapMinY = tileMap.frame.minY + self.size.height / 2
        let mapMaxY = tileMap.frame.maxY - self.size.height / 2
        
        // Clamp camera position to ensure it stays within the map boundaries
        cameraNode.position.x = clamp(value: player.position.x, min: mapMinX, max: mapMaxX)
        cameraNode.position.y = clamp(value: player.position.y, min: mapMinY, max: mapMaxY)
    }
    
    // Utility function to clamp values within a range
    func clamp(value: CGFloat, min: CGFloat, max: CGFloat) -> CGFloat {
        return Swift.min(max, Swift.max(min, value))
    }

}
