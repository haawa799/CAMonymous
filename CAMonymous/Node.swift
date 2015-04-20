//
//  Node.swift
//  CAMonymous
//
//  Created by Andrew K. on 10/11/14.
//  Copyright (c) 2014 CAMonymous_team. All rights reserved.
//

import UIKit
import Metal
import QuartzCore
import GLKit.GLKMath

class Node: NSObject {
  
  var time:CFTimeInterval = 0.0
  
  let name: String
  var vertexCount: Int
  
  var positionX:Float = 0.0
  var positionY:Float = 0.0
  var positionZ:Float = 0.0
  
  var rotationX:Float = 0.0
  var rotationY:Float = 0.0
  var rotationZ:Float = 0.0
  var scale:Float     = 1.0
  
  var vertexBuffer: MTLBuffer
  var uniformsBuffer: MTLBuffer?
  
  var texture: MTLTexture?
  var samplerState: MTLSamplerState?
  
  var numberOfFaces:Int = 0
  var metadataBuffer: MTLBuffer?
  var facesBuffer: MTLBuffer?
  
  var device: MTLDevice
  
  init(name: String,
    vertices: Array<Vertex>,
    device: MTLDevice){
      
      //Setup vertex buffer
      var vertexData = Array<Float>()
      for vertex in vertices
      {
        vertexData += vertex.floatBuffer()
      }
      
      let dataSize = vertexData.count * sizeofValue(vertexData[0])
      
      self.name = name
      self.device = device
      vertexCount = vertices.count
      vertexBuffer = device.newBufferWithBytes(vertexData, length: dataSize, options: nil)
      
      super.init()
  }
  
  func render(commandQueue: MTLCommandQueue, pipelineState: MTLRenderPipelineState, drawable: CAMetalDrawable, parentModelViewMatrix: Matrix4, projectionMatrix: Matrix4, clearColor: MTLClearColor?){
    
    let renderPassDescriptor = MTLRenderPassDescriptor()
    renderPassDescriptor.colorAttachments[0].texture = drawable.texture
    renderPassDescriptor.colorAttachments[0].loadAction = .Clear
    
    if let clearColor = clearColor{
      renderPassDescriptor.colorAttachments[0].clearColor = clearColor
    }
    else{
      renderPassDescriptor.colorAttachments[0].clearColor = MTLClearColor(red: 1.0, green: 1, blue: 1, alpha: 1.0)
    }
    
    renderPassDescriptor.colorAttachments[0].storeAction = .Store
    
    let commandBuffer = commandQueue.commandBuffer()
    commandBuffer.addCompletedHandler({
      (buffer:MTLCommandBuffer!) -> Void in
      
      
      CaptureManager.sharedManager().lastFrameDisplayed = drawable.texture;
      
    })
    
    let renderEncoder = commandBuffer.renderCommandEncoderWithDescriptor(renderPassDescriptor)!
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(self.vertexBuffer, offset: 0, atIndex: 0)
    
    if let texture = texture{
      renderEncoder.setFragmentTexture(self.texture, atIndex: 0)
    }
    
    if let samplerState = samplerState{
      renderEncoder.setFragmentSamplerState(samplerState, atIndex: 0)
    }
    
    //Metadata buffer
    var metaDataBuffer = device.newBufferWithBytes(&numberOfFaces, length: sizeofValue(numberOfFaces), options: MTLResourceOptions.OptionCPUCacheModeDefault)
    renderEncoder.setFragmentBuffer(metaDataBuffer, offset: 0, atIndex: 0)
    
    if let facesBuffer = facesBuffer{
      
    }else{
      facesBuffer = device.newBufferWithBytes(&numberOfFaces, length: 6*4, options: MTLResourceOptions.OptionCPUCacheModeDefault)
    }
    renderEncoder.setFragmentBuffer(facesBuffer, offset: 0, atIndex: 1)
    
    //For now cull mode is used instead of depth buffer
    renderEncoder.setCullMode(MTLCullMode.Front)
    
    //Setup uniform buffer
    var nodeModelMatrix: Matrix4 = self.modelMatrix()
    nodeModelMatrix.multiplyLeft(parentModelViewMatrix)
    
    uniformsBuffer = device.newBufferWithLength(sizeof(Float)*16*2, options: nil)
    var bufferPointer = uniformsBuffer?.contents()
    memcpy(bufferPointer!, nodeModelMatrix.raw(), sizeof(Float)*16)
    memcpy(bufferPointer! + sizeof(Float)*16, projectionMatrix.raw(), sizeof(Float)*16)
    renderEncoder.setVertexBuffer(self.uniformsBuffer, offset: 0, atIndex: 1)
    
    //Draw primitives
    renderEncoder.drawPrimitives(.Triangle, vertexStart: 0, vertexCount: self.vertexCount, instanceCount: self.vertexCount/3)
    renderEncoder.endEncoding()
    
    commandBuffer.presentDrawable(drawable)
    commandBuffer.commit()
  }
  
  
  func updateWithDelta(delta: CFTimeInterval){
    time += delta
    
  }
  
  func modelMatrix() -> Matrix4{
    var matrix = Matrix4()
    matrix.translate(positionX, y: positionY, z: positionZ)
    matrix.rotateAroundX(rotationX, y: rotationY, z: rotationZ)
    matrix.scale(scale, y: scale, z: scale)
    return matrix
  }
}
