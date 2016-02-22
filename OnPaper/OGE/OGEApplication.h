//
//  OGEApplication.h
//  es2
//
//  Created by wangyang on 9/10/15.
//  Copyright (c) 2015 wangyang. All rights reserved.
//

#ifndef __es2__OGEApplication__
#define __es2__OGEApplication__

#include <string>

class OGEProgram;
class OGEOBJ;
class OGEApplication
{
    
private:
    OGEProgram* program;
    OGEOBJ* obj;
public:
    OGEApplication();
    ~OGEApplication();
    static OGEApplication* shared();
    
    void init();
    void draw(float timeInMilliseconds);
    void destroy();
};

#endif /* defined(__es2__OGEApplication__) */
