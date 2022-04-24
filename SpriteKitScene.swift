//
//  File.swift
//  ParkingMaster
//
//  Created by 임영후 on 2022/04/23.
//
import UIKit
import SpriteKit
import RealityKit
import SceneKit
import ARKit

class SpriteScene: SKScene {
    
    //change the code below to whatever you want to happen on skscene
    enum NodesZPosition: CGFloat {
      case joystick
    }
    
    
    override func didMove(to view: SKView) {
        view.allowsTransparency = true
        self.backgroundColor = .clear
        view.backgroundColor = .clear
        
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        let location = touch.location(in: self)
        
        removeAllChildren()
        let analogJoystick = AnalogJoystick(diameter: 100, colors: nil, images: (substrate: #imageLiteral(resourceName: "jSubstrate"), stick: #imageLiteral(resourceName: "jStick")))
        analogJoystick.position = location
        analogJoystick.trackingHandler = { [unowned self] data in
          NotificationCenter.default.post(name: joystickNotificationName, object: nil, userInfo: ["data": data])
        }
//        tlAnalogJoystick.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 50, height: 50))
        addChild(analogJoystick)
    }
    
      
    
}
