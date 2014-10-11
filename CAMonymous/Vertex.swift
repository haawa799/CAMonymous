//
//  Vertex.swift
//  CAMonymous
//
//  Created by Andrew K. on 10/11/14.
//  Copyright (c) 2014 CAMonymous_team. All rights reserved.
//

struct Vertex{
  
  var x,y,z: Float
  var r,g,b,a: Float
  var s,t: Float
  
  func floatBuffer() -> [Float]{
    return [x,y,z,r,g,b,a,s,t]
  }
  
};
