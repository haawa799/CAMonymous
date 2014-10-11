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

struct Metadata{
  int numberOfRects;
};

struct Face{
  float x;
  float y;
  float width;
  float height;
  float rollAngle;
  float yawlAngle;
};

constant float blurSize = 1.0/256.0;

bool pointIsOnFace(float2 point, Face face);
float4 grayscaleFromColor(float4 color);
float distanceBetweenTwoPoints(float2 point1, float2 point2);

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
                               const device Metadata*  metadatas [[ buffer(0) ]],
                               const device Face*  faces [[ buffer(1) ]],
                               texture2d<float>  tex2D     [[ texture(0) ]],
                               sampler           sampler2D [[ sampler(0) ]])
{
  
  Metadata data = metadatas[0];
  
  if (data.numberOfRects > 0){
    
    for (int i = 0; i<data.numberOfRects; i++){
      Face face = faces[i];
      
      float q;
      
      if (face.height < 0.25){
        q = 266;
      }else if (face.height < 0.5){
        q = 130;
      }else{
        q = 90;
      }
      
      float blurSizeX = 1.0 / (q);
      float blurSizeY = 1.0 / (q);
      
      float2 pointInTexture = interpolated.textureCoordinate;
      
      if (pointIsOnFace(pointInTexture,face)){
        
        float4 sum = float4(0.0);
        
        
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 3.0*blurSizeX, pointInTexture.y - 3.0*blurSizeY)) * 1/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 2.0*blurSizeX, pointInTexture.y - 3.0*blurSizeY)) * 1/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 1.0*blurSizeX, pointInTexture.y - 3.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 0.0*blurSizeX, pointInTexture.y - 3.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 1.0*blurSizeX, pointInTexture.y - 3.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 2.0*blurSizeX, pointInTexture.y - 3.0*blurSizeY)) * 1/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 3.0*blurSizeX, pointInTexture.y - 3.0*blurSizeY)) * 1/170;
        
        
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 3.0*blurSizeX, pointInTexture.y - 2.0*blurSizeY)) * 1/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 2.0*blurSizeX, pointInTexture.y - 2.0*blurSizeY)) * 3/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 1.0*blurSizeX, pointInTexture.y - 2.0*blurSizeY)) * 4/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 0.0*blurSizeX, pointInTexture.y - 2.0*blurSizeY)) * 5/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 1.0*blurSizeX, pointInTexture.y - 2.0*blurSizeY)) * 4/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 2.0*blurSizeX, pointInTexture.y - 2.0*blurSizeY)) * 3/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 3.0*blurSizeX, pointInTexture.y - 2.0*blurSizeY)) * 1/170;
        
        
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 3.0*blurSizeX, pointInTexture.y - 1.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 2.0*blurSizeX, pointInTexture.y - 1.0*blurSizeY)) * 4/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 1.0*blurSizeX, pointInTexture.y - 1.0*blurSizeY)) * 7/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 0.0*blurSizeX, pointInTexture.y - 1.0*blurSizeY)) * 8/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 1.0*blurSizeX, pointInTexture.y - 1.0*blurSizeY)) * 7/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 2.0*blurSizeX, pointInTexture.y - 1.0*blurSizeY)) * 4/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 3.0*blurSizeX, pointInTexture.y - 1.0*blurSizeY)) * 2/170;
        
        
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 3.0*blurSizeX, pointInTexture.y + 0.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 2.0*blurSizeX, pointInTexture.y + 0.0*blurSizeY)) * 5/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 1.0*blurSizeX, pointInTexture.y + 0.0*blurSizeY)) * 8/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 0.0*blurSizeX, pointInTexture.y + 0.0*blurSizeY)) * 10/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 1.0*blurSizeX, pointInTexture.y + 0.0*blurSizeY)) * 8/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 2.0*blurSizeX, pointInTexture.y + 0.0*blurSizeY)) * 5/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 3.0*blurSizeX, pointInTexture.y + 0.0*blurSizeY)) * 2/170;
        
        
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 3.0*blurSizeX, pointInTexture.y + 1.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 2.0*blurSizeX, pointInTexture.y + 1.0*blurSizeY)) * 4/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 1.0*blurSizeX, pointInTexture.y + 1.0*blurSizeY)) * 7/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 0.0*blurSizeX, pointInTexture.y + 1.0*blurSizeY)) * 8/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 1.0*blurSizeX, pointInTexture.y + 1.0*blurSizeY)) * 7/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 2.0*blurSizeX, pointInTexture.y + 1.0*blurSizeY)) * 4/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 3.0*blurSizeX, pointInTexture.y + 1.0*blurSizeY)) * 2/170;
        
        
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 3.0*blurSizeX, pointInTexture.y + 2.0*blurSizeY)) * 1/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 2.0*blurSizeX, pointInTexture.y + 2.0*blurSizeY)) * 3/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 1.0*blurSizeX, pointInTexture.y + 2.0*blurSizeY)) * 4/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 0.0*blurSizeX, pointInTexture.y + 2.0*blurSizeY)) * 5/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 1.0*blurSizeX, pointInTexture.y + 2.0*blurSizeY)) * 4/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 2.0*blurSizeX, pointInTexture.y + 2.0*blurSizeY)) * 3/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 3.0*blurSizeX, pointInTexture.y + 2.0*blurSizeY)) * 1/170;
        
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 3.0*blurSizeX, pointInTexture.y + 3.0*blurSizeY)) * 1/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 2.0*blurSizeX, pointInTexture.y + 3.0*blurSizeY)) * 1/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x - 1.0*blurSizeX, pointInTexture.y + 3.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 0.0*blurSizeX, pointInTexture.y + 3.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 1.0*blurSizeX, pointInTexture.y + 3.0*blurSizeY)) * 2/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 2.0*blurSizeX, pointInTexture.y + 3.0*blurSizeY)) * 1/170;
        sum += tex2D.sample(sampler2D, float2(pointInTexture.x + 3.0*blurSizeX, pointInTexture.y + 3.0*blurSizeY)) * 1/170;
        
        return sum;//  sum1);//grayscaleFromColor(tex2D.sample(sampler2D, pointInTexture));
      }
    }
    
