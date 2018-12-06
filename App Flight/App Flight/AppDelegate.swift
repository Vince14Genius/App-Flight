//
//  AppDelegate.swift
//  App Flight
//
//  Created by Vince14Genius on 2/3/15.
//  Copyright (c) 2015 Vince14Genius. All rights reserved.
//

import Cocoa
import SpriteKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var skView: SKView!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        /* Pick a size for the scene */
        if let scene = GameScene(fileNamed:"GameScene") {
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .aspectFill
            
            self.skView!.presentScene(scene)
            
            self.skView!.showsFPS = true
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        if skView.scene!.isKind(of: GamePlayScene.self) {
            skView.isPaused = true
        }
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        skView.isPaused = false
    }
}

