//
//  ARCameraCapture.m
//  OnPaper
//
//  Created by wangyang on 16/2/22.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import "ARCameraCapture.h"

@interface ARCameraCapture()
@property (strong,nonatomic) CameraVideo* cameraVideo;
@end

@implementation ARCameraCapture

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.videoParam = NULL;
    }
    return self;
}

static void videoOpenCallback(void *userData)
{
    ARCameraCapture *vc = (__bridge ARCameraCapture *)userData;
    [vc start];
}

- (void)start
{
    if(self.videoParam == NULL)
    {
        // Open the video path.
        char *vconf = ""; // See http://www.artoolworks.com/support/library/Configuring_video_capture_in_ARToolKit_Professional#AR_VIDEO_DEVICE_IPHONE
        if (!(self.videoParam = ar2VideoOpenAsync(vconf, videoOpenCallback, (__bridge void *)(self)))) {
            NSLog(@"Error: Unable to open connection to camera.\n");
            [self stop];
            return;
        }
    }
    else
    {
        [self config];
    }
}



- (void)config
{
    // Find the size of the camera input.
    int xsize, ysize;
    if (ar2VideoGetSize(self.videoParam, &xsize, &ysize) < 0) {
        NSLog(@"Error: ar2VideoGetSize.\n");
        [self stop];
        return;
    }
    
    // Get the format in which the camera is returning pixels.
    self.pixelFormat = ar2VideoGetPixelFormat(self.videoParam);
    if (self.pixelFormat == AR_PIXEL_FORMAT_INVALID) {
        NSLog(@"Error: Camera is using unsupported pixel format.\n");
        [self stop];
        return;
    }
    
    // Work out if the front camera is being used. If it is, flip the viewing frustum for
    // 3D drawing.
    self.flipV = FALSE;
    int frontCamera;
    if (ar2VideoGetParami(self.videoParam, AR_VIDEO_PARAM_IOS_CAMERA_POSITION, &frontCamera) >= 0) {
        if (frontCamera == AR_VIDEO_IOS_CAMERA_POSITION_FRONT) self.flipV = TRUE;
    }
    
    // Tell arVideo what the typical focal distance will be. Note that this does NOT
    // change the actual focus, but on devices with non-fixed focus, it lets arVideo
    // choose a better set of camera parameters.
    ar2VideoSetParami(self.videoParam, AR_VIDEO_PARAM_IOS_FOCUS, AR_VIDEO_IOS_FOCUS_0_3M); // Default is 0.3 metres. See <AR/sys/videoiPhone.h> for allowable values.
    
    // Load the camera parameters, resize for the window and init.
    ARParam cparam;
    if (ar2VideoGetCParam(self.videoParam, &cparam) < 0) {
        char cparam_name[] = "Data/camera_para.dat";
        NSLog(@"Unable to automatically determine camera parameters. Using default.\n");
        if (arParamLoad(cparam_name, 1, &cparam) < 0) {
            NSLog(@"Error: Unable to load parameter file %s for camera.\n", cparam_name);
            [self stop];
            return;
        }
    }
    if (cparam.xsize != xsize || cparam.ysize != ysize) {
#ifdef DEBUG
        fprintf(stdout, "*** Camera Parameter resized from %d, %d. ***\n", cparam.xsize, cparam.ysize);
#endif
        arParamChangeSize(&cparam, xsize, ysize, &cparam);
    }
#ifdef DEBUG
    fprintf(stdout, "*** Camera Parameter ***\n");
    arParamDisp(&cparam);
#endif
    if ((self.arParamLT = arParamLTCreate(&cparam, AR_PARAM_LT_DEFAULT_OFFSET)) == NULL) {
        NSLog(@"Error: arParamLTCreate.\n");
        [self stop];
        return;
    }
    
//    // AR init.
//    if ((gARHandle = arCreateHandle(gCparamLT)) == NULL) {
//        NSLog(@"Error: arCreateHandle.\n");
//        [self stop];
//        return;
//    }
//    if (arSetPixelFormat(gARHandle, pixFormat) < 0) {
//        NSLog(@"Error: arSetPixelFormat.\n");
//        [self stop];
//        return;
//    }
//    if ((gAR3DHandle = ar3DCreateHandle(&gCparamLT->param)) == NULL) {
//        NSLog(@"Error: ar3DCreateHandle.\n");
//        [self stop];
//        return;
//    }
//    
    // libARvideo on iPhone uses an underlying class called CameraVideo. Here, we
    // access the instance of this class to get/set some special types of information.
    self.cameraVideo = ar2VideoGetNativeVideoInstanceiPhone(self.videoParam->device.iPhone);
    if (!self.cameraVideo) {
        NSLog(@"Error: Unable to set up AR camera: missing CameraVideo instance.\n");
        [self stop];
        return;
    }
    
    // The camera will be started by -startRunLoop.
    [self.cameraVideo setTookPictureDelegate:self];
    [self.cameraVideo setTookPictureDelegateUserData:NULL];
    
    ar2VideoCapStart(self.videoParam);
    
    [self.delegate cameraCaptureIsReady];

//
//    // Other ARToolKit setup.
//    arSetMarkerExtractionMode(gARHandle, AR_USE_TRACKING_HISTORY_V2);
//    //arSetMarkerExtractionMode(gARHandle, AR_NOUSE_TRACKING_HISTORY);
//    //arSetLabelingThreshMode(gARHandle, AR_LABELING_THRESH_MODE_MANUAL); // Uncomment to use  manual thresholding.
//    
//    // Allocate the OpenGL view.
//    glView = [[[ARView alloc] initWithFrame:[[UIScreen mainScreen] bounds] pixelFormat:kEAGLColorFormatRGBA8 depthFormat:kEAGLDepth16 withStencil:NO preserveBackbuffer:NO] autorelease]; // Don't retain it, as it will be retained when added to self.view.
//    glView.arViewController = self;
//    [self.view addSubview:glView];
//    
//    // Create the OpenGL projection from the calibrated camera parameters.
//    // If flipV is set, flip.
//    GLfloat frustum[16];
//    arglCameraFrustumRHf(&gCparamLT->param, VIEW_DISTANCE_MIN, VIEW_DISTANCE_MAX, frustum);
//    [glView setCameraLens:frustum];
//    glView.contentFlipV = flipV;
//    
//    // Set up content positioning.
//    glView.contentScaleMode = ARViewContentScaleModeFill;
//    glView.contentAlignMode = ARViewContentAlignModeCenter;
//    glView.contentWidth = gARHandle->xsize;
//    glView.contentHeight = gARHandle->ysize;
//    BOOL isBackingTallerThanWide = (glView.surfaceSize.height > glView.surfaceSize.width);
//    if (glView.contentWidth > glView.contentHeight) glView.contentRotate90 = isBackingTallerThanWide;
//    else glView.contentRotate90 = !isBackingTallerThanWide;
//#ifdef DEBUG
//    NSLog(@"[ARViewController start] content %dx%d (wxh) will display in GL context %dx%d%s.\n", glView.contentWidth, glView.contentHeight, (int)glView.surfaceSize.width, (int)glView.surfaceSize.height, (glView.contentRotate90 ? " rotated" : ""));
//#endif
//    
//    // Setup ARGL to draw the background video.
//    arglContextSettings = arglSetupForCurrentContext(&gCparamLT->param, pixFormat);
//    
//    arglSetRotate90(arglContextSettings, (glView.contentWidth > glView.contentHeight ? isBackingTallerThanWide : !isBackingTallerThanWide));
//    if (flipV) arglSetFlipV(arglContextSettings, TRUE);
//    int width, height;
//    ar2VideoGetBufferSize(self.videoParam, &width, &height);
//    arglPixelBufferSizeSet(arglContextSettings, width, height);
//    
//    // Prepare ARToolKit to load patterns.
//    if (!(gARPattHandle = arPattCreateHandle())) {
//        NSLog(@"Error: arPattCreateHandle.\n");
//        [self stop];
//        return;
//    }
//    arPattAttach(gARHandle, gARPattHandle);
//    
//    // Load marker(s).
//    // Loading only 1 pattern in this example.
//    char *patt_name  = "Data/patt.hiro";
//    if ((gPatt_id = arPattLoad(gARPattHandle, patt_name)) < 0) {
//        NSLog(@"Error loading pattern file %s.\n", patt_name);
//        [self stop];
//        return;
//    }
//    gPatt_width = 40.0f;
//    gPatt_found = FALSE;
//    
//    // For FPS statistics.
//    arUtilTimerReset();
//    gCallCountMarkerDetect = 0;
//    
//    //Create our runloop timer
//    [self setRunLoopInterval:2]; // Target 30 fps on a 60 fps device.
//    [self startRunLoop];
}

- (void) cameraVideoTookPicture:(id)sender userData:(void *)data
{
    AR2VideoBufferT *buffer = ar2VideoGetImage(self.videoParam);
    if (buffer)
    {
        [self.delegate frameCaptured:buffer];
    }
}
@end
