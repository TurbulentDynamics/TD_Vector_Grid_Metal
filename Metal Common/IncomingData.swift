import Foundation

class IncomingData: NSObject {
    
    static let shared = IncomingData()
    var verticesArray: [[Float]] = []
    
    func readDataFromFile(contents: String) {
        var nx = 0

        let arrayOfLines = contents.components(separatedBy: "\n")
        self.verticesArray = []
        
        var j = 0
        var percentDone = 0
        var lowerColor:Float = FLT_MAX
        var upperColor:Float = 0
        print(Date())
        
        for item in arrayOfLines {
            let points = item.components(separatedBy:" ").filter{$0 != ""}
            if points.count == 4, let brightness = Float(points[0]), let x = Float(points[1]), let y = Float(points[2]), let z = Float(points[3]) {
                
                lowerColor = min(lowerColor, brightness)
                upperColor = max(upperColor, brightness)
                
                let k = Float(0.005)
                
                let startY = k*Float(Int(j/nx) - nx/2 )
                let startZ = k*Float(Int(j%nx) - nx/2 )
                j += 1
                
                // add starting point
                let startPoint = [0, startY, startZ, brightness, 0, 0, 0, 0, 0, 0, 0, 0]
                
                // add endpoint
                let end = [x, y, z, 0, 0, 0, 0, 0, 0, 0, 0, 0]
                
                self.verticesArray += [startPoint + end]

                let p = Int(100 * j/arrayOfLines.count)
                if percentDone < p {
                    percentDone = p + 9
                    print("\(percentDone)%")
                }
            } else if points.count == 2 && points[0] == points[1] {
                nx = Int(points[0])!
            }
        }
        print(Date())
        self.verticesArray = self.verticesArray.map{ points -> [Float] in
            var item = points
            item[3] = (item[3] - lowerColor) / (upperColor-lowerColor)
            return item
        }
    }
    
    func multiply(multiplier: Float) -> [[Float]] {
        let newVerticesArray = verticesArray.map{ points -> [Float] in
            var item = points
            item[12] = multiplier * item[12]
            item[13] = multiplier * item[13]
            item[14] = multiplier * item[14]
            return item
        }

        return newVerticesArray
    }
    
}

