//
//  Bubble.swift
//  testswiftpenguin
//
//  Created by tak on 2016/09/10.
//  Copyright © 2016年 tak. All rights reserved.
//

import Foundation
import UIKit
import SceneKit


class Bubbles : NSObject {
    var scene:SCNScene
    var penguin:SCNNode
    var controller:GameViewController
    var bubble_array:LinkedList<SCNNode, UIView, Float, Float, Float>
    var dx:Double
    var dy:Double
    
    init(s_scene: SCNScene, penguin_node: SCNNode, game_controller: GameViewController){
        
        self.scene = s_scene
        self.penguin = penguin_node
        self.controller = game_controller
        self.bubble_array = LinkedList<SCNNode, UIView, Float, Float, Float>()
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        
        super.init()
        
        // fish generate
        self.generate()
        
        //_ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "changeDelta", userInfo: nil, repeats: true)
        //_ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "move", userInfo: nil, repeats: true)
        let displayLink = CADisplayLink(target: self, selector: #selector(Bubbles.move))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        
    }
    
    func generate(){
        let penguin:SCNNode = self.penguin
        
        let bubble:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node:SCNNode = bubble.rootNode.childNode(withName: "bubble", recursively: false)!
        
        //let bubble2:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node2:SCNNode = bubble_node.clone()
        //let bubble_node2:SCNNode = bubble2.rootNode.childNode(withName: "bubble", recursively: false)!
        
        //let bubble3:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node3:SCNNode = bubble_node.clone()
        //let bubble_node3:SCNNode = bubble3.rootNode.childNode(withName: "bubble", recursively: false)!
        
        //let bubble4:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node4:SCNNode = bubble_node.clone()
        //let bubble_node4:SCNNode = bubble4.rootNode.childNode(withName: "bubble", recursively: false)!
        
        //let bubble5:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node5:SCNNode = bubble_node.clone()
        //let bubble_node5:SCNNode = bubble5.rootNode.childNode(withName: "bubble", recursively: false)!
        
        //let bubble6:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node6:SCNNode = bubble_node.clone()
        //let bubble_node6:SCNNode = bubble6.rootNode.childNode(withName: "bubble", recursively: false)!
        
        //let bubble7:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node7:SCNNode = bubble_node.clone()
        //let bubble_node7:SCNNode = bubble7.rootNode.childNode(withName: "bubble", recursively: false)!
        
        //let bubble8:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node8:SCNNode = bubble_node.clone()
        //let bubble_node8:SCNNode = bubble8.rootNode.childNode(withName: "bubble", recursively: false)!
        
        //let bubble9:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node9:SCNNode = bubble_node.clone()
        //let bubble_node9:SCNNode = bubble9.rootNode.childNode(withName: "bubble", recursively: false)!
        
        
        bubble_node.scale = SCNVector3(0.03, 0.03, 0.03)
        bubble_node2.scale = SCNVector3(0.03, 0.03, 0.03)
        bubble_node3.scale = SCNVector3(0.03, 0.03, 0.03)
        bubble_node4.scale = SCNVector3(0.03, 0.03, 0.03)
        bubble_node5.scale = SCNVector3(0.03, 0.03, 0.03)
        bubble_node6.scale = SCNVector3(0.03, 0.03, 0.03)
        bubble_node7.scale = SCNVector3(0.03, 0.03, 0.03)
        bubble_node8.scale = SCNVector3(0.03, 0.03, 0.03)
        bubble_node9.scale = SCNVector3(0.03, 0.03, 0.03)
        
        let x:Double = Double(penguin.position.x)
        let y:Double = Double(penguin.position.y)
        let z:Double = 0
        
        bubble_node.position = SCNVector3(x, y, z)
        bubble_node2.position = SCNVector3( ( x - 0.3 ), ( y - 0.3 ), z)
        bubble_node3.position = SCNVector3(x, ( y - 0.3 ), ( z + 0.3 ) )
        bubble_node4.position = SCNVector3( ( x + 0.3 ), ( y - 0.3 ), z)
        bubble_node5.position = SCNVector3(x, ( y + 0.3 ), ( z - 0.3 ) )
        bubble_node6.position = SCNVector3( ( x + 0.3 ), ( y + 0.3 ), z)
        bubble_node7.position = SCNVector3(x, ( y + 0.3 ), ( z - 0.3 ) )
        bubble_node8.position = SCNVector3( ( x - 0.3 ), ( y + 0.3 ), z)
        bubble_node9.position = SCNVector3(x, ( y - 0.3 ), ( z + 0.3 ) )
        
        bubble_node.opacity = 0.3
        bubble_node2.opacity = 0.3
        bubble_node3.opacity = 0.3
        bubble_node4.opacity = 0.3
        bubble_node5.opacity = 0.3
        bubble_node6.opacity = 0.3
        bubble_node7.opacity = 0.3
        bubble_node8.opacity = 0.3
        bubble_node9.opacity = 0.3
        
        bubble_array.append(value: bubble_node, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        bubble_array.append(value: bubble_node2, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        bubble_array.append(value: bubble_node3, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        bubble_array.append(value: bubble_node4, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        bubble_array.append(value: bubble_node5, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        bubble_array.append(value: bubble_node6, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        bubble_array.append(value: bubble_node7, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        bubble_array.append(value: bubble_node8, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        bubble_array.append(value: bubble_node9, view: UIView(), move_x: 0, move_y: 0, move_z: 0)
        
        scene.rootNode.addChildNode(bubble_node)
        scene.rootNode.addChildNode(bubble_node2)
        scene.rootNode.addChildNode(bubble_node3)
        scene.rootNode.addChildNode(bubble_node4)
        scene.rootNode.addChildNode(bubble_node5)
        scene.rootNode.addChildNode(bubble_node6)
        scene.rootNode.addChildNode(bubble_node7)
        scene.rootNode.addChildNode(bubble_node8)
        scene.rootNode.addChildNode(bubble_node9)
    }
    
    @objc func move(){
        var bubble_node:LinkedListNode<SCNNode, UIView, Float, Float, Float>? = bubble_array.first
        while( bubble_node != nil ){
            let bubble:SCNNode! = bubble_node?.value
            bubble.position = SCNVector3(x: bubble.position.x, y: bubble.position.y, z: bubble.position.z + 0.22)
            if( bubble.position.z > 20 ){
                bubble.removeFromParentNode()
                _ = bubble_array.removeNode(node: bubble_node!)            }
            bubble_node = bubble_node?.next
        }
    }
        
}
