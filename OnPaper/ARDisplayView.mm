//
//  ARDisplayView.m
//  OnPaper
//
//  Created by wangyang on 16/2/22.
//  Copyright © 2016年 wangyang. All rights reserved.
//

#import "ARDisplayView.h"
#import "ARCameraCapture.h"
#import "ARMarkerDetector.h"

#import <AR/ar.h>
#import <AR/video.h>
#import <AR/gsub_es2.h>
#include <AR/gsub_mtx.h>
#import "OGEApplication.h"
#import "OGEGlobal.h"
#import "OGEOBJ.h"

#define VIEW_DISTANCE_MIN        5.0f          // Objects closer to the camera than this will not be displayed.
#define VIEW_DISTANCE_MAX        2000.0f        // Objects further away from the camera than this will not be displayed.

enum {
    UNIFORM_MODELVIEW_PROJECTION_MATRIX,
    UNIFORM_COUNT
};

enum {
    ATTRIBUTE_VERTEX,
    ATTRIBUTE_COLOUR,
    ATTRIBUTE_COUNT
};

@interface ARDisplayView()
{
    GLint uniforms[UNIFORM_COUNT];
    OGEOBJ* obj;
}
@property (weak,nonatomic) ARCameraCapture* cameraCapture;
@property (weak,nonatomic) ARMarkerDetector* markerDetector;
@end

@implementation ARDisplayView
@synthesize arglContextSettings;
- (id)initWithFrame:(CGRect)frame capture:(ARCameraCapture*)capture detector:(ARMarkerDetector*)detector
{
    self = [super initWithFrame:frame pixelFormat:kEAGLColorFormatRGBA8 depthFormat:kEAGLDepth16 withStencil:NO preserveBackbuffer:NO];
    if (self) {
        self.cameraCapture = capture;
        self.markerDetector = detector;
        GLfloat frustum[16];
        arglCameraFrustumRHf(&self.cameraCapture.arParamLT->param, VIEW_DISTANCE_MIN, VIEW_DISTANCE_MAX, frustum);
        [self setCameraLens:frustum];
        self.contentFlipV = self.cameraCapture.flipV;
        
        // Set up content positioning.
        self.contentScaleMode = ARViewContentScaleModeFill;
        self.contentAlignMode = ARViewContentAlignModeCenter;
        self.contentWidth = self.markerDetector.gARHandle->xsize;
        self.contentHeight = self.markerDetector.gARHandle->ysize;
        BOOL isBackingTallerThanWide = (self.surfaceSize.height > self.surfaceSize.width);
        if (self.contentWidth > self.contentHeight) self.contentRotate90 = isBackingTallerThanWide;
        else self.contentRotate90 = !isBackingTallerThanWide;
#ifdef DEBUG
        NSLog(@"[ARViewController start] content %dx%d (wxh) will display in GL context %dx%d%s.\n", self.contentWidth, self.contentHeight, (int)self.surfaceSize.width, (int)self.surfaceSize.height, (self.contentRotate90 ? " rotated" : ""));
#endif
        
        // Setup ARGL to draw the background video.
        arglContextSettings = arglSetupForCurrentContext(&self.cameraCapture.arParamLT->param, self.cameraCapture.pixelFormat);
        
        arglSetRotate90(arglContextSettings, (self.contentWidth > self.contentHeight ? isBackingTallerThanWide : !isBackingTallerThanWide));
        if (self.cameraCapture.flipV) arglSetFlipV(arglContextSettings, TRUE);
        int width, height;
        ar2VideoGetBufferSize(self.cameraCapture.videoParam, &width, &height);
        arglPixelBufferSizeSet(arglContextSettings, width, height);
        
        
        std::string cubePath = OGEGlobal::pathForResource("cube2.obj");
        obj = new OGEOBJ();
        obj->parse(cubePath.data());
    }
    return self;
}

- (void)update:(AR2VideoBufferT *)buffer
{
    // Upload the frame to OpenGL.
    if (buffer->bufPlaneCount == 2) arglPixelBufferDataUploadBiPlanar(arglContextSettings, buffer->bufPlanes[0], buffer->bufPlanes[1]);
    else arglPixelBufferDataUpload(arglContextSettings, buffer->buff);
    
    BOOL isDetectedAnything = [self.markerDetector detect:buffer];
    if(isDetectedAnything)
    {
        float* modelViewTrans = [self.markerDetector modelViewTransform];
        [self setCameraPose:modelViewTrans];
    }
    else
    {
        [self setCameraPose:NULL];
    }
    
    [self drawView:arglContextSettings];
}

