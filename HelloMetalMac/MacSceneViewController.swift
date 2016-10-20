//
//  ViewController.swift
//  HelloMetalMac
//
//  Created by Igor Poltavtsev on 14.10.16.
//  Copyright © 2016 Razeware LLC. All rights reserved.
//

import Cocoa
import simd

class MacSceneViewController: MetalViewController, MetalViewControllerDelegate {

    var worldModelMatrix:float4x4!
    var vectorsObject: Vectors!
    
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    var lastDoublePanLocation: CGPoint!
    var lastScale: CGFloat!
    
    var multiplier: Float! {
        didSet {
            multiplierLabel.stringValue = String(format: "multiplier = %.2f", multiplier)
        }
    }
    
    @IBOutlet weak var multiplierLabel: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        multiplier = 0.05
        
        worldModelMatrix = float4x4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -1)
        worldModelMatrix.rotateAroundX(0, y: float4x4.degrees(toRad: 90), z: 0.0)
        
        IncomingData.shared.readDataFromFile()
        
        vectorsObject = Vectors(device: device, commandQ: commandQueue, textureLoader: textureLoader, multiplier: multiplier)
        vectorsObject.scale = 1
        self.metalViewControllerDelegate = self

        //setupGestures()
    }
    
    override func scrollWheel(with event: NSEvent) {
        print(event)
    }

    override func mouseDragged(with event: NSEvent) {
        print(event)
    }
    override func rightMouseDragged(with event: NSEvent) {
        print(event)
    }


    //MARK: - MetalViewControllerDelegate
    func renderObjects(_ drawable:CAMetalDrawable) {
        
        vectorsObject.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(_ timeSinceLastUpdate: CFTimeInterval) {
        vectorsObject.updateWithDelta(timeSinceLastUpdate)
    }
    /*
    //MARK: - Gesture related
    // 1
    func setupGestures() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(MySceneViewController.pan(_:)))
        pan.maximumNumberOfTouches = 2
        self.view.addGestureRecognizer(pan)
        
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(pinch(pinchGesture:)))
        self.view.addGestureRecognizer(pinch)
    }
    
    // 2
    func pan(_ panGesture: UIPanGestureRecognizer) {
        if panGesture.state == .changed {
            let pointInView = panGesture.location(in: self.view)
            
            if panGesture.numberOfTouches == 1 {
                if (lastPanLocation == .zero) {
                    lastDoublePanLocation = .zero
                } else {
                    let xDelta = Float((lastPanLocation.x - pointInView.x)/self.view.bounds.width) * panSensivity
                    let yDelta = Float((lastPanLocation.y - pointInView.y)/self.view.bounds.height) * panSensivity
                    
                    vectorsObject.rotationY -= xDelta
                    vectorsObject.rotationZ -= yDelta
                }
                lastPanLocation = pointInView
                
            } else if panGesture.numberOfTouches == 2 {
                if (lastDoublePanLocation == .zero) {
                    lastPanLocation = .zero
                } else {
                    
                    let xDelta = Float((lastDoublePanLocation.x - pointInView.x)/self.view.bounds.width)
                    let yDelta = Float((lastDoublePanLocation.y - pointInView.y)/self.view.bounds.height)
                    
                    vectorsObject.positionZ -= xDelta
                    vectorsObject.positionY += yDelta
                }
                lastDoublePanLocation = pointInView
                
            }
        } else if panGesture.state == .began {
            if panGesture.numberOfTouches == 1 {
                lastPanLocation = panGesture.location(in: self.view)
            } else if panGesture.numberOfTouches == 2 {
                lastDoublePanLocation = panGesture.location(in: self.view)
            }
        } else if panGesture.state == .ended {
            lastPanLocation = .zero
            lastDoublePanLocation = .zero
        }
    }
    
    func pinch(pinchGesture: UIPinchGestureRecognizer){
        if pinchGesture.state == UIGestureRecognizerState.changed{
            vectorsObject.scale -= Float(lastScale - pinchGesture.scale) * vectorsObject.scale
            lastScale = pinchGesture.scale
        } else if pinchGesture.state == UIGestureRecognizerState.began{
            lastScale = pinchGesture.scale
        }
    }
    
    @IBAction func changeMultiplier(_ sender: UIButton) {
        multiplier = multiplier + (sender.tag == 1 ? -0.01 : 0.01)
        multiplier = multiplier <= 0 ? 0 : multiplier
        
        let old = vectorsObject!
        vectorsObject = Vectors(device: device, commandQ: commandQueue, textureLoader: textureLoader, multiplier: multiplier)
        vectorsObject.scale = old.scale
        vectorsObject.rotationX = old.rotationX
        vectorsObject.rotationY = old.rotationY
        vectorsObject.rotationZ = old.rotationZ
        vectorsObject.positionX = old.positionX
        vectorsObject.positionY = old.positionY
        vectorsObject.positionZ = old.positionZ
    }
*/
}
