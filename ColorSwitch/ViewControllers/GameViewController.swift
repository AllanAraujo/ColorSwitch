//
//  GameViewController.swift
//  ColorSwitch
//
//  Created by Allan Araujo on 8/9/18.
//  Copyright © 2018 Escher. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            
            //Open up menu scene first
            let scene = MenuScene(size: view.bounds.size)
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Present the scene
            view.presentScene(scene)
            
            
            view.ignoresSiblingOrder = true

        }
    }

}
