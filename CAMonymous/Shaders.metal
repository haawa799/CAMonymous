//
//  Shaders.metal
//  CAMonymous
//
//  Created by Andrew K. on 10/11/14.
//  Copyright (c) 2014 CAMonymous_team. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn{
  packed_float3 position;
  packed_float4 color;
  packed_float2 textureCoordinate;
};

struct VertexOut{
  float4 position [[position]];
  float4 color;
  float2 textureCoordinate;
};

struct Uniforms{
  float4x4 modelMatrix;
  float4x4 projectionMatrix;
};

vertex VertexOut basic_vertex(
                              const device VertexIn*  vertex_array [[ buffer(0) ]],
                              const device Uniforms&  uniforms     [[ buffer(1) ]],
                              unsigned int vid [[ vertex_id ]]) {
  
  float4x4 mv_Matrix = uniforms.modelMatrix;
  float4x4 proj_Matrix = uniforms.projectionMatrix;
  
  float4 fragmentPos4 = mv_Matrix * float4(vertex_array[vid].position, 1.0);
  
  VertexOut out;
  out.position = proj_Matrix * fragmentPos4;
  out.color = vertex_array[vid].color;
  out.textureCoordinate = vertex_array[vid].textureCoordinate;
  
  return out;
}

fragment float4 basic_fragment(VertexOut interpolated [[stage_in]],
                               texture2d<float>  tex2D     [[ texture(0) ]],
                               sampler           sampler2D [[ sampler(0) ]])
{
  return tex2D.sample(sampler2D, interpolated.textureCoordinate);
}

