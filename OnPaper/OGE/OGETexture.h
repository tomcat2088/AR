//
//  OGETexture.h
//  es2
//
//  Created by wangyang on 15/9/11.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#ifndef __es2__OGETexture__
#define __es2__OGETexture__

#include "OGECommon.h"

class OGETexture
{
public:
    OGETexture();
    void init(const char* filePath);
    
    GLuint width;
    GLuint height;
    GLuint textureID;
};
#endif /* defined(__es2__OGETexture__) */
