//
//  Fishes.swift
//  testswiftpenguin
//
//  Created by tak on 2015/12/30.
//  Copyright © 2015年 tak. All rights reserved.
//

import Foundation
import UIKit
import SceneKit


class Fishes : NSObject {
    var scene:SCNScene
    var penguin:SCNNode
    var controller:GameViewController
    var fish_array:LinkedList<SCNNode, UIView, Float, Float, Float>
    var dx:Double
    var dy:Double
    
    init(s_scene: SCNScene, penguin_node: SCNNode, game_controller: GameViewController){
        
        self.scene = s_scene
        self.penguin = penguin_node
        self.controller = game_controller
        self.fish_array = LinkedList<SCNNode, UIView, Float, Float, Float>()
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        
        super.init()
        
        // fish generate
        self.generate()
        
        //_ = NSTimer.scheduledTimerWithTimeInterval(2.0, target: self, selector: "changeDelta", userInfo: nil, repeats: true)
        //_ = NSTimer.scheduledTimerWithTimeInterval(0.05, target: self, selector: "move", userInfo: nil, repeats: true)
        let displayLink = CADisplayLink(target: self, selector: #selector(Fishes.move))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: RunLoop.current, forMode: RunLoop.Mode.default)

    }
    
    func changeDelta(){
        self.dx = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
        self.dy = ( Double(arc4random_uniform(10)) - 5.0 ) / 100
    }
    
    func generate(){
        let amount:Int = Int(arc4random_uniform(20)) + 30
        
        
        let x:Double = Double( arc4random_uniform(150) ) - 75
        let y:Double = Double( arc4random_uniform(20) ) - 10
        let z:Double = (Double(arc4random_uniform(40)) - 60)
        
        let iwashi:SCNScene = SCNScene(named: "art.scnassets/iwashi_refine.dae")!
        let iwashi_node_base:SCNNode = iwashi.rootNode.childNode(withName: "iwashi-body", recursively: false)!
        
        for _ in 1...amount {
            let iwashi_node:SCNNode = iwashi_node_base.clone()
            let iwashi_rader_node:UIView = UIView()
            iwashi_node.position = SCNVector3(
                ( x + (Double( arc4random_uniform(10) ) - 5 ) / 5  ),
                ( y + (Double( arc4random_uniform(10) ) - 5 ) / 5  ),
                ( z +  (Double( arc4random_uniform(10) ) - 5 ) / 5 )
            )
            iwashi_rader_node.frame = CGRect.init(x: Double((iwashi_node.position.x+150.0)/2.0), y: Double((iwashi_node.position.z+40.0)*(80.0/60.0)), width: 2.0, height: 2.0)
            iwashi_rader_node.backgroundColor = UIColor.green
            
            let move_x:Float = (Float(arc4random_uniform(5)) - 2.5) / 40
            let move_y:Float = (Float(arc4random_uniform(5)) - 2.5) / 40
            let move_z:Float = 3.0 / 10
            
            fish_array.append(value: iwashi_node, view: iwashi_rader_node, move_x: move_x, move_y: move_y, move_z: move_z)
            
            self.controller.rader.addSubview(iwashi_rader_node)
            //scene.rootNode.addChildNode(iwashi_node)
        }
    }
    
    @objc func move(){
        var fish_node:LinkedListNode<SCNNode, UIView, Float, Float, Float>? = fish_array.first
        while( fish_node != nil ){
            let fish:SCNNode! = fish_node?.value
            let rader:UIView! = fish_node?.view
            fish.position = SCNVector3(
                fish.position.x + fish_node!.move_x,
                fish.position.y + fish_node!.move_y,
                fish.position.z + fish_node!.move_z)
            rader.frame.origin.y = rader.frame.origin.y + (0.4*(80.0/60.0))
            if(canSee(fish_node: fish_node!)){
              scene.rootNode.addChildNode(fish)
            }else{
              fish.removeFromParentNode()
            }
            if(
                abs(fish.position.z - penguin.position.z) < 1
                && abs(fish.position.y - penguin.position.y) < 1
                && abs(fish.position.x - penguin.position.x) < 1
                && controller.eat_flag == true
            ){
                let fish_x:Float = fish.position.x;
                let fish_y:Float = fish.position.y;
                let fish_z:Float = fish.position.z;
                // remove object
                fish.removeFromParentNode()
                rader.removeFromSuperview()
                _ = fish_array.removeNode(node: fish_node!)
                
                // ring setting
                let ring:SCNScene = SCNScene(named: "art.scnassets/ring_new.dae")!
                let ring_node:SCNNode = ring.rootNode.childNode(withName: "ring_new", recursively: false)!
                ring_node.position = SCNVector3(fish_x, fish_y + 1.5, fish_z + 5)
                
                // point text setting
                let text:SCNScene = SCNScene(named: "art.scnassets/point.dae")!
                let text_node:SCNNode = text.rootNode.childNode(withName: "Text", recursively: false)!
                text_node.position = SCNVector3(fish_x, fish_y + 2.0, fish_z + 5)
                text_node.scale = SCNVector3(x: 0.4, y: 0.4, z: 0.4)
                
                // add view
                scene.rootNode.addChildNode(ring_node)
                scene.rootNode.addChildNode(text_node)
                
                // plus point
                controller.point += 100
                
                // set combo
                controller.combo += 1
                
                _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(Fishes.resetCombo), userInfo: nil, repeats: false)
                
                var combo_node:SCNNode = SCNNode();
                if( controller.combo > 1 ){
                    controller.point += 100
                    let combo:SCNScene = SCNScene(named: "art.scnassets/combo.dae")!
                    combo_node = combo.rootNode.childNode(withName: "combo", recursively: false)!
                    combo_node.position = SCNVector3(penguin.position.x + 1.0, penguin.position.y + 1.75, penguin.position.z + 5)
                    combo_node.scale = SCNVector3(0.4, 0.4, 0.4)
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
                
                _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(Fishes.removeRing), userInfo: nil, repeats: false)
                
                
                
            }else if( fish.position.z > 15 || fish.position.z < -40){
                fish.removeFromParentNode()
                rader.removeFromSuperview()
                _ = fish_array.removeNode(node: fish_node!)
            }
            
            fish_node = fish_node?.next
        }
        
    }
    
    func canSee(fish_node :LinkedListNode<SCNNode, UIView, Float, Float, Float>) -> Bool{
        if (
            abs(self.penguin.position.x - fish_node.value.position.x) < 30
            && abs(self.penguin.position.y - fish_node.value.position.y) < 30
            && (self.penguin.position.z - fish_node.value.position.z) < 40
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
        let text_node:SCNNode? = scene.rootNode.childNode(withName: "Text", recursively: false)
        let combo_node:SCNNode? = scene.rootNode.childNode(withName: "combo", recursively: false)
        if( ring_node != nil ){
            ring_node?.removeFromParentNode()
        }
        if( text_node != nil){
            text_node?.removeFromParentNode()
        }
        if( combo_node != nil ){
            combo_node?.removeFromParentNode()
        }
    }

}
