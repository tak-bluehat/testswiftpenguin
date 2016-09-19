//
//  CycleBubbles.swift
//  testswiftpenguin
//
//  Created by tak on 2016/09/10.
//  Copyright © 2016年 tak. All rights reserved.
//

import Foundation
import UIKit
import SceneKit


class CycleBubbles : NSObject {
    var scene:SCNScene
    var penguin:SCNNode
    var controller:GameViewController
    var cycle_bubble_array:LinkedList<SCNNode>
    var dx:Double
    var dy:Double
    
    init(s_scene: SCNScene, penguin_node: SCNNode, game_controller: GameViewController){
        
        self.scene = s_scene
        self.penguin = penguin_node
        self.controller = game_controller
        self.cycle_bubble_array = LinkedList<SCNNode>()
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        
        super.init()
        
        // fish generate
        self.generate()
        
        //_ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "changeDelta", userInfo: nil, repeats: true)
        //_ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "move", userInfo: nil, repeats: true)
        let displayLink = CADisplayLink(target: self, selector: #selector(CycleBubbles.move))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    
    func generate(){
        for index in 1...10 {
            let penguin:SCNNode = self.penguin
            
            let bubble:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node:SCNNode = bubble.rootNode.childNode(withName: "bubble", recursively: false)!
            
            //let bubble2:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node2:SCNNode = bubble_node.clone()
            
            //let bubble3:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node3:SCNNode = bubble_node.clone()
            
            //let bubble4:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node4:SCNNode = bubble_node.clone()
            
            //let bubble5:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node5:SCNNode = bubble_node.clone()
             
            bubble_node.scale = SCNVector3(0.02, 0.02, 0.02)
            bubble_node2.scale = SCNVector3(0.02, 0.02, 0.02)
            bubble_node3.scale = SCNVector3(0.02, 0.02, 0.02)
            bubble_node4.scale = SCNVector3(0.02, 0.02, 0.02)
            bubble_node5.scale = SCNVector3(0.02, 0.02, 0.02)
            
            let x:Double = Double(penguin.position.x) - 5 + Double(index)
            let y:Double = Double(penguin.position.y) - 4 - Double(index)
            let z:Double = 0
            
            bubble_node.position = SCNVector3(x, y, z)
            bubble_node2.position = SCNVector3( ( x - 0.3 ), ( y - 0.3 ), z)
            bubble_node3.position = SCNVector3(x, ( y - 0.3 ), ( z + 0.3 ) )
            bubble_node4.position = SCNVector3( ( x + 0.3 ), ( y - 0.3 ), z)
            bubble_node5.position = SCNVector3(x, ( y + 0.3 ), ( z - 0.3 ) )
            
            bubble_node.opacity = 0.4
            bubble_node2.opacity = 0.4
            bubble_node3.opacity = 0.4
            bubble_node4.opacity = 0.4
            bubble_node5.opacity = 0.4
            
            cycle_bubble_array.append(value: bubble_node)
            cycle_bubble_array.append(value: bubble_node2)
            cycle_bubble_array.append(value: bubble_node3)
            cycle_bubble_array.append(value: bubble_node4)
            cycle_bubble_array.append(value: bubble_node5)
            
            scene.rootNode.addChildNode(bubble_node)
            scene.rootNode.addChildNode(bubble_node2)
            scene.rootNode.addChildNode(bubble_node3)
            scene.rootNode.addChildNode(bubble_node4)
            scene.rootNode.addChildNode(bubble_node5)
        }

    }
    
    func move(){
        var cycle_bubble_node:LinkedListNode<SCNNode>? = cycle_bubble_array.first
        while( cycle_bubble_node != nil ){
            let cycle_bubble:SCNNode! = cycle_bubble_node?.value
            cycle_bubble.position = SCNVector3(x: cycle_bubble.position.x, y: cycle_bubble.position.y + 0.30, z: cycle_bubble.position.z + 0.30)
            if( cycle_bubble.position.y > penguin.position.y + 10 ){
                cycle_bubble.removeFromParentNode()
                cycle_bubble_array.removeNode(node: cycle_bubble_node!)
            }
            cycle_bubble_node = cycle_bubble_node?.next
        }
    }
    
}
