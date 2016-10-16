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
import MetalKit

class Vectors: Node {
    
    init(device: MTLDevice, commandQ: MTLCommandQueue, textureLoader :MTKTextureLoader) {
        
        
        let nx = 600
        //let filename = "inputVectors"
        //let filename = "flowyz_nx_01536_0012000_vect"
        let filename = "flowyz_nx_00600_0004000_vect"
        
        
        let filepath = Bundle.main.path(forResource: filename, ofType: "vvt")!
        
        let contents = try! String(contentsOfFile: filepath)
        let arrayOfLines = contents.components(separatedBy: "\n")
        
        var verticesArray:Array<Vertex> = Array<Vertex>()
        var j = 0
        for item in arrayOfLines {
            let points = item.components(separatedBy: " ").filter{$0 != ""}
            //print(Float(points[0]))
            //print(Float(points[1]))
            //print(Float(points[2]))
            //print(Float(points[3]))
            if points.count == 4, let _ = Float(points[0]), let p1 = Float(points[1]), let p2 = Float(points[2]), let p3 = Float(points[3]) {

                let k = Float(0.005)
                
                let startY = k*Float(Int(j/nx) - nx/2 )
                let startZ = k*Float(Int(j%nx) - nx/2 )

                // add starting point
                verticesArray.append(Vertex(x: 0, y: startY, z: startZ, r: 0, g: 0, b: 0, a: 0, s: 0, t: 0, nX: 0, nY: 0, nZ: 0))
                
                let multiplier = Float(0.05)
                // add endpoint
                verticesArray.append(Vertex(x: multiplier*p1, y: startY+multiplier*p2, z: startZ+multiplier*p3, r: 0, g: 0, b: 0, a: 0, s: 0, t: 0, nX: 0, nY: 0, nZ: 0))
                j+=1
            }
        }
        //print(verticesArray)
        //print(verticesArray.count)
        
        //3
        let path = Bundle.main.path(forResource: "cube", ofType: "png")!
        let data = NSData(contentsOfFile: path) as! Data
        let texture = try! textureLoader.newTexture(with: data, options: [MTKTextureLoaderOptionSRGB : (false as NSNumber)])
        
        super.init(name: "Vectors", vertices: verticesArray, device: device, texture: texture)
    }
    
}
