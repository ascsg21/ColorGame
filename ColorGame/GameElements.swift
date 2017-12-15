//
//  GameElements.swift
//  ColorGame
//
//  Created by MinRiDaddy on 2017. 12. 3..
//  Copyright © 2017년 MinRiDaddy. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Enemies: Int {
    case small
    case medium
    case large
}

extension GameScene {
    
    func createHUD () {
        pause = self.childNode(withName: "pause") as? SKSpriteNode
        timeLabel = self.childNode(withName: "time") as? SKLabelNode
        scoreLabel = self.childNode(withName: "score") as? SKLabelNode
        
        remainingTime = 60
        currentScore = 0
    }
    
    // 앱 실행 시 최초에 트랙 정보를 배열로 옮긴다
    func setupTracks() {
        for i in 0 ... 8 {
            if let track = self.childNode(withName: "\(i)") as? SKSpriteNode {
                tracksArray?.append(track)
            }
        }
    }
    
    // 앱 실행 시 플레이어 객체를 생성하고 노드로 추가한다.
    func createPlayer() {
        player = SKSpriteNode(imageNamed: "player")
        player?.physicsBody = SKPhysicsBody(circleOfRadius: player!.size.width / 2)
        player?.physicsBody?.linearDamping = 0
        // 플레이어의 bitmask 세팅
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = 0
        // contactTestBitMask 설정
        player?.physicsBody?.contactTestBitMask = enemyCategory | targetCategory | powerUpCategory
        
        
        // 첫번째 트랙의 x 값
        guard let playerPosition = tracksArray?.first?.position.x else {return}
        // 최초 플레이어의 위치는 첫번째 트랙의 x 와 동일한 x 값을 가지고
        // y 값은 scene 의 height 의 중간값으로 설정
        player?.position = CGPoint(x: playerPosition, y: self.size.height / 2)
        
        // 노드로 추가
        self.addChild(player!)
        
        let pulse = SKEmitterNode(fileNamed: "pulse")!
        player?.addChild(pulse)
        pulse.position = CGPoint(x: 0, y: 0)
        
    }
    
    func createTarget () {
        target = self.childNode(withName: "target") as? SKSpriteNode
        target?.physicsBody = SKPhysicsBody(circleOfRadius: target!.size.width / 2)
        // 타겟의 카테고리 bitmask 설정
        target?.physicsBody?.categoryBitMask = targetCategory
        target?.physicsBody?.collisionBitMask = 0
    }
    
    func createEnemy (type: Enemies, forTrack track: Int) -> SKShapeNode? {
        // SKShapeNode 객체 생성(장애물)
        let enemySprite = SKShapeNode()
        enemySprite.name = "ENEMY"
        
        // 타입에 따라 다른 path, 칼라 설정
        switch type {
        case .small:
            // width 20, height 70
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 70), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.4431, green: 0.5529, blue: 0.7451, alpha: 1)
        case .medium:
            // width 20, height 100
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 100), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1)
        case .large:
            // width 20, height 130
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 130), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1)
        }
        
        // 트랙의 position 객체
        guard let enemyPosition = tracksArray?[track].position else {return nil}
        
        // 랜덤하게 결정된 트랙의 방향
        let up = directionArray[track]
        
        // 장애물의 x 좌표는 트랙의 x 좌표
        enemySprite.position.x = enemyPosition.x
        // 장애물의 y 좌표는 랜덤하게 결정된 방향에 따라 -130
        // 또는 scene 의 height + 130 으로 설정
        enemySprite.position.y = up ? -130 : self.size.height + 130
        
        // 장애물의 physicsBody
        enemySprite.physicsBody = SKPhysicsBody(edgeLoopFrom: enemySprite.path!)
        
        // 장애물의 카테고리 bitmask 설정
        enemySprite.physicsBody?.categoryBitMask = enemyCategory
        
        // 랜덤하게 결정된 velocity 에 따라 physicsBody 의 velocity 설정
        enemySprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        return enemySprite
    }
    
    func createPowerUp (forTrack track:Int) -> SKSpriteNode? {
        let powerUpSprite = SKSpriteNode(imageNamed: "powerUp")
        powerUpSprite.name = "ENEMY"
        
        powerUpSprite.physicsBody = SKPhysicsBody(circleOfRadius: powerUpSprite.size.width / 2)
        powerUpSprite.physicsBody?.linearDamping = 0
        powerUpSprite.physicsBody?.categoryBitMask = powerUpCategory
        powerUpSprite.physicsBody?.collisionBitMask = 0
        
        let up = directionArray[track]
        guard let powerUpXPosition = tracksArray?[track].position.x else {return nil}
        
        powerUpSprite.position.x = powerUpXPosition
        powerUpSprite.position.y = up ? -130 : self.size.height + 130
        
        powerUpSprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        return powerUpSprite
        
    }
}
