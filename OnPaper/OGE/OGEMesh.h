//
//  OGEMesh.h
//  es2
//
//  Created by wangyang on 15/9/11.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#ifndef __es2__OGEMesh__
#define __es2__OGEMesh__

#include "OGECommon.h"
#include "OGEMaterial.h"

class OGEMesh
{
public:
    OGEMesh();
    ~OGEMesh();
    GLuint vao;
    GLuint diffuseTexture;
    long triangleCount;
    OGEMaterial material;
};

#endif /* defined(__es2__OGEMesh__) */
