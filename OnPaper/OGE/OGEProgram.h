//
//  OGEProgram.h
//  es2
//
//  Created by wangyang on 15/9/9.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#include "OGECommon.h"

typedef enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_PROJECTION_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_DIFFUSE,
    NUM_UNIFORM
}UNIFORMS;
//
//typedef void(OGEProgramSetUniformsCallBack)(const char* uniformName);

class OGEProgram
{
public:
    GLuint pid;
    GLuint vertexShader;
    GLuint fragmentShader;
    GLint uniforms[NUM_UNIFORM];
    
    OGEProgram();
    ~OGEProgram();
    void initWithPath(const char* vertexShaderPath,const char* fragmentShaderPath);
    void initWithString(const char* vertexShaderString,const char* fragmentShaderString);

private:
    GLboolean compileShader(GLuint *shader,GLenum type ,const char *shaderStr);
    GLboolean linkProgram(GLuint prog);
    GLboolean validateProgram(GLuint prog);
};