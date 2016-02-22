//
//  OGEProgram.m
//  es2
//
//  Created by wangyang on 15/9/9.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#import "OGEProgram.h"
#include "OGEFile.h"
#include <stdlib.h>
#include "OGEDefines.h"

OGEProgram::OGEProgram()
{
    
}

OGEProgram::~OGEProgram()
{
    if (vertexShader) {
        glDeleteShader(vertexShader);
        vertexShader = 0;
    }
    if (fragmentShader) {
        glDeleteShader(fragmentShader);
        fragmentShader = 0;
    }
    if (pid) {
        glDeleteProgram(pid);
        pid = 0;
    }
}

void OGEProgram::initWithPath(const char *vertexShaderPath, const char *fragmentShaderPath)
{
    std::string vertextShaderContent = OGEFile::contentOfFile(vertexShaderPath);
    std::string fragmentShaderContent = OGEFile::contentOfFile(fragmentShaderPath);
    initWithString(vertextShaderContent.data(), fragmentShaderContent.data());
}


void OGEProgram::initWithString(const char *vertexShaderString, const char *fragmentShaderString)
{
    pid = glCreateProgram();
    
    if (!compileShader(&vertexShader,GL_VERTEX_SHADER,vertexShaderString)) {
        printf("Failed to compile vertex shader");
        return;
    }
    
    if (!compileShader(&fragmentShader,GL_FRAGMENT_SHADER,fragmentShaderString)) {
        printf("Failed to compile fragment shader");
        return;
    }
    
    glAttachShader(pid, vertexShader);
    glAttachShader(pid, fragmentShader);
    
    glBindAttribLocation(pid, OGEGLAttributePosition, kOGEGLAttributePosition);
    glBindAttribLocation(pid, OGEGLAttributeNormal, kOGEGLAttributeNormal);
    glBindAttribLocation(pid, OGEGLAttributeColor, kOGEGLAttributeColor);
    glBindAttribLocation(pid, OGEGLAttributeTexcoord0, kOGEGLAttributeTexcoord0);
    
    if (!linkProgram(pid)) {
        printf("Failed to link program: %d", pid);
        return;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(pid, "ModelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(pid, "NormalMatrix");
    uniforms[UNIFORM_DIFFUSE] = glGetUniformLocation(pid, "DIFFUSE");
    
    // Release vertex and fragment shaders.
    if (vertexShader) {
        glDetachShader(pid, vertexShader);
        glDeleteShader(vertexShader);
    }
    if (fragmentShader) {
        glDetachShader(pid, fragmentShader);
        glDeleteShader(fragmentShader);
    }
}

GLboolean OGEProgram::compileShader(GLuint *shader,GLenum type ,const char *shaderStr)
{
    GLint status;
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &shaderStr, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        printf("Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return 0;
    }
    
    return 1;
}

GLboolean OGEProgram::linkProgram(GLuint prog)
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        printf("Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return 0;
    }
    
    return 1;
}

GLboolean OGEProgram::validateProgram(GLuint prog)
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        printf("Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return 0;
    }
    
    return 1;
}