- (void) drawGeometry:(float *)viewProjectionMatrix
{
    for(int i=0;i<obj->meshes.size();i++)
    {
        glBindVertexArrayOES(obj->meshes[i].vao);
        //        if(obj->meshes[i].material.diffuseTexture.textureID)
        //        {
        //            glActiveTexture(GL_TEXTURE0);
        //            glBindTexture(GL_TEXTURE_2D, obj->meshes[i].material.diffuseTexture.textureID);
        //        }
        glDrawElements(GL_TRIANGLES, obj->meshes[i].triangleCount * 3, GL_UNSIGNED_INT, NULL);
        //    glDrawArrays(GL_TRIANGLES, 0, obj->meshes[i].triangleCount * 3);
    }

    return;
//    float viewProjectionMatrix[16];
//    mtxLoadIdentityf(viewProjectionMatrix);
//    mtxScalef(viewProjectionMatrix, 1/25.0f, 1/25.0f, 1/25.0f);
    // Colour cube data.
    int i;
    const GLfloat cube_vertices [8][3] = {
        /* +z */ {0.5f, 0.5f, 0.5f}, {0.5f, -0.5f, 0.5f}, {-0.5f, -0.5f, 0.5f}, {-0.5f, 0.5f, 0.5f},
        /* -z */ {0.5f, 0.5f, -0.5f}, {0.5f, -0.5f, -0.5f}, {-0.5f, -0.5f, -0.5f}, {-0.5f, 0.5f, -0.5f} };
    const GLubyte cube_vertex_colors [8][4] = {
        {255, 255, 255, 255}, {255, 255, 0, 255}, {0, 255, 0, 255}, {0, 255, 255, 255},
        {255, 0, 255, 255}, {255, 0, 0, 255}, {0, 0, 0, 255}, {0, 0, 255, 255} };
    const GLubyte cube_vertex_colors_black [8][4] = {
        {0, 0, 0, 255}, {0, 0, 0, 255}, {0, 0, 0, 255}, {0, 0, 0, 255},
        {0, 0, 0, 255}, {0, 0, 0, 255}, {0, 0, 0, 255}, {0, 0, 0, 255} };
    const GLushort cube_faces [6][4] = { /* ccw-winding */
        /* +z */ {3, 2, 1, 0}, /* -y */ {2, 3, 7, 6}, /* +y */ {0, 1, 5, 4},
        /* -x */ {3, 0, 4, 7}, /* +x */ {1, 2, 6, 5}, /* -z */ {4, 5, 6, 7} };
    float modelViewProjection[16];
    
    mtxLoadMatrixf(modelViewProjection, viewProjectionMatrix);
    mtxRotatef(modelViewProjection, 20, 0.0f, 0.0f, 1.0f); // Rotate about z axis.
    mtxScalef(modelViewProjection, 20.0f, 20.0f, 20.0f);
    mtxTranslatef(modelViewProjection, 0.0f, 0.0f, 0.5f); // Place base of cube on marker surface.
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEW_PROJECTION_MATRIX], 1, GL_FALSE, modelViewProjection);
    
    glVertexAttribPointer(ATTRIBUTE_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, cube_vertices);
    glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
    glVertexAttribPointer(ATTRIBUTE_COLOUR, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, cube_vertex_colors);
    glEnableVertexAttribArray(ATTRIBUTE_COLOUR);
    
    for (i = 0; i < 6; i++) {
        glDrawElements(GL_TRIANGLE_FAN, 4, GL_UNSIGNED_SHORT, &(cube_faces[i][0]));
    }
    glVertexAttribPointer(ATTRIBUTE_COLOUR, 4, GL_UNSIGNED_BYTE, GL_TRUE, 0, cube_vertex_colors_black);
    glEnableVertexAttribArray(ATTRIBUTE_COLOUR);
    for (i = 0; i < 6; i++) {
        glDrawElements(GL_LINE_LOOP, 4, GL_UNSIGNED_SHORT, &(cube_faces[i][0]));
    }
}

@end
