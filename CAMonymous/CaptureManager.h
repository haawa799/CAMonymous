//
//  CaptureManager.h
//  CAMonymous
//
//  Created by Andrew K. on 10/11/14.
//  Copyright (c) 2014 CAMonymous_team. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MTLTexture;

@protocol CaptureManagerDelegate <NSObject>

- (void)textureUpdated:(id <MTLTexture>)texture;
- (void)facesUpdated:(id <MTLBuffer>)buffer numberOfFaces:(NSInteger)faces;

@end

@interface CaptureManager : NSObject

@property(nonatomic,weak) id <CaptureManagerDelegate> delegate;
@property(nonatomic,weak) id <MTLDevice> device;
@property(nonatomic,weak) id <MTLTexture> lastFrameDisplayed;

+ (CaptureManager *)sharedManager;

- (void)setupCaptureWithDevice:(id <MTLDevice>)device;

- (void)savePicture;

@end
