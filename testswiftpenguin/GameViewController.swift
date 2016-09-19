//
//  GameViewController.swift
//  testswiftpenguin
//
//  Created by tak on 2015/12/30.
//  Copyright (c) 2015年 tak. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var scene: SCNScene
    var bubble_array: LinkedList = LinkedList<SCNNode>()
    var cycle_bubble_array:LinkedList = LinkedList<SCNNode>()
    var ground_array:LinkedList = LinkedList<SCNNode>()
    var camera_btn: UIImageView
    var eat_btn: UIButton
    var eat_timer: Timer
    var move_btn: UIImageView
    var cameraNode: SCNNode
    var lightNode: SCNNode
    var ambientLightNode: SCNNode
    var shati_node: SCNNode?
    var shati_node2: SCNNode?
    var shati_node3: SCNNode?
    var ami_node: SCNNode?
    var ei_node: SCNNode?
    var groundMaterial: SCNMaterial
    var scnView: SCNView
    var bubble_flag: Bool = false
    var cancel_minus_efect_flag:Bool = false
    var trans_flag:Bool = false
    var gold_ring:SCNNode?
    var gold_ring_timer:Timer
    var move_divide:Int = 100
    var penguin_node:SCNNode = SCNNode();
    var penguin_base_material:[SCNMaterial]
    var banner:UIImageView
    var points: UILabel
    var point: Int = 0
    var depth_label: UILabel
    var depth: Int = 0
    
    var eat_flag: Bool = false
    var combo: Int = 0
    
    // touch state
    var touch_state:Bool = false

    required init(coder aDecoder: NSCoder) {
        
        // penguin scene
        self.scene = SCNScene()
        
        // each node init
        self.cameraNode = SCNNode()
        self.lightNode = SCNNode()
        self.ambientLightNode = SCNNode()
        self.gold_ring = nil
        self.shati_node = nil
        self.shati_node2 = nil
        self.shati_node3 = nil
        self.ami_node = nil
        self.ei_node = nil
        
        // other init
        self.groundMaterial = SCNMaterial()
        self.scnView = SCNView()
        
        self.penguin_base_material = []
        self.gold_ring_timer = Timer()
        self.eat_timer = Timer()
        
        // button init
        self.camera_btn = UIImageView(image: UIImage(named: "camera_btn.png"))
        self.move_btn = UIImageView(image: UIImage(named: "move_btn.png"))
        self.eat_btn = UIButton(type: UIButtonType.custom)
        
        // label init
        self.points = UILabel(frame: CGRect(x: 50, y: 30, width: 100, height: 50))
        self.depth_label = UILabel(frame: CGRect(x: 560, y: 30, width: 100, height: 50))

        self.banner = UIImageView(image: UIImage(named: "banner_start.png"))
        
        super.init(coder: aDecoder)!;
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.banner.frame = CGRect(x: 224, y: 80, width: 233, height: 55)
        self.displayLoadingBanner()
        
        self.scene = SCNScene(named: "art.scnassets/new_world.dae")!
        let ground:SCNNode = self.scene.rootNode.childNode(withName: "ground", recursively: false)!
        ground.scale = SCNVector3(150, 100, 100)
        ground.position = SCNVector3(0, -40, 0)
        
        let sea:SCNScene = SCNScene(named: "art.scnassets/sea.dae")!
        let sea_node:SCNNode = sea.rootNode.childNode(withName: "sea", recursively: false)!
        sea_node.scale = SCNVector3(150, 100, 100)
        sea_node.opacity = 0.4
        sea_node.position = SCNVector3(0, 25, 0)
        self.scene.rootNode.addChildNode(sea_node)
        
        
        // fog settings
        self.scene.fogColor = UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        self.scene.fogStartDistance = 0.0;
        self.scene.fogEndDistance = 50.0;
        self.scene.fogDensityExponent = 1.0;
        
        // create and add a camera to the scene
        self.cameraNode.camera = SCNCamera()
        self.cameraNode.position = SCNVector3(0, 2, 13)
        self.cameraNode.camera?.focalDistance = 10.0
        self.cameraNode.camera?.focalSize = 30.0
        self.cameraNode.camera?.focalBlurRadius = 0.15
        self.scene.rootNode.addChildNode(cameraNode)
        
        // create and add a light to the scene
        self.lightNode.light = SCNLight()
        self.lightNode.light!.type = SCNLight.LightType.omni
        self.lightNode.light!.color = UIColor.white//UIColor(red: 0.96, green: 0.96, blue: 0.80, alpha: 0.9)
        self.lightNode.light!.intensity = 2000
        self.lightNode.position = SCNVector3(x: 0, y: 50, z: 0)
        self.lightNode.light!.castsShadow = true
        self.scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        self.ambientLightNode.light = SCNLight()
        self.ambientLightNode.light!.type = SCNLight.LightType.omni
        self.ambientLightNode.light!.color = UIColor.white
        //self.ambientLightNode.light?.castsShadow = true
        self.ambientLightNode.position = SCNVector3(0, 10, 15)
        self.scene.rootNode.addChildNode(ambientLightNode)
        
        // create penguin
        let penguin = SCNScene(named: "art.scnassets/penguin3.dae")!
        self.penguin_node = penguin.rootNode.childNode(withName: "Cube", recursively: false)!
        self.scene.rootNode.addChildNode(penguin_node)

        
        // create sea
        let seaNode = SCNNode();
        seaNode.geometry = SCNBox(width: 400, height: 1, length: 400, chamferRadius: 0)
        seaNode.position = SCNVector3(0, 40, 0)
        let seaMaterial = SCNMaterial()
        seaMaterial.diffuse.contents = UIColor(red: 0.6, green: 0.85, blue: 0.94, alpha: 0.3)
        seaMaterial.fresnelExponent = 10.0
        seaNode.geometry!.materials = [seaMaterial]
        //self.scene.rootNode.addChildNode(seaNode)
        
        // create seaend
        let seaEndNode = SCNNode();
        seaEndNode.geometry = SCNBox(width: 400, height: 80, length: 2, chamferRadius: 0)
        seaEndNode.position = SCNVector3(0, 0, -100)
        let seaEndMaterial = SCNMaterial()
        seaEndMaterial.diffuse.contents = UIColor(red: 0, green: 0, blue: 1, alpha: 0.8)
        seaEndNode.geometry!.materials = [seaEndMaterial]
        //self.scene.rootNode.addChildNode(seaEndNode)
        
        // create ground
        let groundNode = SCNNode();
        groundNode.geometry = SCNBox(width: 400, height: 3, length: 400, chamferRadius: 0)
        groundNode.position = SCNVector3(0, -40, 0)
        self.groundMaterial.transparency = 0.6
        self.groundMaterial.diffuse.contents = UIImage(named: "ground.jpg")
        self.groundMaterial.fresnelExponent = 10.0
        groundNode.geometry!.materials = [self.groundMaterial]
        ground_array.append(value: groundNode)
        //self.scene.rootNode.addChildNode(groundNode)
        
        // create camera button
        self.camera_btn.frame = CGRect(x: 500, y: 100, width: 64, height: 64)
        self.camera_btn.alpha = 0.8
        self.view.addSubview(self.camera_btn)
        
        // create move button
        self.move_btn.frame = CGRect(x: 50, y: 250, width: 64, height: 64)
        self.view.addSubview(self.move_btn)
        
        // create eat button
        self.eat_btn.frame = CGRect(x: 540, y: 240, width: 84, height: 84)
        self.eat_btn.setImage(UIImage(named: "eat_btn.png"), for: UIControlState())
        self.eat_btn.setImage(UIImage(named: "eat_btn_press.png"), for: UIControlState.highlighted)
        self.eat_btn.addTarget(self, action: #selector(GameViewController.eatState), for: UIControlEvents.touchDown)
        self.view.addSubview(self.eat_btn)
        
        // create points label
        self.points.text = "0 points"
        self.points.font = UIFont.systemFont(ofSize: 15)
        self.points.textColor = UIColor.white
        self.view.addSubview(self.points)
        
        // create depth label
        self.depth_label.text = "40 m"
        self.depth_label.font = UIFont.systemFont(ofSize: 15)
        self.depth_label.textColor = UIColor.white
        self.view.addSubview(self.depth_label)
        
        
        // retrive sceneview
        self.scnView = self.view as! SCNView
        
        // set the scene to the view
        self.scnView.scene = self.scene
        
        
        // show statistics such as fps and timing information
        //self.scnView.showsStatistics = true
        
        // configure the view
        scnView.backgroundColor = UIColor(red: 0, green: 0, blue: 1, alpha: 1.0)
        
        _ = Timer.scheduledTimer(timeInterval: 0.3, target: self, selector: #selector(GameViewController.generateIwashi), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.generateIka), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GameViewController.generateShati), userInfo: nil, repeats: false)
        _ = Timer.scheduledTimer(timeInterval: 22.5, target: self, selector: #selector(GameViewController.generateAmi), userInfo: nil, repeats: false)
        _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(GameViewController.generateEi), userInfo: nil, repeats: false)
        _ = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(GameViewController.moveObject), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(GameViewController.generateCycleBubble), userInfo: nil, repeats: true)
        _ = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(GameViewController.displayStartBanner), userInfo: nil, repeats: false)
        let displayLink = CADisplayLink(target: self, selector: #selector(GameViewController.moveObject))
        displayLink.preferredFramesPerSecond = 30
        displayLink.add(to: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        
    }
    
    func generateIwashi(){
        _ = Fishes(s_scene: self.scene, penguin_node: self.penguin_node, game_controller: self)
    }
    
    func generateIka(){
        _ = Ikas(s_scene: self.scene, penguin_node: self.penguin_node, game_controller: self)
    }
    
    func generateBubble(){
        _ = Bubbles(s_scene: self.scene, penguin_node: self.penguin_node, game_controller: self)
    }
    
    func generateCycleBubble(){
        _ = CycleBubbles(s_scene: self.scene, penguin_node: self.penguin_node, game_controller: self)
    }
    
    func displayLoadingBanner(){
        self.displayBanner("banner_loading.png")
    }
    
    func displayStartBanner(){
        self.displayBanner("banner_start.png")
    }
    
    func displayAmiBanner(){
        self.displayBanner("banner_ami.png")
    }
    
    func displayCollisionBanner(){
        self.displayBanner("banner_collission.png")
    }
    
    func displayTransBanner(){
        self.displayBanner("banner_trans.png")
    }
    
    func hideBanner(){
        self.banner.removeFromSuperview()
    }
    
    func displayBanner(_ image_name:String){
        self.banner.image = UIImage(named: image_name)
        self.view.addSubview(self.banner)
        _ = Timer.scheduledTimer(timeInterval: 2.5, target: self, selector: #selector(GameViewController.hideBanner), userInfo: nil, repeats: false)
    }
    
    func generateShati(){
        let shati:SCNScene = SCNScene(named: "art.scnassets/shati_new.dae")!
        self.shati_node = shati.rootNode.childNode(withName: "shati_new", recursively: false)
        self.shati_node!.scale = SCNVector3(1.5, 1.5, 1.5)
            
        let x:Double = Double(arc4random_uniform(100)) - 50
        let y:Double = Double(arc4random_uniform(20)) - 10
        let z:Double = -120
            
        self.shati_node!.position = SCNVector3(x, y, z)
        self.scene.rootNode.addChildNode(self.shati_node!)
        
        // shati2
        let shati2:SCNScene = SCNScene(named: "art.scnassets/shati_new.dae")!
        self.shati_node2 = shati2.rootNode.childNode(withName: "shati_new", recursively: false)
        self.shati_node2!.scale = SCNVector3(1.5, 1.5, 1.5)
        
        let x_2:Double = Double(arc4random_uniform(100)) - 50
        let y_2:Double = Double(arc4random_uniform(20)) - 10
        let z_2:Double = -110
        
        self.shati_node2!.position = SCNVector3(x_2, y_2, z_2)
        self.scene.rootNode.addChildNode(self.shati_node2!)
        
        // shati3
        let shati3:SCNScene = SCNScene(named: "art.scnassets/shati_new.dae")!
        self.shati_node3 = shati3.rootNode.childNode(withName: "shati_new", recursively: false)
        self.shati_node3!.scale = SCNVector3(1.5, 1.5, 1.5)
        
        let x_3:Double = Double(arc4random_uniform(100)) - 50
        let y_3:Double = Double(arc4random_uniform(20)) - 10
        let z_3:Double = -130
        
        self.shati_node3!.position = SCNVector3(x_3, y_3, z_3)
        self.scene.rootNode.addChildNode(self.shati_node3!)
        
    }

    
    func adjustShati(){
        let amount:Int = Int(arc4random_uniform(3))
        
        let x:Double = Double(arc4random_uniform(100)) - 50
        let y:Double = Double(arc4random_uniform(20)) - 10
        let z:Double = -120;
        
        self.shati_node!.position = SCNVector3(x, y, z)
        
        if( amount > 0 ){
            let x_2:Double = Double(arc4random_uniform(100)) - 50
            let y_2:Double = Double(arc4random_uniform(20)) - 10
            let z_2:Double = -110;
            
            self.shati_node2!.position = SCNVector3(x_2, y_2, z_2)
        }
        if( amount > 1 ){
            let x_3:Double = Double(arc4random_uniform(100)) - 50
            let y_3:Double = Double(arc4random_uniform(20)) - 10
            let z_3:Double = -130;
            
            self.shati_node3!.position = SCNVector3(x_3, y_3, z_3)
        }
    }
    
    func generateAmi(){
        let ami:SCNScene = SCNScene(named: "art.scnassets/ami-whole.dae")!
        if( self.ami_node == nil){
            self.ami_node = ami.rootNode.childNode(withName: "ami-whole", recursively: false)
            self.ami_node!.opacity = 0.6
            self.ami_node?.scale = SCNVector3(5, 5, 5)
            
            let x:Double = Double(arc4random_uniform(100)) - 50
            let y:Double = Double(arc4random_uniform(10)) - 5
            let z:Double = -120;
            
            self.ami_node!.position = SCNVector3(x, y, z)
            self.scene.rootNode.addChildNode(self.ami_node!)
        }
    }
    
    func adjustAmi(){
        
        let x:Double = Double(arc4random_uniform(100)) - 50
        let y:Double = Double(arc4random_uniform(10)) - 5
        let z:Double = -120;
        
        self.ami_node!.position = SCNVector3(x, y, z)
    }
    
    func generateEi(){
        let ei:SCNScene = SCNScene(named: "art.scnassets/ei.dae")!
        if( self.ei_node == nil){
            self.ei_node = ei.rootNode.childNode(withName: "ei", recursively: false)
            let x:Double = Double(arc4random_uniform(100)) - 50
            let y:Double = Double(arc4random_uniform(20)) - 10
            let z:Double = -120;
            
            self.ei_node!.position = SCNVector3(x, y, z)
            self.scene.rootNode.addChildNode(self.ei_node!)
        }
    }
    
    func adjustEi(){
        self.ei_node = self.scene.rootNode.childNode(withName: "ei", recursively: false)
        let x:Double = Double(arc4random_uniform(100)) - 50
        let y:Double = Double(arc4random_uniform(20)) - 10
        let z:Double = -120;
        
        self.ei_node!.position = SCNVector3(x, y, z)
    }
    
    func moveObject(){
        if( self.shati_node != nil ){
            self.shati_node!.position = SCNVector3(
                x: self.shati_node!.position.x,
                y: self.shati_node!.position.y,
                z: self.shati_node!.position.z + 0.15
            )
            if( self.shati_node!.position.z > 20 ){
                //self.shati_node!.removeFromParentNode()
                //self.shati_node = nil
                self.adjustShati()
            }else if(
                fabs(self.penguin_node.position.z - self.shati_node!.position.z) < 3
                    && fabs(self.penguin_node.position.y - self.shati_node!.position.y) < 3
                    && fabs(self.penguin_node.position.x - self.shati_node!.position.x) < 2
                    && self.cancel_minus_efect_flag == false
            ){
                if( self.trans_flag == false ){
                    self.minusEfect()
                }else if( self.trans_flag == true ){
                    self.eatEfect(node: self.shati_node!)
                }

            }
        }
        if( self.shati_node2 != nil ){
            if( self.shati_node2!.position.z < 30 ){
                self.shati_node2!.position = SCNVector3(
                    x: self.shati_node2!.position.x,
                    y: self.shati_node2!.position.y,
                    z: self.shati_node2!.position.z + 0.2
                )
                if(
                    fabs(self.penguin_node.position.z - self.shati_node2!.position.z) < 3
                    && fabs(self.penguin_node.position.y - self.shati_node2!.position.y) < 3
                    && fabs(self.penguin_node.position.x - self.shati_node2!.position.x) < 2
                    && self.cancel_minus_efect_flag == false
                ){
                    if( self.trans_flag == false ){
                        self.minusEfect()
                    }else if( self.trans_flag == true ){
                        self.eatEfect(node: self.shati_node2!)
                    }
                    
                }
            }
        }
        if( self.shati_node3 != nil ){
            if( self.shati_node3!.position.z < 30 ){
                self.shati_node3!.position = SCNVector3(
                    x: self.shati_node3!.position.x,
                    y: self.shati_node3!.position.y,
                    z: self.shati_node3!.position.z + 0.25
                )
                if(
                    fabs(self.penguin_node.position.z - self.shati_node3!.position.z) < 3
                        && fabs(self.penguin_node.position.y - self.shati_node3!.position.y) < 3
                        && fabs(self.penguin_node.position.x - self.shati_node3!.position.x) < 2
                        && self.cancel_minus_efect_flag == false
                    ){
                        if( self.trans_flag == false ){
                            self.minusEfect()
                        }else if( self.trans_flag == true ){
                            self.eatEfect(node: self.shati_node3!)
                        }
                        
                }
            }
        }
        if( self.ami_node != nil ){
            self.ami_node!.position = SCNVector3(
                x: self.ami_node!.position.x,
                y: self.ami_node!.position.y,
                z: self.ami_node!.position.z + 0.10
            )
            if( self.ami_node!.position.z > 20 ){
                //self.ami_node!.removeFromParentNode()
                //self.ami_node = nil
                self.adjustAmi()
            }else if(
                fabs(self.penguin_node.position.z - self.ami_node!.position.z) < 3
                    && fabs(self.penguin_node.position.y - self.ami_node!.position.y) < 10
                    && fabs(self.penguin_node.position.x - self.ami_node!.position.x) < 10
                    && self.cancel_minus_efect_flag == false
                ){
                    if( self.trans_flag == false ){
                        self.minusEfect()
                    }else if( self.trans_flag == true ){
                        self.eatEfect(node: self.ami_node!)
                    }
                    
            }else if( fabs(self.ami_node!.position.z - Float(-80)) < 0.1 ){
                self.displayAmiBanner()
            }
        }
        if( self.ei_node != nil ){
            self.ei_node!.position = SCNVector3(
                x: self.ei_node!.position.x,
                y: self.ei_node!.position.y,
                z: self.ei_node!.position.z + 0.16
            )
            if( self.ei_node!.position.z > 20 ){
                //self.ami_node!.removeFromParentNode()
                //self.ami_node = nil
                self.adjustEi()
            }else if(
                fabs(self.penguin_node.position.z - self.ei_node!.position.z) < 2
                    && fabs(self.penguin_node.position.y - self.ei_node!.position.y) < 2
                    && fabs(self.penguin_node.position.x - self.ei_node!.position.x) < 2
                    && self.cancel_minus_efect_flag == false
                ){
                    if( self.trans_flag == false ){
                        self.minusEfect()
                    }else if( self.trans_flag == true ){
                        self.eatEfect(node: self.ei_node!)
                    }
                    
            }
        }
        /*var bubble_node:LinkedListNode<SCNNode>? = bubble_array.first
        while( bubble_node != nil ){
            let bubble:SCNNode! = bubble_node?.value
            bubble.position = SCNVector3(x: bubble.position.x, y: bubble.position.y, z: bubble.position.z + 0.15)
            if( bubble.position.z > 20 ){
                bubble.removeFromParentNode()
                bubble_array.removeNode(node: bubble_node!)            }
            bubble_node = bubble_node?.next
        }*/
        /*
        var cycle_bubble_node:LinkedListNode<SCNNode>? = cycle_bubble_array.first
        while( cycle_bubble_node != nil ){
            let cycle_bubble:SCNNode! = cycle_bubble_node?.value
            cycle_bubble.position = SCNVector3(x: cycle_bubble.position.x, y: cycle_bubble.position.y + 0.1, z: cycle_bubble.position.z + 0.15)
            if( cycle_bubble.position.y > penguin.position.y + 10 ){
                cycle_bubble.removeFromParentNode()
                cycle_bubble_array.removeNode(node: cycle_bubble_node!)
            }
            cycle_bubble_node = cycle_bubble_node?.next
        }
        */
    }
    
    func eatEfect( node p_node:SCNNode )
    {
        let node_x:Float = p_node.position.x;
        let node_y:Float = p_node.position.y;
        let node_z:Float = p_node.position.z;
        // remove object
        p_node.position.z = 21;
        
        // ring setting
        let ring:SCNScene = SCNScene(named: "art.scnassets/ring_new.dae")!
        let ring_node:SCNNode = ring.rootNode.childNode(withName: "ring_new", recursively: false)!
        ring_node.position = SCNVector3(node_x, node_y + 1.5, node_z + 5)
        
        // point text setting
        let text:SCNScene = SCNScene(named: "art.scnassets/point_ika.dae")!
        let text_node:SCNNode = text.rootNode.childNode(withName: "ikapoint", recursively: false)!
        text_node.position = SCNVector3(node_x, node_y + 2.0, node_z + 5)
        text_node.scale = SCNVector3(x: 0.4, y: 0.4, z: 0.4)
        
        // add view
        scene.rootNode.addChildNode(ring_node)
        scene.rootNode.addChildNode(text_node)
        
        // plus point
        self.point += 200
        
        // set combo
        self.combo += 1
        
        _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(GameViewController.resetCombo), userInfo: nil, repeats: false)
        
        var combo_node:SCNNode = SCNNode();
        if( self.combo > 1 ){
            self.point += 200
            let combo:SCNScene = SCNScene(named: "art.scnassets/combo.dae")!
            combo_node = combo.rootNode.childNode(withName: "combo", recursively: false)!
            combo_node.position = SCNVector3(self.penguin_node.position.x + 1.0, self.penguin_node.position.y + 1.75, self.penguin_node.position.z + 5)
            combo_node.scale = SCNVector3(0.2, 0.2, 0.2)
            scene.rootNode.addChildNode(combo_node)
            
        }
        if( self.combo > 5 && self.trans_flag == false){
            self.enalbleGoldState()
        }
        
        // set point
        let str:NSMutableString = NSMutableString()
        str.appendFormat("%d", self.point)
        str.append(" points")
        self.points.text = str as String
        
        // set animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        ring_node.scale = SCNVector3(1.0, 1.0, 1.0)
        text_node.scale = SCNVector3(0.8, 0.8, 0.8)
        if( self.combo > 1 ){
            combo_node.scale = SCNVector3(0.8, 0.8, 0.8)
        }
        SCNTransaction.commit()
        
        
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameViewController.removeRing), userInfo: nil, repeats: false)
    }
    
    func resetCombo(){
        self.combo = 0
    }
    
    func removeRing(){
        let ring_node:SCNNode? = scene.rootNode.childNode(withName: "ring_new", recursively: false)
        let text_node:SCNNode? = scene.rootNode.childNode(withName: "ikapoint", recursively: false)
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

    
    func minusEfect()
    {
        self.point -= 50
        // set point
        let str:NSMutableString = NSMutableString()
        str.appendFormat("%d", self.point)
        str.append(" points")
        self.points.text = str as String
        
        // set minus
        let red_ring:SCNScene = SCNScene(named: "art.scnassets/ring_new.dae")!
        let red_ring_node:SCNNode = red_ring.rootNode.childNode(withName: "ring_new", recursively: false)!
        red_ring_node.position = SCNVector3(self.penguin_node.position.x, self.penguin_node.position.y + 1.5, self.penguin_node.position.z + 5)
        let red_ring_material:SCNMaterial = SCNMaterial()
        red_ring_material.diffuse.contents = UIColor.red
        red_ring_node.geometry?.materials = [red_ring_material]
        
        // point text setting
        let text:SCNScene = SCNScene(named: "art.scnassets/point_minus.dae")!
        let text_node:SCNNode = text.rootNode.childNode(withName: "minus", recursively: false)!
        text_node.position = SCNVector3(self.penguin_node.position.x, self.penguin_node.position.y + 2.0, self.penguin_node.position.z + 5)
        text_node.scale = SCNVector3(x: 0.4, y: 0.4, z: 0.4)
        
        // set 3d view
        self.scene.rootNode.addChildNode(red_ring_node)
        self.scene.rootNode.addChildNode(text_node)
        
        // set animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        red_ring_node.scale = SCNVector3(1.0, 1.0, 1.0)
        text_node.scale = SCNVector3(0.8, 0.8, 0.8)
        SCNTransaction.commit()
        
        self.displayCollisionBanner()
   
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameViewController.removeMinus), userInfo: nil, repeats: false)
        _ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameViewController.setYesCancelMinus), userInfo: nil, repeats: false)
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.setNoCancelMinus), userInfo: nil, repeats: false)
    }
    
    func removeMinus(){
        let ring_node:SCNNode? = scene.rootNode.childNode(withName: "ring_new", recursively: false)
        let text_node:SCNNode? = scene.rootNode.childNode(withName: "minus", recursively: false)
        if( ring_node != nil ){
            ring_node?.removeFromParentNode()
        }
        if( text_node != nil ){
            text_node?.removeFromParentNode()
        }
    }
    
    // penguin direction change
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let first_touch:UITouch = touches.first!
        let point_touch:CGPoint = first_touch.location(in: self.view)
        if( 0 < point_touch.x && point_touch.x < 200 && 200 < point_touch.y && point_touch.y < 400){
            
            // set dx dy
            let dx:Double = Double( CGFloat(72) - point_touch.x )
            let dy:Double = Double( CGFloat(282) - point_touch.y )
            
            // set move btn
            self.move_btn.frame = CGRect(x: 50 - dx, y: 250 - dy, width: 64, height: 64)
            
            let rotation:SCNVector4 = SCNVector4(dx / 300 * -1, 1, dy / 300 * -1, M_PI)
            
            var p_new_x:Double = Double(self.penguin_node.position.x) - dx / Double(self.move_divide)
            var p_new_y:Double = Double(self.penguin_node.position.y) - dy / Double(self.move_divide)
            
            // generate bubble
            if( ( dx > 10 || dy > 10 ) && self.bubble_flag == false){
                // generate bubble
                self.generateBubble()
                _ = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(GameViewController.setYesBubble), userInfo: nil, repeats: false)
                _ = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(GameViewController.setNoBubble), userInfo: nil, repeats: false)
            }
            
            // stop level
            if( p_new_x < -150){
                p_new_x = -150
            }else if( p_new_x > 150 ){
                p_new_x = 150
            }
            
            if( p_new_y < -20){
                p_new_y = -20
            }else if( p_new_y > 20 ){
                p_new_y = 20
            }
            
            let position:SCNVector3 = SCNVector3(p_new_x, p_new_y, Double(self.penguin_node.position.z))
            
            // set depth
            self.depth = Int(self.calculateDepth(p_new_y))
            let str:NSMutableString = NSMutableString()
            str.appendFormat("%d", self.depth)
            str.append(" m")
            self.depth_label.text = str as String
            
            var gold_ring_instance:SCNNode?
            if( gold_ring != nil ){
                gold_ring_instance = self.scene.rootNode.childNode(withName: "ring_gold", recursively: false)!
            }
            // set animation
            SCNTransaction.begin()
            self.penguin_node.rotation = rotation
            self.penguin_node.position = position
            self.cameraNode.position = SCNVector3(self.penguin_node.position.x, self.penguin_node.position.y + 2, self.penguin_node.position.z + 13)
            if( gold_ring != nil ){
                gold_ring_instance!.position = SCNVector3(self.penguin_node.position.x, self.penguin_node.position.y, self.penguin_node.position.z)
            }
            SCNTransaction.commit()
            
            // set lightnodes
            self.lightNode.position = SCNVector3(self.penguin_node.position.x, self.penguin_node.position.y + 40, self.penguin_node.position.z)
            self.ambientLightNode.position = SCNVector3(self.penguin_node.position.x, self.penguin_node.position.y + 10, self.penguin_node.position.z + 15)
            
            
        }else if( 483 < point_touch.x && point_touch.x < 583 && 82 < point_touch.y && point_touch.y < 182 ){
            
            // set dx dy
            let dx:Double = Double( point_touch.x - CGFloat(533) )
            let dy:Double = Double( point_touch.y - CGFloat(132) ) * -1
            
            // set camera btn
            self.camera_btn.frame = CGRect(x: 500 + dx, y: 100 - dy, width: 64, height: 64)
            
            // position calculate
            let r:Double = sqrt( 2 * 2 + 13 * 13 )
            let x_add_angle:Double = dx * M_PI_2 / 40
            //let alpha:Double = atan( 2 / 13 )
            let y_add_angle:Double = dy * M_PI_2 / 40
            
            let position_x:Double = Double(self.penguin_node.position.x) + r * cos(y_add_angle) * sin(x_add_angle)
            let position_y:Double = Double(self.penguin_node.position.y) + r * sin(y_add_angle)
            let position_z:Double = Double(self.penguin_node.position.z) + r * cos(y_add_angle) * cos(x_add_angle)
            
            self.cameraNode.position = SCNVector3(position_x, position_y, position_z)
            let weight:Double = (abs(y_add_angle/M_PI_2) + abs(x_add_angle/M_PI_2))
            self.cameraNode.rotation = SCNVector4(-y_add_angle/M_PI_2, x_add_angle/M_PI_2, 0, weight)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.cameraNode.position = SCNVector3(self.penguin_node.position.x, self.penguin_node.position.y + 2, self.penguin_node.position.z + 13)
        self.cameraNode.rotation = SCNVector4(0, 0, 0, M_PI)
        self.camera_btn.frame = CGRect(x: 500, y: 100, width: 64, height: 64)
    }
    
    // generate bubble
    /*
    func generateBubble(){
        let penguin:SCNNode = self.scene.rootNode.childNode(withName: "Cube", recursively: false)!
        
        let bubble:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node:SCNNode = bubble.rootNode.childNode(withName: "bubble", recursively: false)!
        
        let bubble2:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node2:SCNNode = bubble2.rootNode.childNode(withName: "bubble", recursively: false)!
        
        let bubble3:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node3:SCNNode = bubble3.rootNode.childNode(withName: "bubble", recursively: false)!
        
        let bubble4:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node4:SCNNode = bubble4.rootNode.childNode(withName: "bubble", recursively: false)!
        
        let bubble5:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node5:SCNNode = bubble5.rootNode.childNode(withName: "bubble", recursively: false)!
        
        let bubble6:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node6:SCNNode = bubble6.rootNode.childNode(withName: "bubble", recursively: false)!
        
        let bubble7:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node7:SCNNode = bubble7.rootNode.childNode(withName: "bubble", recursively: false)!
        
        let bubble8:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node8:SCNNode = bubble8.rootNode.childNode(withName: "bubble", recursively: false)!
        
        let bubble9:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
        let bubble_node9:SCNNode = bubble9.rootNode.childNode(withName: "bubble", recursively: false)!

        
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
        
        bubble_array.append(value: bubble_node)
        bubble_array.append(value: bubble_node2)
        bubble_array.append(value: bubble_node3)
        bubble_array.append(value: bubble_node4)
        bubble_array.append(value: bubble_node5)
        bubble_array.append(value: bubble_node6)
        bubble_array.append(value: bubble_node7)
        bubble_array.append(value: bubble_node8)
        bubble_array.append(value: bubble_node9)
        
        self.scene.rootNode.addChildNode(bubble_node)
        self.scene.rootNode.addChildNode(bubble_node2)
        self.scene.rootNode.addChildNode(bubble_node3)
        self.scene.rootNode.addChildNode(bubble_node4)
        self.scene.rootNode.addChildNode(bubble_node5)
        self.scene.rootNode.addChildNode(bubble_node6)
        self.scene.rootNode.addChildNode(bubble_node7)
        self.scene.rootNode.addChildNode(bubble_node8)
        self.scene.rootNode.addChildNode(bubble_node9)

        /*_ = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(GameViewController.setYesBubble), userInfo: nil, repeats: false)
        _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.setNoBubble), userInfo: nil, repeats: false)*/
        
        
    }*/
    /*
    func generateCycleBubble(){
        for index in 1...10 {
            let penguin:SCNNode = self.scene.rootNode.childNode(withName: "Cube", recursively: false)!
            
            let bubble:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node:SCNNode = bubble.rootNode.childNode(withName: "bubble", recursively: false)!
            
            let bubble2:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node2:SCNNode = bubble2.rootNode.childNode(withName: "bubble", recursively: false)!
            
            let bubble3:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node3:SCNNode = bubble3.rootNode.childNode(withName: "bubble", recursively: false)!
            
            let bubble4:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node4:SCNNode = bubble4.rootNode.childNode(withName: "bubble", recursively: false)!
            
            let bubble5:SCNScene = SCNScene(named: "art.scnassets/bubble.dae")!
            let bubble_node5:SCNNode = bubble5.rootNode.childNode(withName: "bubble", recursively: false)!
            
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
            
            self.scene.rootNode.addChildNode(bubble_node)
            self.scene.rootNode.addChildNode(bubble_node2)
            self.scene.rootNode.addChildNode(bubble_node3)
            self.scene.rootNode.addChildNode(bubble_node4)
            self.scene.rootNode.addChildNode(bubble_node5)
        }
    }*/
    
    // calculate depth
    func calculateDepth( _ y:Double ) -> Double{
        return abs(y - Double(40))
    }
    
    // set true bubble_flag
    func setYesBubble(){
        self.bubble_flag = true
    }
    
    // set false bubble_flag
    func setNoBubble(){
        self.bubble_flag = false
    }
    
    func setYesCancelMinus(){
        self.cancel_minus_efect_flag = true
    }
    
    func setNoCancelMinus(){
        self.cancel_minus_efect_flag = false
    }
    
    // eat
    func eatState(){
        self.eat_flag = true
        self.eat_timer.invalidate()
        self.eat_timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.notEatState), userInfo: nil, repeats: false)
    }
    
    // cancel eat
    func notEatState(){
        self.eat_flag = false
    }
    
    // touchstate off
    func setDisableTouchState(){
        self.touch_state = false
    }
    
    // enalble gold mode
    func enalbleGoldState(){
        self.trans_flag = true
        self.move_divide = 50;
        let gold_material:SCNMaterial = SCNMaterial()
        gold_material.diffuse.contents = UIColor.yellow
        gold_material.transparency = 0.2
        self.penguin_base_material = (self.penguin_node.geometry?.materials)!
        var gold_style:[SCNMaterial] = self.penguin_base_material
        gold_style.removeFirst()
        gold_style.append(gold_material)
        self.penguin_node.geometry?.materials = gold_style
        // ring setting
        let ring:SCNScene = SCNScene(named: "art.scnassets/ring_gold.dae")!
        self.gold_ring = ring.rootNode.childNode(withName: "ring_gold", recursively: false)!
        self.gold_ring!.position = SCNVector3(self.penguin_node.position.x, self.penguin_node.position.y, self.penguin_node.position.z)
        let green_ring_material:SCNMaterial = SCNMaterial()
        green_ring_material.diffuse.contents = UIColor.green
        self.gold_ring!.geometry?.materials = [green_ring_material]
        self.scene.rootNode.addChildNode(self.gold_ring!)
        displayTransBanner()
        self.gold_ring_timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(GameViewController.animationGoldRing), userInfo: nil, repeats: true)
        
        _ = Timer.scheduledTimer(timeInterval: 15.0, target: self, selector: #selector(GameViewController.cancelGoldState), userInfo: nil, repeats: false)
    }
    
    // animation gold ring
    func animationGoldRing(){
        let gold_ring_instance:SCNNode? = self.scene.rootNode.childNode(withName: "ring_gold", recursively: false)!
        gold_ring_instance!.scale = SCNVector3(4.0, 4.0, 4.0)
        gold_ring_instance!.opacity = 0.5
        // set animation
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 1.0
        gold_ring_instance!.opacity = 0.0
        gold_ring_instance!.scale = SCNVector3(12.0, 12.0, 12.0)
        SCNTransaction.commit()
    }
    
    // cancel gold mode
    func cancelGoldState(){
        self.trans_flag = false
        self.move_divide = 100;
        self.penguin_node.geometry?.materials = self.penguin_base_material
        let gold_ring_instance:SCNNode? = self.scene.rootNode.childNode(withName: "ring_gold", recursively: false)!
        gold_ring_instance?.removeFromParentNode()
        self.gold_ring_timer.invalidate()
        self.gold_ring = nil
    }
    
    override var shouldAutorotate : Bool {
        return true
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
