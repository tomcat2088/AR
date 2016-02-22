//
//  OGEGlobal.h
//  es2
//
//  Created by wangyang on 15/9/11.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#ifndef __es2__OGEGlobal__
#define __es2__OGEGlobal__

#include <stdio.h>
#include <string>

class OGEGlobal
{
    
public:
    static std::string workspacePath;
    static std::string resourcePath;
    
    static std::string pathForResource(std::string subpath);
};
#endif /* defined(__es2__OGEGlobal__) */
