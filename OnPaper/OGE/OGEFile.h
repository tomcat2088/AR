//
//  OGEFile.h
//  es2
//
//  Created by wangyang on 9/10/15.
//  Copyright (c) 2015 wangyang. All rights reserved.
//

#ifndef __es2__OGEFile__
#define __es2__OGEFile__

#include <string>

class OGEFile
{
public:
    static std::string contentOfFile(const char* filePath);
    static void contentOfFileInBytes(const char* filePath);
    static long sizeOfFile(const char* filePath);
};

#endif /* defined(__es2__OGEFile__) */
