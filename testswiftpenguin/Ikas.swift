//
//  Ikas.swift
//  testswiftpenguin
//
//  Created by tak on 2015/12/30.
//  Copyright © 2015年 tak. All rights reserved.
//

import Foundation
import UIKit
import SceneKit


class Ikas : NSObject {
    var scene:SCNScene
    var penguin:SCNNode
    var controller:GameViewController
    var ika_array:NSMutableArray
    var dx:Double
    var dy:Double
    
    init(s_scene: SCNScene, penguin_node: SCNNode, game_controller: GameViewController){
        
        self.scene = s_scene
        self.penguin = penguin_node
        self.controller = game_controller
        self.ika_array = NSMutableArray()
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        
        super.init()
        
        // fish generate
        self.generate()
        
        //_ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "changeDelta", userInfo: nil, repeats: true)
        //_ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "move", userInfo: nil, repeats: true)
        let displayLink = CADisplayLink(target: self, selector: "move")
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        
    }
    
    func changeDelta(){
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
    }
    
    func generate(){
        let amount:Int = Int(arc4random_uniform(2)) + 3
        
        
        let x:Double = Double( penguin.position.x ) + Double( arc4random_uniform(10) ) - 5
        let y:Double = Double( penguin.position.y ) + Double( arc4random_uniform(10) ) - 5
        let z:Double = -40
        
        for _ in 1...amount {
            let ika:SCNScene = SCNScene(named: "art.scnassets/ika.dae")!
            let ika_node:SCNNode = ika.rootNode.childNodeWithName("ika", recursively: false)!
            
            ika_node.position = SCNVector3(
                ( x + (Double( arc4random_uniform(10) ) - 5 ) / 5 ),
                ( y + (Double( arc4random_uniform(10) ) - 5 ) / 5 ),
                ( z +  (Double( arc4random_uniform(10) ) - 5 ) / 5 )
            )
            
            ika_array.addObject(ika_node)
            
            scene.rootNode.addChildNode(ika_node)
        }
    }
    
    func move(){
        for var index = 0; index < ika_array.count; index++ {
            let ika:SCNNode = ika_array.objectAtIndex(index) as! SCNNode
            ika.position = SCNVector3(ika.position.x, ika.position.y, ika.position.z + 0.2)
            
            if(
                fabs(ika.position.z - penguin.position.z) < 1
                    && fabs(ika.position.y - penguin.position.y) < 1
                    && fabs(ika.position.x - penguin.position.x) < 1
                    && controller.eat_flag == true
                ){
                    let ika_x:Float = ika.position.x;
                    let ika_y:Float = ika.position.y;
                    let ika_z:Float = ika.position.z;
                    // remove object
                    ika_array.removeObject(ika)
                    ika.removeFromParentNode()
                    
                    // ring setting
                    let ring:SCNScene = SCNScene(named: "art.scnassets/ring_new.dae")!
                    let ring_node:SCNNode = ring.rootNode.childNodeWithName("ring_new", recursively: false)!
                    ring_node.position = SCNVector3(ika_x, ika_y + 1.5, ika_z + 5)
                    
                    // point text setting
                    let text:SCNScene = SCNScene(named: "art.scnassets/point_ika.dae")!
                    let text_node:SCNNode = text.rootNode.childNodeWithName("ikapoint", recursively: false)!
                    text_node.position = SCNVector3(ika_x, ika_y + 2.0, ika_z + 5)
                    text_node.scale = SCNVector3(x: 0.2, y: 0.2, z: 0.2)
                    
                    // add view
                    scene.rootNode.addChildNode(ring_node)
                    scene.rootNode.addChildNode(text_node)
                    
                    // plus point
                    controller.point += 200
                    
                    // set combo
                    controller.combo++
                    
                    _ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "resetCombo", userInfo: nil, repeats: false)
                    
                    var combo_node:SCNNode = SCNNode();
                    if( controller.combo > 1 ){
                        controller.point += 200
                        let combo:SCNScene = SCNScene(named: "art.scnassets/combo.dae")!
                        combo_node = combo.rootNode.childNodeWithName("combo", recursively: false)!
                        combo_node.position = SCNVector3(penguin.position.x + 1.0, penguin.position.y + 1.75, penguin.position.z + 5)
                        combo_node.scale = SCNVector3(0.2, 0.2, 0.2)
                        scene.rootNode.addChildNode(combo_node)
                        
                    }
                    
                    // set point
                    let str:NSMutableString = NSMutableString()
                    str.appendFormat("%d", controller.point)
                    str.appendString(" points")
                    controller.points.text = str as String
                    
                    // set animation
                    SCNTransaction.begin()
                    SCNTransaction.setAnimationDuration(1.0)
                    ring_node.scale = SCNVector3(0.5, 0.5, 0.5)
                    text_node.scale = SCNVector3(0.4, 0.4, 0.4)
                    if( controller.combo > 1 ){
                        combo_node.scale = SCNVector3(0.4, 0.4, 0.4)
                    }
                    SCNTransaction.commit()
                    
                    
                    _ = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "removeRing", userInfo: nil, repeats: false)
                    
                    
                    
            }else if( ika.position.z > 20 ){
                ika_array.removeObject(ika)
                ika.removeFromParentNode()
            }
        }
        
        
    }
    
    func resetCombo(){
        controller.combo = 0
    }
        
    func removeRing(){
        let ring_node:SCNNode? = scene.rootNode.childNodeWithName("ring_new", recursively: false)
        let text_node:SCNNode? = scene.rootNode.childNodeWithName("ikapoint", recursively: false)
        let combo_node:SCNNode? = scene.rootNode.childNodeWithName("combo", recursively: false)
        
        if( ring_node != nil ){
            ring_node?.removeFromParentNode()
        }
        if( text_node != nil ){
            text_node?.removeFromParentNode()
        }
        if( combo_node != nil ){
            combo_node?.removeFromParentNode()
        }
    }
}
