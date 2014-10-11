//
//  ViewController.swift
//  CAMonymous
//
//  Created by Andrew K. on 10/11/14.
//  Copyright (c) 2014 CAMonymous_team. All rights reserved.
//

import UIKit
import Metal
import QuartzCore


class ViewController: UIViewController, CaptureManagerDelegate {
  
  var device: MTLDevice! = nil
  var metalLayer: CAMetalLayer! = nil
  var pipelineState: MTLRenderPipelineState! = nil
  var commandQueue: MTLCommandQueue! = nil
  var timer: CADisplayLink! = nil
  
  var lastFrameTimestamp: CFTimeInterval = 0.0
  var objectToDraw: Square!
  var projectionMatrix: Matrix4!
  
  var captureManager = CaptureManager.sharedManager()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    projectionMatrix = Matrix4()//.makePerspectiveViewAngle(Matrix4.degreesToRad(85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
    
    
    device = MTLCreateSystemDefaultDevice()
    
    captureManager.setupCaptureWithDevice(device)
    captureManager.delegate = self
    
    metalLayer = CAMetalLayer()
    metalLayer.device = device
    metalLayer.pixelFormat = .BGRA8Unorm
    metalLayer.framebufferOnly = false
    metalLayer.frame = view.layer.frame
    view.layer.addSublayer(metalLayer)
    
    objectToDraw = Square(device: device)
    var texture = METLTexture(resourceName: "dessert", ext: "png")
    texture.finalize(device, flip: false)
    objectToDraw.samplerState = self.generateSamplerStateForTexture(device)
    objectToDraw.texture = texture.texture

    
    let defaultLibrary = device.newDefaultLibrary()!
    let fragmentProgram = defaultLibrary.newFunctionWithName("basic_fragment")
    let vertexProgram = defaultLibrary.newFunctionWithName("basic_vertex")
    
    
    let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
    pipelineStateDescriptor.vertexFunction = vertexProgram
    pipelineStateDescriptor.fragmentFunction = fragmentProgram
    pipelineStateDescriptor.colorAttachments.objectAtIndexedSubscript(0).pixelFormat = .BGRA8Unorm
    
    
    var pipelineError : NSError?
    pipelineState = device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor, error: &pipelineError)
    if !(pipelineState != nil) {
      println("Failed to create pipeline state, error \(pipelineError)")
    }
    
    commandQueue = device.newCommandQueue()
    
    timer = CADisplayLink(target: self, selector: Selector("newFrame:"))
    timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
    
  }
  
  func render() {
    
    var drawable = metalLayer.nextDrawable()
    
    var worldModelMatrix = Matrix4()
    
    objectToDraw.render(commandQueue, pipelineState: pipelineState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: projectionMatrix ,clearColor: nil)
    
    drawable.texture
    
  }
  
  func gameloop(timeSinceLastUpdate: CFTimeInterval) {
    
    objectToDraw.updateWithDelta(timeSinceLastUpdate)
    
    autoreleasepool {
      self.render()
    }
  }
  
  func newFrame(displayLink: CADisplayLink){
    
    if lastFrameTimestamp == 0.0
    {
      lastFrameTimestamp = displayLink.timestamp
    }
    
    var elapsed:CFTimeInterval = displayLink.timestamp - lastFrameTimestamp
    lastFrameTimestamp = displayLink.timestamp
    
    gameloop(elapsed)
  }
  
  func generateSamplerStateForTexture(device: MTLDevice) -> MTLSamplerState?
  {
    var pSamplerDescriptor:MTLSamplerDescriptor? = MTLSamplerDescriptor();
    
    if let sampler = pSamplerDescriptor
    {
      sampler.minFilter             = MTLSamplerMinMagFilter.Nearest
      sampler.magFilter             = MTLSamplerMinMagFilter.Nearest
      sampler.mipFilter             = MTLSamplerMipFilter.NotMipmapped
      sampler.maxAnisotropy         = 1
      sampler.sAddressMode          = MTLSamplerAddressMode.ClampToEdge
      sampler.tAddressMode          = MTLSamplerAddressMode.ClampToEdge
      sampler.rAddressMode          = MTLSamplerAddressMode.ClampToEdge
      sampler.normalizedCoordinates = true
      sampler.lodMinClamp           = 0
      sampler.lodMaxClamp           = FLT_MAX
    }
    else
    {
      println(">> ERROR: Failed creating a sampler descriptor!")
    }
    
    return device.newSamplerStateWithDescriptor(pSamplerDescriptor!)
  }
  
  // MARK: - CaptureManagerDelegate
  
  func textureUpdated(texture: MTLTexture!) {
    objectToDraw.texture! = texture
  }
  
  func facesUpdated(buffer: MTLBuffer!, numberOfFaces: Int) {
    objectToDraw.numberOfFaces = numberOfFaces
    objectToDraw.facesBuffer = buffer
  }
  
}


