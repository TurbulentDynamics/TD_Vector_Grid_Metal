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
        
        let filepath = Bundle.main.path(forResource: "inputVectors", ofType: "vvt")!
        let contents = try! String(contentsOfFile: filepath)
        let arrayOfLines = contents.components(separatedBy: "\n")
        
        var verticesArray:Array<Vertex> = Array<Vertex>()
        for i in 3...arrayOfLines.count-1 {
            let points = arrayOfLines[i].components(separatedBy: " ").filter{$0 != ""}
            //print(Float(points[0]))
            //print(Float(points[1]))
            //print(Float(points[2]))
            //print(Float(points[3]))
            if points.count == 4, let p0 = Float(points[0]), let p1 = Float(points[1]), let p2 = Float(points[2]), let p3 = Float(points[3]) {
                verticesArray.append(Vertex(x: p0*p1, y: p0*p2, z: p0*p3, r: 0, g: 0, b: 0, a: 0, s: 0, t: 0, nX: 0, nY: 0, nZ: 0))
            }
        }
        print(verticesArray)
        print(verticesArray.count)
        
        //3
        let path = Bundle.main.path(forResource: "cube", ofType: "png")!
        let data = NSData(contentsOfFile: path) as! Data
        let texture = try! textureLoader.newTexture(with: data, options: [MTKTextureLoaderOptionSRGB : (false as NSNumber)])
        
        super.init(name: "Vectors", vertices: verticesArray, device: device, texture: texture)
    }
    
}
