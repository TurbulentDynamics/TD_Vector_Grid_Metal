//
//  BufferProvider.swift
//  HelloMetal
//
//  Created by Andrew  K. on 4/10/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

class BufferProvider: NSObject {
  // 1
  let inflightBuffersCount: Int
  // 2
  private var uniformsBuffers: [MTLBuffer]
  // 3
  private var avaliableBufferIndex: Int = 0
  var avaliableResourcesSemaphore:DispatchSemaphore
  
  init(device:MTLDevice, inflightBuffersCount: Int) {
    
    let sizeOfUniformsBuffer = MemoryLayout<Float>.size * (2 * Matrix4.numberOfElements()) + Light.size()
    
    avaliableResourcesSemaphore = DispatchSemaphore(value: inflightBuffersCount)
    
    self.inflightBuffersCount = inflightBuffersCount
    uniformsBuffers = [MTLBuffer]()
    
    for _ in 0...inflightBuffersCount-1{
      let uniformsBuffer = device.makeBuffer(length: sizeOfUniformsBuffer, options: [])
      uniformsBuffers.append(uniformsBuffer)
    }
  }
  
  deinit{
    for _ in 0...self.inflightBuffersCount{
      self.avaliableResourcesSemaphore.signal()
    }
  }
  
  func nextUniformsBuffer(projectionMatrix: Matrix4, modelViewMatrix: Matrix4, light: Light) -> MTLBuffer {
    
    // 1
    let buffer = uniformsBuffers[avaliableBufferIndex]
    
    // 2
    let bufferPointer = buffer.contents()
    
    // 3
    memcpy(bufferPointer, modelViewMatrix.raw(), MemoryLayout<Float>.size*Matrix4.numberOfElements())
    memcpy(bufferPointer + MemoryLayout<Float>.size*Matrix4.numberOfElements(), projectionMatrix.raw(), MemoryLayout<Float>.size*Matrix4.numberOfElements())
    memcpy(bufferPointer + 2*MemoryLayout<Float>.size*Matrix4.numberOfElements(), light.raw(), Light.size())
    
    // 4
    avaliableBufferIndex += 1
    if avaliableBufferIndex == inflightBuffersCount{
      avaliableBufferIndex = 0
    } 
    
    return buffer
  }
}
