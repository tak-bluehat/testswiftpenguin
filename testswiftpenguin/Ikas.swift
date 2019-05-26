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
    var ika_array:LinkedList<SCNNode, UIView, Float, Float, Float>
    var dx:Double
    var dy:Double
    
    init(s_scene: SCNScene, penguin_node: SCNNode, game_controller: GameViewController){
        self.scene = s_scene
        self.penguin = penguin_node
        self.controller = game_controller
        self.ika_array = LinkedList<SCNNode, UIView, Float, Float, Float>()
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        
        super.init()
        
        // fish generate
        self.generate()
        
        //_ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "changeDelta", userInfo: nil, repeats: true)
        //_ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "move", userInfo: nil, repeats: true)
        let displayLink = CADisplayLink(target: self, selector: #selector(Ikas.move))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
        
    }
    
    func changeDelta(){
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
    }
    
    func generate(){
        let amount:Int = Int(arc4random_uniform(2)) + 3
        
        
        let x:Double = Double( arc4random_uniform(150) ) - 75
        let y:Double = Double( arc4random_uniform(20) ) - 10
        let z:Double = (Double(arc4random_uniform(40)) - 60)
        
        let ika:SCNScene = SCNScene(named: "art.scnassets/ika.dae")!
        let ika_node_base:SCNNode = ika.rootNode.childNode(withName: "ika", recursively: false)!
        
        for _ in 1...amount {
            let ika_node:SCNNode = ika_node_base.clone()
            let ika_rader_node:UIView = UIView()
            ika_rader_node.backgroundColor = UIColor.green
            
            ika_node.position = SCNVector3(
                ( x + (Double( arc4random_uniform(10) ) - 5 ) / 5 ),
                ( y + (Double( arc4random_uniform(10) ) - 5 ) / 5 ),
                ( z +  (Double( arc4random_uniform(10) ) - 5 ) / 5 )
            )
            let move_x:Float = (Float(arc4random_uniform(5)) - 2.5) / 40
            let move_y:Float = (Float(arc4random_uniform(5)) - 2.5) / 40
            let move_z:Float = (Float(arc4random_uniform(5)) - 1.0) / 10
            
            ika_rader_node.frame = CGRect.init(x: Double((ika_node.position.x+150.0)/2.0), y: Double((ika_node.position.z+40.0)*(80.0/60.0)), width: 2.0, height: 2.0)
            ika_array.append(value: ika_node, view: ika_rader_node, move_x: move_x, move_y: move_y, move_z: move_z)
            self.controller.rader.addSubview(ika_rader_node)
            //scene.rootNode.addChildNode(ika_node)
        }
    }
    
    @objc func move(){
        var ika_node:LinkedListNode<SCNNode, UIView, Float, Float, Float>? = ika_array.first
        while( ika_node != nil ){
            let ika:SCNNode! = ika_node?.value
            let rader:UIView! = ika_node?.view
            ika.position = SCNVector3(
                ika.position.x + ika_node!.move_x,
                ika.position.y + ika_node!.move_y,
                ika.position.z + ika_node!.move_z)
            rader.frame.origin.y = rader.frame.origin.y + (0.2*(80.0/60.0))
            
            if(canSee(ika_node: ika_node!)){
                scene.rootNode.addChildNode(ika_node!.value)
            }else{
                ika_node?.value.removeFromParentNode()
            }
            
            if(
                abs(ika.position.z - penguin.position.z) < 1
                    && abs(ika.position.y - penguin.position.y) < 1
                    && abs(ika.position.x - penguin.position.x) < 1
                    && controller.eat_flag == true
                ){
                    let ika_x:Float = ika.position.x;
                    let ika_y:Float = ika.position.y;
                    let ika_z:Float = ika.position.z;
                    // remove object
                    ika.removeFromParentNode()
                    rader.removeFromSuperview()
                    _ = ika_array.removeNode(node: ika_node!)

                
                    // ring setting
                    let ring:SCNScene = SCNScene(named: "art.scnassets/ring_new.dae")!
                    let ring_node:SCNNode = ring.rootNode.childNode(withName: "ring_new", recursively: false)!
                    ring_node.position = SCNVector3(ika_x, ika_y + 1.5, ika_z + 5)
                    
                    // point text setting
                    let text:SCNScene = SCNScene(named: "art.scnassets/point_ika.dae")!
                    let text_node:SCNNode = text.rootNode.childNode(withName: "ikapoint", recursively: false)!
                    text_node.position = SCNVector3(ika_x, ika_y + 2.0, ika_z + 5)
                    text_node.scale = SCNVector3(x: 0.4, y: 0.4, z: 0.4)
                    
                    // add view
                    scene.rootNode.addChildNode(ring_node)
                    scene.rootNode.addChildNode(text_node)
                    
                    // plus point
                    controller.point += 200
                    
                    // set combo
                    controller.combo += 1
                    
                    _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(Ikas.resetCombo), userInfo: nil, repeats: false)
                    
                    var combo_node:SCNNode = SCNNode();
                    if( controller.combo > 1 ){
                        controller.point += 200
                        let combo:SCNScene = SCNScene(named: "art.scnassets/combo.dae")!
                        combo_node = combo.rootNode.childNode(withName: "combo", recursively: false)!
                        combo_node.position = SCNVector3(penguin.position.x + 1.0, penguin.position.y + 1.75, penguin.position.z + 5)
                        combo_node.scale = SCNVector3(0.2, 0.2, 0.2)
                        scene.rootNode.addChildNode(combo_node)
                        
                    }
                    if( controller.combo > 3 && controller.trans_flag == false){
                        controller.enalbleGoldState()
                    }
                    
                    // set point
                    let str:NSMutableString = NSMutableString()
                    str.appendFormat("%d", controller.point)
                    str.append(" points")
                    controller.points.text = str as String
                    
                    // set animation
                    SCNTransaction.begin()
                    SCNTransaction.animationDuration = 1.0
                    ring_node.scale = SCNVector3(1.0, 1.0, 1.0)
                    text_node.scale = SCNVector3(0.8, 0.8, 0.8)
                    if( controller.combo > 1 ){
                        combo_node.scale = SCNVector3(0.8, 0.8, 0.8)
                    }
                    SCNTransaction.commit()
                    
                    
                    _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(Ikas.removeRing), userInfo: nil, repeats: false)
                    
                    
                    
            }else if( ika.position.z > 10 || ika.position.z < -30 ){
                ika.removeFromParentNode()
                rader.removeFromSuperview()
                _ = ika_array.removeNode(node: ika_node!)
            }
            ika_node = ika_node?.next
        }
        
        
    }
    
    func canSee(ika_node :LinkedListNode<SCNNode, UIView, Float, Float, Float>) -> Bool{
        if (
            abs(self.penguin.position.x - ika_node.value.position.x) < 30
                && abs(self.penguin.position.y - ika_node.value.position.y) < 30
                && (self.penguin.position.z - ika_node.value.position.z) < 50
            ){
            return true
        }
        return false
    }
    
    @objc func resetCombo(){
        controller.combo = 0
    }
        
    @objc func removeRing(){
        let ring_node:SCNNode? = scene.rootNode.childNode(withName: "ring_new", recursively: false)
        let text_node:SCNNode? = scene.rootNode.childNode(withName: "ikapoint", recursively: false)
        let combo_node:SCNNode? = scene.rootNode.childNode(withName: "combo", recursively: false)
        
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
