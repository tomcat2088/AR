//
//  ARMarkerDetector.m
//  OnPaper
//
//  Created by wangyang on 16/2/22.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import "ARMarkerDetector.h"
#import "ARCameraCapture.h"

#import <AR/ar.h>
#import <AR/gsub_es2.h>


#define VIEW_SCALEFACTOR 1.0f

@interface ARMarkerDetector()
{
    // Marker detection.
    long            gCallCountMarkerDetect;
    
    // Transformation matrix retrieval.
    AR3DHandle     *gAR3DHandle;
    ARdouble        gPatt_trans[3][4];      // Per-marker, but we are using only 1 marker.
    int             gPatt_found;            // Per-marker, but we are using only 1 marker.
    int             gPatt_id;               // Per-marker, but we are using only 1 marker.
    BOOL            useContPoseEstimation;
    
    float modelView[16];
}
@end

@implementation ARMarkerDetector
@synthesize gARHandle;
@synthesize pattHandle;
@synthesize pattWidth;

- (id)initWithCameraCapture:(ARCameraCapture*)cameraCapture
{
    self = [super init];
    if (self) {
        SafeInit((gARHandle = arCreateHandle(cameraCapture.arParamLT)), [self initFailedFallBack]);
        SafeInit((arSetPixelFormat(gARHandle, cameraCapture.pixelFormat)), [self initFailedFallBack]);
        SafeInit((gAR3DHandle = ar3DCreateHandle(&cameraCapture.arParamLT->param)), [self initFailedFallBack]);
        
        arSetMarkerExtractionMode(gARHandle, AR_USE_TRACKING_HISTORY_V2);
      //  arSetLabelingMode(gARHandle, (AR_LABELING_WHITE_REGION));
        
        [self initMarkerPattern];
    }
    return self;
}

- (void)initMarkerPattern
{
    pattHandle = arPattCreateHandle();
    arPattAttach(gARHandle, pattHandle);
    
    // Load marker(s).
    // Loading only 1 pattern in this example.
    char *patt_name  = "Data/patt.hiro";
    gPatt_id = arPattLoad(pattHandle, patt_name);
    self.pattWidth = 40.0f;
    gPatt_found = FALSE;
}

- (void)initFailedFallBack
{
    
}

- (BOOL)detect:(AR2VideoBufferT *)buffer
{
    ARdouble err;
    int j, k;
    if (buffer) {
        if (arDetectMarker(gARHandle, buffer->buff) < 0)
            return NO;
        // Check through the marker_info array for highest confidence
        // visible marker matching our preferred pattern.
        k = -1;
        for (j = 0; j < gARHandle->marker_num; j++) {
            if (gARHandle->markerInfo[j].id == gPatt_id) {
                if (k == -1) k = j; // First marker detected.
                else if (gARHandle->markerInfo[j].cf > gARHandle->markerInfo[k].cf) k = j; // Higher confidence marker detected.
            }
        }
        
        if (k != -1) {
#ifdef DEBUG
            NSLog(@"marker %d matched pattern %d.\n", k, gPatt_id);
#endif
            // Get the transformation between the marker and the real camera into gPatt_trans.
            if (gPatt_found && useContPoseEstimation) {
                err = arGetTransMatSquareCont(gAR3DHandle, &(gARHandle->markerInfo[k]), gPatt_trans, pattWidth , gPatt_trans);
            } else {
                err = arGetTransMatSquare(gAR3DHandle, &(gARHandle->markerInfo[k]), pattWidth, gPatt_trans);
            }

#ifdef ARDOUBLE_IS_FLOAT
            arglCameraViewRHf(gPatt_trans, modelView, VIEW_SCALEFACTOR);
#else
            float patt_transf[3][4];
            int r, c;
            for (r = 0; r < 3; r++) {
                for (c = 0; c < 4; c++) {
                    patt_transf[r][c] = (float)(gPatt_trans[r][c]);
                }
            }
            arglCameraViewRHf(patt_transf, modelview, VIEW_SCALEFACTOR);
#endif
            gPatt_found = TRUE;
        } else {
            gPatt_found = FALSE;
        }
    }
    return gPatt_found;
}

- (float*)modelViewTransform
{
    return modelView;
}
@end
