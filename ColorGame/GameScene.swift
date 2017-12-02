//
//  GameScene.swift
//  ColorGame
//
//  Created by MinRiDaddy on 2017. 12. 2..
//  Copyright © 2017년 MinRiDaddy. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Enemies: Int {
    case small
    case medium
    case large
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // 트랙 배열
    var tracksArray:[SKSpriteNode]? = [SKSpriteNode]()
    // 플레이어
    var player:SKSpriteNode?
    var target:SKSpriteNode?
    
    // 현재 트랙 번호
    var currentTrack = 0
    // 수평 이동 중 여부
    var movingToTrack = false
    
    // 이동 시 sound
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    
    // velocity 값 배열
    let trackVelocities = [180, 200, 250]
    // 랜덤 방향 배열
    var directionArray = [Bool]()
    // 랜덤 velocity 배열
    var velocityArray = [Int]()
    
    let playerCategory:UInt32 = 0x1 << 0
    let enemyCategory:UInt32 = 0x1 << 1
    let targetCategory:UInt32 = 0x1 << 2
    
    
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
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = 0
        player?.physicsBody?.contactTestBitMask = enemyCategory | targetCategory
        
        
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
        
        enemySprite.physicsBody?.categoryBitMask = enemyCategory
        
        // 랜덤하게 결정된 velocity 에 따라 physicsBody 의 velocity 설정
        enemySprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) : CGVector(dx: 0, dy: -velocityArray[track])
        
        return enemySprite
    }
    
    func spwanEnemies () {
        for i in 1 ... 7 {
            let randomEnemy = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
            if let newEnemy = createEnemy(type: randomEnemy, forTrack: i) {
                self.addChild(newEnemy)
            }
        }
        
        self.enumerateChildNodes(withName: "ENEMY") { (node: SKNode, nil) in
            if node.position.y < -150 || node.position.y > self.size.height + 150 {
                node.removeFromParent()
            }
        }
    }
    
    override func didMove(to view: SKView) {
        setupTracks()
        createPlayer()
        createTarget()
        
        self.physicsWorld.contactDelegate = self
        
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
    
    // 위, 아래 이동
    func moveVertically (up:Bool) {
        if up {
            // x 는 변화가 없고 y 로 3 pixel 을 0.01 시간에 이동
            let moveAction = SKAction.moveBy(x: 0, y: 3, duration: 0.01)
            // 위의 이동을 계속 반복하도록 설정
            let repeatAction = SKAction.repeatForever(moveAction)
            // 플레이어에 액션 설정
            player?.run(repeatAction)
        } else {
            // x 는 변화가 없고 y 로 -3 pixel 을 0.01 시간에 이동
            let moveAction = SKAction.moveBy(x: 0, y: -3, duration: 0.01)
            // 위의 이동을 계속 반복하도록 설정
            let repeatAction = SKAction.repeatForever(moveAction)
            // 플레이어에 액션 설정
            player?.run(repeatAction)
        }
    }
    
    func moveToNextTrack () {
        // 다음 트랙으로 이동 전 플레이어의 액션을 모두 제거
        player?.removeAllActions()
        // 수평 이동 여부 세팅
        movingToTrack = true
        
        // 다음 트랙의 position
        guard let nextTrack = tracksArray?[currentTrack + 1].position else {return}
        
        // 플레이어 객체
        if let player = self.player {
            // 플레이어의 액션
            // 다음 트랙의 x 좌표, 현재 플레이어의 y 좌표로 이동 액션
            let moveAction = SKAction.move(to: CGPoint(x: nextTrack.x, y: player.position.y), duration: 0.2)
            //player.run(moveAction)
            // 액션 실행 : 완료되면 수평 이동 여부 세팅
            player.run(moveAction, completion: {
                self.movingToTrack = false
                })
            // 현재 트랙 정보 갱신
            currentTrack += 1
            
            // 이동 사운드 실행
            self.run(moveSound)
        }
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
                moveToNextTrack()
            } else if node?.name == "up" {
                moveVertically(up: true)
            } else if node?.name == "down" {
                moveVertically(up: false)
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
    
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody:SKPhysicsBody
        var otherBody:SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            playerBody = contact.bodyA
            otherBody = contact.bodyB
        } else {
            playerBody = contact.bodyB
            otherBody = contact.bodyA
        }
        
        if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == enemyCategory {
            print("Enemy hit")
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory {
            print("Target hit")
        }
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
