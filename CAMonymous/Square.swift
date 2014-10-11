//
//  Square.swift
//  CAMonymous
//
//  Created by Andrew K. on 10/11/14.
//  Copyright (c) 2014 CAMonymous_team. All rights reserved.
//

import UIKit

class Square: Node {
  init(device: MTLDevice){
    
    let A = Vertex(x: -1.0, y:   1.0, z:   1.0, r:  1.0, g:  0.0, b:  0.0, a:  1.0, s: 1.0, t: 1.0)
    let B = Vertex(x: -1.0, y:  -1.0, z:   1.0, r:  0.0, g:  1.0, b:  0.0, a:  1.0, s: 1.0, t: 0.0)
    let C = Vertex(x:  1.0, y:  -1.0, z:   1.0, r:  0.0, g:  0.0, b:  1.0, a:  1.0, s: 0.0, t: 0.0)
    let D = Vertex(x:  1.0, y:   1.0, z:   1.0, r:  0.1, g:  0.6, b:  0.4, a:  1.0, s: 0.0, t: 1.0)
    
    
    var verticesArray:Array<Vertex> = [
      A,B,C ,A,C,D   //Front
    ]
    
    super.init(name: "Square", vertices: verticesArray, device: device)
    
  }
}
