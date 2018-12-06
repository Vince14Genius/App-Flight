//
//  GameScene.swift
//  App Flight
//
//  Created by Vince14Genius on 2/3/15.
//  Copyright (c) 2015 Vince14Genius. All rights reserved.
//

import SpriteKit

enum GameMode: Int {
    case classic    = 1
    case survival   = 2
    case domination = 3
    case torture    = 4
}

class GameScene: SKScene {
    override func didMove(to view: SKView) {
        view.presentScene(GameTitleScene(size: size))
    }
}

//////////////////// CODE FOR MAIN MENU STARTS HERE ///////////////////

class GameTitleScene: SKScene {
    let buttons = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "buttons")))
    let highlight = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "highlight")))
    
    override init(size: CGSize) {
        super.init(size: size)
        
        let background = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "background")))
        background.position = CGPoint(x: 160, y: 284)
        addChild(background)
        
        let logo = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "logo")))
        logo.position = CGPoint(x: 160, y: 400)
        addChild(logo)
        
        buttons.position = CGPoint(x: 160, y: 284)
        addChild(buttons)
        
        highlight.position = CGPoint(x: -500, y: -500)
        addChild(highlight)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        if atPoint(theEvent.location(in: self)) === buttons {
            switch theEvent.location(in: self).y {
            case 220...270: view!.presentScene(GameTutorialScene(size: size, mode: .classic), transition: .reveal(with: .up, duration: 0.4))
            case 160...210: view!.presentScene(GameTutorialScene(size: size, mode: .survival), transition: .reveal(with: .up, duration: 0.4))
            case 100...150: view!.presentScene(GameTutorialScene(size: size, mode: .domination), transition: .reveal(with: .up, duration: 0.4))
            case 40...90: view!.presentScene(GameTutorialScene(size: size, mode: .torture), transition: .reveal(with: .up, duration: 0.4))
            default: break
            }
        }
        highlight.position = CGPoint(x: -500, y: -500)
    }
}

class GameTutorialScene: SKScene {
    let mode: GameMode
    
    init(size: CGSize, mode: GameMode) {
        self.mode = mode
        super.init(size: size)
        
        let background = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "background")))
        background.position = CGPoint(x: 160, y: 284)
        addChild(background)
        
        let text: SKSpriteNode
        
        switch mode {
        case .classic: text = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "textclassic")))
        case .survival: text = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "textsurvival")))
        case .domination: text = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "textdomination")))
        case .torture: text = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "texttorture")))
        }
        
        text.position = CGPoint(x: 160, y: 284)
        addChild(text)
    }
    
    override func keyUp(with theEvent: NSEvent) {
        scene!.view!.presentScene(GamePlayScene(size: size, mode: mode))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameOverScene: SKScene {
    init(size: CGSize, scorerequired: Int, score: Int) {
        super.init(size: size)
        if score >= scorerequired {
            let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "victory")))
            bg.position = CGPoint(x: 160, y: 284)
            addChild(bg)
            run(SKAction.playSoundFileNamed("win.mp3", waitForCompletion: false))
        } else {
            let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "defeat")))
            bg.position = CGPoint(x: 160, y: 284)
            addChild(bg)
            
            let scorelabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
            scorelabel.fontSize = 18
            scorelabel.text = "Score: \(score)"
            scorelabel.position = CGPoint(x: 160, y: 100)
            scorelabel.fontColor = SKColor.black
            addChild(scorelabel)
            
            run(SKAction.playSoundFileNamed("lose.mp3", waitForCompletion: false))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyUp(with theEvent: NSEvent) {
        view!.presentScene(GameTitleScene(size: size), transition: .moveIn(with: .down, duration: 0.4))
    }
    
    override func mouseUp(with theEvent: NSEvent) {
        view!.presentScene(GameTitleScene(size: size), transition: .moveIn(with: .down, duration: 0.4))
    }
}

//////////////////// CODE FOR THE GAME STARTS HERE ///////////////////

class GamePlayScene: SKScene {
    let scorerequired: Int
    let mode: GameMode
    
