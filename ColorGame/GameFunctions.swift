//
//  GameFunctions.swift
//  ColorGame
//
//  Created by MinRiDaddy on 2017. 12. 3..
//  Copyright © 2017년 MinRiDaddy. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func launchGameTimer () {
        let timeAction = SKAction.repeatForever(SKAction.sequence([SKAction.run({
            self.remainingTime -= 1
            }), SKAction.wait(forDuration: 1)]))

        timeLabel?.run(timeAction)
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
            
            let up = directionArray[currentTrack + 1]
            
            //player.run(moveAction)
            // 액션 실행 : 완료되면 수평 이동 여부 세팅
            player.run(moveAction, completion: {
                self.movingToTrack = false
                
                if self.currentTrack != 8 {
                    self.player?.physicsBody?.velocity = up ? CGVector(dx: 0, dy: self.velocityArray[self.currentTrack]) : CGVector(dx: 0, dy: -self.velocityArray[self.currentTrack])
                }else {
                    self.player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
                
            })
            // 현재 트랙 정보 갱신
            currentTrack += 1
            
            // 이동 사운드 실행
            self.run(moveSound)
        }
    }
    
    func spwanEnemies () {
        
        var randomTrackNumber = 0
        let createPowerUp = GKRandomSource.sharedRandom().nextBool()
        
        if createPowerUp {
            randomTrackNumber = GKRandomSource.sharedRandom().nextInt(upperBound: 6) + 1
            if let powerUpObject = self.createPowerUp(forTrack: randomTrackNumber) {
                self.addChild(powerUpObject)
            }
        }
        
        for i in 1 ... 7 {
            
            if randomTrackNumber != i {
                let randomEnemy = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
                if let newEnemy = createEnemy(type: randomEnemy, forTrack: i) {
                    self.addChild(newEnemy)
                }
            }
        }
        
        self.enumerateChildNodes(withName: "ENEMY") { (node: SKNode, nil) in
            if node.position.y < -150 || node.position.y > self.size.height + 150 {
                node.removeFromParent()
            }
        }
    }
    
    func movePlayerToStart () {
        if let player = self.player {
            player.removeFromParent()
            self.player = nil
            self.createPlayer()
            self.currentTrack = 0
        }
    }
    
    func nextLevel (playerPhysicsBody: SKPhysicsBody) {
        currentScore += 1
        self.run(SKAction.playSoundFileNamed("levelUp.wav", waitForCompletion: true))
        let emitter = SKEmitterNode(fileNamed: "fireworks.sks")
        playerPhysicsBody.node?.addChild(emitter!)
        
        self.run(SKAction.wait(forDuration: 0.5)) {
            emitter?.removeFromParent()
            self.movePlayerToStart()
        }
    }
    
    func gameOver() {
        GameHandler.sharedInstance.saveGameStats()
        
        self.run(SKAction.playSoundFileNamed("levelCompleted.wav", waitForCompletion: true))
        
        let transition = SKTransition.fade(withDuration: 1)
        if let gameOverScene = SKScene(fileNamed: "GameOverScene") {
            gameOverScene.scaleMode = .aspectFit
            self.view?.presentScene(gameOverScene, transition: transition)
        }
    }
    
}