//    if (pointIsOnFace(interpolated.textureCoordinate,face)){
//      return grayscaleFromColor(tex2D.sample(sampler2D, interpolated.textureCoordinate));//return float4(1.0,0.0,0.0,1.0);
//    }
    
  }
  
  return tex2D.sample(sampler2D, interpolated.textureCoordinate);
}

bool pointIsOnFace(float2 point, Face face){
  
  if ((point[0] < 0.9*face.x) || (point[0] > face.x + 1.1*face.width)){
    return false;
  }
  if ((point[1] < 0.9*face.y) || (point[1] > face.y + 1.1*face.height)){
    return false;
  }
  
  return true;
}

constant float3 kRec709Luma = float3(0.2126, 0.7152, 0.0722);


float4 grayscaleFromColor(float4 color){
  float  gray     = dot(color.rgb, kRec709Luma);
  return float4(gray, gray, gray, 1.0);
}

float distanceBetweenTwoPoints(float2 point1, float2 point2){
  float a = point1[0]-point2[0];
  float b = point1[1]-point2[1];
  return sqrt(a*a + b*b);
}


kernel void grayscale(texture2d<float, access::read>  inTexture   [[ texture(0) ]],
                      texture2d<float, access::write> outTexture  [[ texture(1) ]],
                      uint2                           gid         [[ thread_position_in_grid ]])
{
  float4 inColor  = inTexture.read(gid);
  float  gray     = dot(inColor.rgb, kRec709Luma);
  float4 outColor = float4(gray, gray, gray, 1.0);
  
  if (inColor[3] < 0.6){
    outColor[3] = inColor[3];
  }
  
  outTexture.write(outColor, gid);
}


