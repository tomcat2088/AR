//
//  ARMarkerDetector.h
//  OnPaper
//
//  Created by wangyang on 16/2/22.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AR/ar.h>
#import <AR/video.h>

@class ARCameraCapture;
@interface ARMarkerDetector : NSObject
@property (assign,nonatomic) ARHandle* gARHandle;
@property (assign,nonatomic) ARPattHandle* pattHandle;
@property (assign,nonatomic) float pattWidth;
- (id)initWithCameraCapture:(ARCameraCapture*)cameraCapture;
- (BOOL)detect:(AR2VideoBufferT *)buffer;
- (float*)modelViewTransform;
@end
