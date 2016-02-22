//
//  ARDisplayView.h
//  OnPaper
//
//  Created by wangyang on 16/2/22.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import "ARView.h"
#import <AR/video.h>

@class ARCameraCapture;
@class ARMarkerDetector;
@interface ARDisplayView : ARView
@property (assign,nonatomic) ARGL_CONTEXT_SETTINGS_REF arglContextSettings;
- (id)initWithFrame:(CGRect)frame capture:(ARCameraCapture*)capture detector:(ARMarkerDetector*)detector;
- (void)update:(AR2VideoBufferT*)buffer;
@end
