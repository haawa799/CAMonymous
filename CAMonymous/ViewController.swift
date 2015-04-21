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
    var metalLayer: CAMetalLayer? = nil
    var pipelineState: MTLRenderPipelineState? = nil
    var commandQueue: MTLCommandQueue? = nil
    var timer: CADisplayLink! = nil
    
    var lastFrameTimestamp: CFTimeInterval = 0.0
    var objectToDraw: Square?
    var projectionMatrix: Matrix4?
    
    var captureManager = CaptureManager.sharedManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.device = MTLCreateSystemDefaultDevice()
        
        self.metalLayer = CAMetalLayer()
        self.metalLayer?.device = self.device
        self.metalLayer?.pixelFormat = .BGRA8Unorm
        self.metalLayer?.framebufferOnly = false
        self.metalLayer?.frame = self.view.layer.frame
        self.view.layer.addSublayer(self.metalLayer)
        
        self.timer = CADisplayLink(target: self, selector: Selector("newFrame:"))
        self.timer.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        let q = dispatch_queue_create("QQ", nil)
        dispatch_async(q, { () -> Void in
            self.projectionMatrix = Matrix4()//.makePerspectiveViewAngle(Matrix4.degreesToRad(85.0), aspectRatio: Float(self.view.bounds.size.width / self.view.bounds.size.height), nearZ: 0.01, farZ: 100.0)
            
            self.captureManager.setupCaptureWithDevice(self.device)
            self.captureManager.delegate = self
            
            self.objectToDraw = Square(device: self.device)
            var texture = METLTexture(resourceName: "dessert", ext: "png")
            texture.finalize(self.device, flip: false)
            self.objectToDraw?.samplerState = self.generateSamplerStateForTexture(self.device)
            self.objectToDraw?.texture = texture.texture
            
            
            let defaultLibrary = self.device.newDefaultLibrary()!
            let fragmentProgram = defaultLibrary.newFunctionWithName("basic_fragment")
            let vertexProgram = defaultLibrary.newFunctionWithName("basic_vertex")
            
            
            let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
            pipelineStateDescriptor.vertexFunction = vertexProgram
            pipelineStateDescriptor.fragmentFunction = fragmentProgram
            pipelineStateDescriptor.colorAttachments[0].pixelFormat = .BGRA8Unorm
            
            
            var pipelineError : NSError?
            self.pipelineState = self.device.newRenderPipelineStateWithDescriptor(pipelineStateDescriptor, error: &pipelineError)
            if !(self.pipelineState != nil) {
                println("Failed to create pipeline state, error \(pipelineError)")
            }
            
            self.commandQueue = self.device.newCommandQueue()
            
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let window = view.window {
            let scale = window.screen.nativeScale
            let layerSize = view.bounds.size
            //2
            view.contentScaleFactor = scale
            metalLayer?.frame = CGRectMake(0, 0, layerSize.width, layerSize.height)
            metalLayer?.drawableSize = CGSizeMake(layerSize.width * scale, layerSize.height * scale)
        }
    }
    
    
    func render() {
        
        if let drawable = metalLayer?.nextDrawable(), q = commandQueue, pState = pipelineState, m = projectionMatrix{
            var worldModelMatrix = Matrix4()
            
            
            objectToDraw?.render(q, pipelineState: pState, drawable: drawable, parentModelViewMatrix: worldModelMatrix, projectionMatrix: m ,clearColor: nil)
            drawable.texture
        }
    }
    
    func gameloop(timeSinceLastUpdate: CFTimeInterval) {
        
        objectToDraw?.updateWithDelta(timeSinceLastUpdate)
        
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
        objectToDraw?.texture = texture
    }
    
    func facesUpdated(buffer: MTLBuffer!, numberOfFaces: Int) {
        objectToDraw?.numberOfFaces = numberOfFaces
        objectToDraw?.facesBuffer = buffer
    }
    
}