    var score = 0
    let scoreLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    let timeLabel = SKLabelNode(fontNamed: "HelveticaNeue-Light")
    var time: TimeInterval = 30
    var heroX: CGFloat = 160
    let hero = SKNode()
    var oldTime = 0
    let airdrops = SKNode()
    let warnings = SKNode()
    var starttest = false
    var wintest = false
    
    let rocket: SKEmitterNode
    
    init(size: CGSize, mode: GameMode) {
        self.mode = mode
        rocket = SKEmitterNode(fileNamed: "rocket\(mode.rawValue).sks")!
        
        switch mode {
        case .classic:
            scorerequired = 25
        case .survival:
            scorerequired = 29
        case .domination:
            scorerequired = 30
            time = 15
        case .torture:
            scorerequired = 15
        }
        
        super.init(size: size)
        
        let bg = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "arena")))
        bg.position = CGPoint(x: 160, y: 284)
        addChild(bg)
        
        let stars = SKEmitterNode(fileNamed: "stars.sks")!
        stars.position.y = 284
        bg.addChild(stars)
        
        rocket.position.y = 75
        rocket.targetNode = self
        addChild(rocket)
        
        addChild(airdrops)
        addChild(warnings)
        
        hero.position.y = 110
        hero.position.x = heroX
        hero.zPosition = 1
        addChild(hero)
        
        let heroPic = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "hero")))
        hero.addChild(heroPic)
        
        scoreLabel.fontSize = 24
        scoreLabel.text = "AirDrops Collected: 0"
        scoreLabel.position = CGPoint(x: 160, y: 488)
        addChild(scoreLabel)
        
        timeLabel.fontSize = 24
        timeLabel.text = "Time Left: 60"
        timeLabel.position = CGPoint(x: 160, y: 528)
        addChild(timeLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func spawn() {
        let airdrop = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "airdrop")))
        let warning = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "warning")))
        let warning1 = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "warning")))
        let warning2 = SKSpriteNode(texture: SKTexture(image: #imageLiteral(resourceName:  "warning")))
        switch mode {
        case .survival:
            // randomly spawn two warnings
            let random = Int(arc4random() % 3)
            warning1.position = CGPoint(x: 80 + 80 * random % 2, y: 600)
            warning2.position = CGPoint(x: 160 + 80 * Int(Double(random) / 2 + 0.5), y: 600)
            switch random {
            case 0:
                warning1.position = CGPoint(x: 80, y: 600)
                warning2.position = CGPoint(x: 160, y: 600)
            case 1:
                warning1.position = CGPoint(x: 160, y: 600)
                warning2.position = CGPoint(x: 240, y: 600)
            default:
                warning1.position = CGPoint(x: 80, y: 600)
                warning2.position = CGPoint(x: 240, y: 600)
            }
            warnings.addChild(warning1)
            warnings.addChild(warning2)
            warning1.run(.moveTo(y: 160, duration: 0.5), completion: {self.wTest(warning1)})
            warning2.run(.moveTo(y: 160, duration: 0.5), completion: {self.wTest(warning2)})
        case .torture:
            // randomly spawn two warnings and an airdrop
            let random = arc4random() % 3
            switch random {
            case 0:
                airdrop.position = CGPoint(x: 240, y: 600)
                warning1.position = CGPoint(x: 80, y: 600)
                warning2.position = CGPoint(x: 160, y: 600)
            case 1:
                airdrop.position = CGPoint(x: 80, y: 600)
                warning1.position = CGPoint(x: 160, y: 600)
                warning2.position = CGPoint(x: 240, y: 600)
            default:
                airdrop.position = CGPoint(x: 160, y: 600)
                warning1.position = CGPoint(x: 80, y: 600)
                warning2.position = CGPoint(x: 240, y: 600)
            }
            airdrops.addChild(airdrop)
            warnings.addChild(warning1)
            warnings.addChild(warning2)
            airdrop.run(.moveTo(y: 160, duration: 0.4), completion: {self.aTest(airdrop)})
            warning1.run(.moveTo(y: 160, duration: 0.4), completion: {self.wTest(warning1)})
            warning2.run(.moveTo(y: 160, duration: 0.4), completion: {self.wTest(warning2)})
        default:
            // randomly spawn a warning and an airdrop
            let random = arc4random() % 6
            switch random {
            case 0:
                airdrop.position = CGPoint(x: 80, y: 600)
                warning.position = CGPoint(x: 160, y: 600)
            case 1:
                airdrop.position = CGPoint(x: 160, y: 600)
                warning.position = CGPoint(x: 80, y: 600)
            case 2:
                airdrop.position = CGPoint(x: 240, y: 600)
                warning.position = CGPoint(x: 160, y: 600)
            case 3:
                airdrop.position = CGPoint(x: 160, y: 600)
                warning.position = CGPoint(x: 240, y: 600)
            case 4:
                airdrop.position = CGPoint(x: 80, y: 600)
                warning.position = CGPoint(x: 240, y: 600)
            default:
                airdrop.position = CGPoint(x: 240, y: 600)
                warning.position = CGPoint(x: 80, y: 600)
                
            }
            airdrops.addChild(airdrop)
            warnings.addChild(warning)
            airdrop.run(.moveTo(y: 160, duration: 0.5), completion: {self.aTest(airdrop)})
            warning.run(.moveTo(y: 160, duration: 0.5), completion: {self.wTest(warning)})
        }
    }
    
    func aTest(_ node: SKNode) {
        // Test for collision with AirDrops
        if node.position.x == heroX {
            if scorerequired == 25 || scorerequired == 15{
                score += 1
                node.removeFromParent()
                run(.playSoundFileNamed("point.mp3", waitForCompletion: false))
            } else if scorerequired == 30 {
                time += 2
                node.removeFromParent()
                run(.playSoundFileNamed("point.mp3", waitForCompletion: false))
            }
        } else {
            node.run(.moveTo(y: -280, duration: 0.5), completion: {node.removeFromParent()})
        }
    }
    
    func wTest(_ node: SKNode) {
        // Test for collision with Warnings
        if node.position.x == heroX {
            if scorerequired == 30 {
                time -= 15
                node.removeFromParent()
                run(.playSoundFileNamed("lose.mp3", waitForCompletion: false))
            } else {
                view!.presentScene(GameOverScene(size: size, scorerequired: scorerequired, score: score), transition: .push(with: .down, duration: 0.4))
            }
        } else {
            node.run(.moveTo(y: -280, duration: 0.5), completion: {node.removeFromParent()})
        }
    }
    
    override func keyDown(with theEvent: NSEvent) {
        let key = theEvent.keyCode
        if key == 0 || key == 123 {
            // Move left
            if heroX != 80 { heroX -= 80 }
        } else if key == 2 || key == 124 {
            // Move right
            if heroX != 240 { heroX += 80 }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        hero.run(.moveTo(x: heroX, duration: 0.1))
        
        if !wintest && score >= scorerequired {
            wintest = true
            view!.presentScene(GameOverScene(size: size, scorerequired: scorerequired, score: score), transition: .push(with: .down, duration: 0.4))
        }
        if !starttest {
            starttest = true
        } else {
            if Int(currentTime) >= Int(oldTime + 1) {
                spawn()
                if scorerequired == 29 || scorerequired == 30 {
                    score += 1
                }
                
                if !wintest && score >= scorerequired {
                    wintest = true
                    view!.presentScene(GameOverScene(size: size, scorerequired: scorerequired, score: score), transition: .push(with: .down, duration: 0.4))
                }
            
                hero.run(.playSoundFileNamed("flame.mp3", waitForCompletion: false))
                time -= 1
                
                if time <= 0 {
                    view!.presentScene(GameOverScene(size: size, scorerequired: scorerequired, score: score), transition: .fade(withDuration: 0.4))
                }
            }
        }
        
        oldTime = Int(currentTime)
        timeLabel.text = "Time Left: \(time)"
        
        switch mode {
        case .survival  :  timeLabel.text = "Time Left: \(time - 1)"; scoreLabel.text = " "
        case .domination: scoreLabel.text = "Domination Points: \(score)"
        default         : scoreLabel.text = "AirDrops Collected: \(score)"
        }
        
        rocket.position.x = hero.position.x
    }
}
