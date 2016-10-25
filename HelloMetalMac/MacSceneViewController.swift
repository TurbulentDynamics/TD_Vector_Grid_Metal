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
    var lastLocation: CGPoint!
    
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
    }
    
    override func scrollWheel(with event: NSEvent) {
        print(event.deltaY)
        
        vectorsObject.scale -= Float(event.deltaY) * vectorsObject.scale
    }
    
    override func mouseDown(with event: NSEvent) {
        print(event.locationInWindow.x)
        lastLocation = event.locationInWindow
    }
    
    
    override func mouseDragged(with event: NSEvent) {
        //print(event.locationInWindow.x)
        
        let xDelta = Float((lastLocation.x - event.locationInWindow.x)/self.view.bounds.width) * panSensivity
        let yDelta = Float((lastLocation.y - event.locationInWindow.y)/self.view.bounds.height) * panSensivity
        
        print("xDelta: \(xDelta), yDelta: \(yDelta)")
        
        vectorsObject.rotationY -= xDelta
        vectorsObject.rotationZ -= yDelta
        
        lastLocation = event.locationInWindow
        
    }
    override func rightMouseDragged(with event: NSEvent) {
        //print(event.locationInWindow.x)
        
        
        let xDelta = Float((lastLocation.x - event.locationInWindow.x)/self.view.bounds.width)
        let yDelta = Float((lastLocation.y - event.locationInWindow.y)/self.view.bounds.height)
        
        print("xDelta: \(xDelta), yDelta: \(yDelta)")
        
        vectorsObject.rotationZ -= xDelta
        vectorsObject.rotationY += yDelta
        
        lastLocation = event.locationInWindow
    }
    


    //MARK: - MetalViewControllerDelegate
    func renderObjects(_ drawable:CAMetalDrawable) {
        
        vectorsObject.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(_ timeSinceLastUpdate: CFTimeInterval) {
        vectorsObject.updateWithDelta(timeSinceLastUpdate)
    }

    
    
}
