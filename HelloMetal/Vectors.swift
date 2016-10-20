import MetalKit

class Vectors: Node {
    
    init(device: MTLDevice, commandQ: MTLCommandQueue, textureLoader :MTKTextureLoader, multiplier: Float) {

        var verticesArray: Array<Vertex> = []
        
        if multiplier != 0 {
            
            for item in IncomingData.shared.multiply(multiplier: multiplier) {
                // add starting point
                verticesArray.append(Vertex(x: item[0], y: item[1], z: item[2], r: item[3], g: 0, b: 0, a: 0, s: 0, t: 0, nX: 0, nY: 0, nZ: 0))
                
                // add endpoint
                verticesArray.append(Vertex(x: item[12], y: item[1]+item[13], z: item[2]+item[14], r: item[3], g: 0, b: 0, a: 0, s: 0, t: 0, nX: 0, nY: 0, nZ: 0))
            }
        } else {
            verticesArray.append(Vertex(x: 0, y: 0, z: 0, r: 0, g: 0, b: 0, a: 0, s: 0, t: 0, nX: 0, nY: 0, nZ: 0))
        }

        let path = Bundle.main.path(forResource: "cube", ofType: "png")!
        let data = NSData(contentsOfFile: path) as! Data
        let texture = try! textureLoader.newTexture(with: data, options: [MTKTextureLoaderOptionSRGB : (false as NSNumber)])
        
        super.init(name: "Vectors", vertices: verticesArray, device: device, texture: texture)
    }
    
}
