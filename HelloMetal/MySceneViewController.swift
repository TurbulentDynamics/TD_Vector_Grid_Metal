/**
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import simd

class MySceneViewController: MetalViewController, MetalViewControllerDelegate {
    
    var worldModelMatrix:float4x4!
    var objectToDraw: Vectors!
    //var objectToDraw: Cube!
    
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    let panDoubleSensivity:Float = 5.0
    var lastDoublePanLocation: CGPoint!
    var lastScale: CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worldModelMatrix = float4x4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -1)
        worldModelMatrix.rotateAroundX(0, y: float4x4.degrees(toRad: 90), z: 0.0)
        
        //objectToDraw = Cube(device: device, commandQ: commandQueue, textureLoader: textureLoader)
        objectToDraw = Vectors(device: device, commandQ: commandQueue, textureLoader: textureLoader)
        self.metalViewControllerDelegate = self
        
        setupGestures()
    }
    
    //MARK: - MetalViewControllerDelegate
    func renderObjects(_ drawable:CAMetalDrawable) {
        
        objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(_ timeSinceLastUpdate: CFTimeInterval) {
        objectToDraw.updateWithDelta(timeSinceLastUpdate)
    }
    
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
                    
                    objectToDraw.rotationY -= xDelta
                    objectToDraw.rotationZ -= yDelta
                }
                lastPanLocation = pointInView
                
            } else if panGesture.numberOfTouches == 2 {
                if (lastDoublePanLocation == .zero) {
                    lastPanLocation = .zero
                } else {
                    
                    let xDelta = Float((lastDoublePanLocation.x - pointInView.x)/self.view.bounds.width)
                    let yDelta = Float((lastDoublePanLocation.y - pointInView.y)/self.view.bounds.height)
                    
                    objectToDraw.positionZ -= xDelta
                    objectToDraw.positionY += yDelta
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
            objectToDraw.scale -= Float(lastScale - pinchGesture.scale) * objectToDraw.scale
            lastScale = pinchGesture.scale
        } else if pinchGesture.state == UIGestureRecognizerState.began{
            lastScale = pinchGesture.scale
        }
    }
    
}
