//
//  OGEOBJ.h
//  es2
//
//  Created by wangyang on 15/9/10.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#ifndef __es2__OGEOBJ__
#define __es2__OGEOBJ__

#include "OGECommon.h"
#include "OGEMesh.h"

class OGEOBJ
{
    
public:
    ~OGEOBJ();
public:
    std::vector<OGEMesh> meshes;
    
    OGEOBJ(){}
    void parse(const char* objfile);
    template <class T>
    static std::vector<T> listToVector(std::list<T> list);
};

#endif /* defined(__es2__OGEOBJ__) */
