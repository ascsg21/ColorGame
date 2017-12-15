//
//  GameScene.swift
//  ColorGame
//
//  Created by MinRiDaddy on 2017. 12. 2..
//  Copyright © 2017년 MinRiDaddy. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // 트랙 배열
    var tracksArray:[SKSpriteNode]? = [SKSpriteNode]()
    
    // 플레이어
    var player:SKSpriteNode?
    var target:SKSpriteNode?
    
    var pause:SKSpriteNode?
    var timeLabel:SKLabelNode?
    var scoreLabel:SKLabelNode?
    var currentScore:Int = 0 {
        didSet {
            self.scoreLabel?.text = "SCORE: \(self.currentScore)"
            GameHandler.sharedInstance.score = currentScore
        }
    }
    var remainingTime:TimeInterval = 60 {
        didSet {
            self.timeLabel?.text = "TIME: \(Int(self.remainingTime))"
        }
    }
    
    // 현재 트랙 번호
    var currentTrack = 0
    // 수평 이동 중 여부
    var movingToTrack = false
    
    // 이동 시 sound
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    var backgroundNoise:SKAudioNode!
    
    
    // velocity 값 배열
    let trackVelocities = [180, 200, 250]
    // 랜덤 방향 배열
    var directionArray = [Bool]()
    // 랜덤 velocity 배열
    var velocityArray = [Int]()
    
    let playerCategory:UInt32 = 0x1 << 0 // 플레이어 카테고리 bitmask
    let enemyCategory:UInt32 = 0x1 << 1  // 장애물 카테고리 bitmask
    let targetCategory:UInt32 = 0x1 << 2 // 타겟 카테고리 bitmask
    let powerUpCategory:UInt32 = 0x1 << 3 // powerUp 카테고리 bitmask
    
    override func didMove(to view: SKView) {
        setupTracks()
        
        createHUD()
        launchGameTimer()
        
        createPlayer()
        createTarget()
        
        self.physicsWorld.contactDelegate = self
        
        if let musicURL = Bundle.main.url(forResource: "background", withExtension: "wav") {
            backgroundNoise = SKAudioNode(url: musicURL)
            addChild(backgroundNoise)
        }
        
        tracksArray?.first?.color = UIColor.green
        
        // 트랙의 갯수
        if let numberOfTracks = tracksArray?.count {
            for _ in 0 ... numberOfTracks {
                // 0~2 사이의 랜덤 넘버
                let randomNumberForVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
                // 랜덤하게 결정된 숫자에 따라 랜덤하게 velocity 값을 배열로 설정
                velocityArray.append(trackVelocities[randomNumberForVelocity])
                // 랜덤하게 bool 값을 direction 배열로 설정
                directionArray.append(GKRandomSource.sharedRandom().nextBool())
            }
        }
        
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spwanEnemies()
        }, SKAction.wait(forDuration: 2)])))
    }
    
    // touch 인식
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // touch 된 첫번째 객체
        if let touch = touches.first {
            // touch 된 객체 이전의 위치 정보
            let location = touch.previousLocation(in: self)
            // scene 노드에서 location 에 해당하는 노드들 중 첫번째 노드
            let node = self.nodes(at: location).first
            
            // 노드 name 을 가지고 분기 처리
            if node?.name == "right" {
                if currentTrack < 8 {
                    moveToNextTrack()
                }
            } else if node?.name == "up" {
                moveVertically(up: true)
            } else if node?.name == "down" {
                moveVertically(up: false)
            } else if node?.name == "pause", let scene = self.scene {
                if scene.isPaused {
                    scene.isPaused = false
                } else {
                    scene.isPaused = true
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movingToTrack {
            player?.removeAllActions()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        player?.removeAllActions()
    }
    
    // SKPhysicsContactDelegate 프로토콜 didBegin 구현
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody:SKPhysicsBody
        var otherBody:SKPhysicsBody
        
        // bodyA 와 bodyB 를 비교해서 플레이어와 other 를 구분
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            playerBody = contact.bodyA
            otherBody = contact.bodyB
        } else {
            playerBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        // 플레이어가 장애물과 만난것인지, 타겟과 만난것인지 구분
        if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == enemyCategory {
            self.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: true))
            movePlayerToStart()
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory {
            nextLevel(playerPhysicsBody: playerBody)
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == powerUpCategory {
            self.run(SKAction.playSoundFileNamed("powerUp.wav", waitForCompletion: true))
            otherBody.node?.removeFromParent()
            remainingTime += 5
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let player = self.player {
            if player.position.y > self.size.height || player.position.y < 0 {
                movePlayerToStart()
            }
        }
        
        if remainingTime <= 5 {
            timeLabel?.fontColor = UIColor.red
        }
        
        if remainingTime == 0 {
            gameOver()
        }
    }
}
