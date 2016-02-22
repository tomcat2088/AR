//
//  ARCameraCapture.h
//  OnPaper
//
//  Created by wangyang on 16/2/22.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AR/video.h>
#import <AR/sys/CameraVideo.h>

@protocol ARCameraCaptureDelegate <NSObject>
- (void)cameraCaptureIsReady;
- (void)frameCaptured:(AR2VideoBufferT*)frameBuffer;
@end

@interface ARCameraCapture : NSObject
{

    AR_PIXEL_FORMAT pixelFormat;
}
@property (weak,nonatomic) id<ARCameraCaptureDelegate> delegate;
@property (assign,nonatomic) AR_PIXEL_FORMAT pixelFormat;
@property (assign,nonatomic) BOOL flipV;
@property (assign,nonatomic) ARParamLT* arParamLT;
@property (assign,nonatomic) AR2VideoParamT *videoParam;
- (void)start;
- (void)pause;
- (void)stop;
@end
