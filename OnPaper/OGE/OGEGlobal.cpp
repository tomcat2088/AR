//
//  OGEGlobal.cpp
//  es2
//
//  Created by wangyang on 15/9/11.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#include "OGEGlobal.h"
std::string OGEGlobal::workspacePath = "";
std::string OGEGlobal::resourcePath = "";

std::string OGEGlobal::pathForResource(std::string subpath)
{
    if(*(subpath.data()) == '/')
        return OGEGlobal::resourcePath + subpath;
    else
        return OGEGlobal::resourcePath + "/"+ subpath;
}