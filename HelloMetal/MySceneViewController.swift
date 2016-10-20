import UIKit
import simd

class MySceneViewController: MetalViewController, MetalViewControllerDelegate {
    
    @IBOutlet weak var multiplierLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var readingLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var minusButton: UIButton!

    
    var worldModelMatrix:float4x4!
    var vectorsObject: Vectors!
    
    
    let panSensivity:Float = 5.0
    var lastPanLocation: CGPoint!
    var lastDoublePanLocation: CGPoint!
    var lastScale: CGFloat!
    
    var previousMultiplier: Float!
    var multiplier: Float! {
        didSet {
            multiplierLabel.text = String(format: "multiplier = %.2f", multiplier)
        }
    }
    var timer: Timer! {
        willSet {
            if timer != nil { timer.invalidate() }
        }
    }
    var canStartTimer: Bool! = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        worldModelMatrix = float4x4()
        worldModelMatrix.translate(0.0, y: 0.0, z: -1)
        worldModelMatrix.rotateAroundX(0, y: float4x4.degrees(toRad: 90), z: 0.0)
        
        multiplier = 0.05
        vectorsObject = Vectors(device: device, commandQ: commandQueue, textureLoader: textureLoader, multiplier: 0)
        
        self.metalViewControllerDelegate = self
        setupGestures()
        //self.progressView.progress = 0
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            IncomingData.shared.readDataFromFile(vc: self)
            self.readingLabel.text = "Applying multiplier..."
            self.setNewMultiplier()
        }
    }
    
    //MARK: - MetalViewControllerDelegate
    func renderObjects(_ drawable:CAMetalDrawable) {
        
        vectorsObject.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix, clearColor: nil)
    }
    
    func updateLogic(_ timeSinceLastUpdate: CFTimeInterval) {
        vectorsObject.updateWithDelta(timeSinceLastUpdate)
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
        stopTimer()
        
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
    
    @IBAction func buttonUp(_ sender: UIButton) {
        stopTimer()
    }
    
    @IBAction func buttonTouchDown(_ sender: AnyObject) {
        changeMultiplier(sender: sender.tag as NSNumber)
        canStartTimer = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            if self.canStartTimer == true {
                self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.fireTimer(timer:)), userInfo: ["sender": sender.tag], repeats: true);
            }
        }
    }
    
    func fireTimer(timer:Timer!) {
        let info = timer.userInfo as! [String : NSNumber]
        let sender = info["sender"]
        changeMultiplier(sender: sender!)
    }
    
    func stopTimer() {
        canStartTimer = false
        timer = nil
        setNewMultiplier()
    }
    
    func changeMultiplier(sender:NSNumber) {
        multiplier = multiplier + (sender == 1 ? -0.01 : 0.01)
        multiplier = multiplier <= 0 ? 0 : multiplier
    }
    
    func setNewMultiplier() {
        if previousMultiplier != multiplier {
            self.activityIndicator.startAnimating()
            self.activityIndicator.isHidden = false
            self.readingLabel.isHidden = false
            self.plusButton.isEnabled = false
            self.minusButton.isEnabled = false

            
            DispatchQueue.global().async {
                self.previousMultiplier = self.multiplier
                let old = self.vectorsObject!
                self.vectorsObject = Vectors(device: self.device, commandQ: self.commandQueue, textureLoader: self.textureLoader, multiplier: self.multiplier)
                if old.vertexCount != 1 {
                    self.vectorsObject.scale = old.scale
                    self.vectorsObject.rotationX = old.rotationX
                    self.vectorsObject.rotationY = old.rotationY
                    self.vectorsObject.rotationZ = old.rotationZ
                    self.vectorsObject.positionX = old.positionX
                    self.vectorsObject.positionY = old.positionY
                    self.vectorsObject.positionZ = old.positionZ
                } else {
                    self.vectorsObject.scale = 1
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.readingLabel.isHidden = true
                    self.plusButton.isEnabled = true
                    self.minusButton.isEnabled = true
                }
            }
        }
    }
}
