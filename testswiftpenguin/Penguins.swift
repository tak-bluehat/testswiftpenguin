//
//  Penguins.swift
//  testswiftpenguin
//
//  Created by tak on 2016/09/19.
//  Copyright © 2016年 tak. All rights reserved.
//

import Foundation
import UIKit
import SceneKit


class Penguins : NSObject {
    var scene:SCNScene
    var node:SCNNode
    var penguins_array:LinkedList<SCNNode>
    var dx:Double
    var dy:Double
    
    init(s_scene: SCNScene, s_node: SCNNode){
        
        self.scene = s_scene
        self.node = s_node
        self.penguins_array = LinkedList<SCNNode>()
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        
        super.init()
        
        // fish generate
        self.changeDelta()
        self.generate()
        
        _ = Timer.scheduledTimer(timeInterval: 4.0, target: self, selector: #selector(Penguins.changeDelta), userInfo: nil, repeats: true)
        //_ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "move", userInfo: nil, repeats: true)
        let displayLink = CADisplayLink(target: self, selector: #selector(Penguins.move))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    
    func changeDelta(){
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
    }
    
    func generate(){
        //penguin_node.scale = SCNVector3(0.03, 0.03, 0.03)
        
        let x:Double = Double( arc4random_uniform(150) ) - 75
        let y:Double = Double( arc4random_uniform(20) ) - 10
        let z:Double = 10
        
        let amount:Int = Int(arc4random_uniform(2)) + 3
        
        for _ in 1...amount {
            let penguin_node:SCNNode = self.node.clone()
            penguin_node.position = SCNVector3(x + (Double( arc4random_uniform(20) ) ), y + (Double( arc4random_uniform(20) ) ), z)
            penguins_array.append(value: penguin_node)
            scene.rootNode.addChildNode(penguin_node)
        }
    }
    
    func move(){
        var penguin_node:LinkedListNode<SCNNode>? = penguins_array.first
        while( penguin_node != nil ){
            let penguin:SCNNode! = penguin_node?.value
            penguin.position = SCNVector3(x: penguin.position.x  + Float(self.dx), y: penguin.position.y + Float(self.dy), z: penguin.position.z - 0.4)
            if( penguin.position.z < -70 ){
                penguin.removeFromParentNode()
                penguins_array.removeNode(node: penguin_node!)
            }
            penguin_node = penguin_node?.next
        }
    }
    
}
