//
//  OGEFile.cpp
//  es2
//
//  Created by wangyang on 9/10/15.
//  Copyright (c) 2015 wangyang. All rights reserved.
//

#include "OGEFile.h"
#include <stdlib.h>

std::string OGEFile::contentOfFile(const char* filePath)
{
    FILE* file = fopen(filePath, (char*)"r");
    if(file)
    {
        fseek(file, 0, SEEK_END);
        long size = ftell(file);
        fseek(file, 0, SEEK_SET);
        char* buffer = (char*)malloc(size + 1);
        fread(buffer, sizeof(char), size, file);
        fclose(file);

        *(buffer+size) = '\0';
        std::string fileContent(buffer);
        free(buffer);
        return fileContent;
    }
    return "";
}