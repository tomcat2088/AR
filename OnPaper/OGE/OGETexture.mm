//
//  OGETexture.cpp
//  es2
//
//  Created by wangyang on 15/9/11.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#include "OGETexture.h"
#include "png.h"

#import <UIKit/UIKit.h>
OGETexture::OGETexture()
{

}
    
void OGETexture::init(const char* filePath)
{
    //FIXME:should be replace by pure c or c++ methods
    UIImage* image = [UIImage imageNamed:[NSString stringWithCString:filePath encoding:NSUTF8StringEncoding]];
    CGImageRef imageRef = [image CGImage];
    int width = CGImageGetWidth(imageRef);
    int height = CGImageGetHeight(imageRef);
    
    GLubyte* textureData = (GLubyte *)malloc(width * height * 4); // if 4 components per pixel (RGBA)
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSUInteger bytesPerPixel = 4;
    NSUInteger bytesPerRow = bytesPerPixel * width;
    NSUInteger bitsPerComponent = 8;
    CGContextRef context = CGBitmapContextCreate(textureData, width, height,
                                                 bitsPerComponent, bytesPerRow, colorSpace,
                                                 kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), imageRef);
    CGContextRelease(context);
    
    glGenTextures(1, &textureID);
    glBindTexture(GL_TEXTURE_2D, textureID);
   // glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT );
   // glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT );
				glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
			//	glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width,height, 0, GL_RGBA, GL_UNSIGNED_BYTE, textureData);
}