//
//  OGEApplication.cpp
//  es2
//
//  Created by wangyang on 9/10/15.
//  Copyright (c) 2015 wangyang. All rights reserved.
//

#include "OGEApplication.h"
#include "OGEOBJ.h"
#include "OGEGlobal.h"
#include "OGEProgram.h"
#include "OGEMaterial.h"
#include "OGETexture.h"
#include <GLKit/GLKit.h>


OGEApplication* OGEApplication::shared()
{
    static OGEApplication* app = NULL;
    if(app == NULL)
    {
        app = new OGEApplication();
    }
    return app;
}

OGEApplication::OGEApplication()
{
    program = new OGEProgram();
}

OGEApplication::~OGEApplication()
{
    delete program;
}

void OGEApplication::init()
{
    std::string defaultVertexShader = OGEGlobal::pathForResource("ShaderDefault.vsh");
    std::string defaultFragmentShader = OGEGlobal::pathForResource("ShaderDefault.fsh");
    program->initWithPath(defaultVertexShader.data(), defaultFragmentShader.data());
    
    std::string cubePath = OGEGlobal::pathForResource("cube2.obj");
    obj = new OGEOBJ();
    obj->parse(cubePath.data());
    
    glEnable(GL_DEPTH_TEST);
}


void OGEApplication::draw(float timeInMilliseconds)
{
   // glClearColor(0.65f, 0.65f, 0.65f, 0.0f);
   // glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  //  glUseProgram(program->pid);
    
    CGRect bounds =  [[UIScreen mainScreen] bounds];
    GLKMatrix4 projection = GLKMatrix4MakePerspective(45.0f/180*M_PI, bounds.size.width/bounds.size.height, 1.0, 1000.0);
    projection = GLKMatrix4Multiply(projection,GLKMatrix4MakeTranslation(0, 0, -35.0));
    
    
    static float yAngle = 0.0f;
    GLKMatrix4 modelMatrix = GLKMatrix4MakeRotation(yAngle, 1.0, 0.0,0.0);
    yAngle += timeInMilliseconds / 1000 * 0.5;
    
    projection = GLKMatrix4Multiply(projection,modelMatrix);
    
    glUniformMatrix4fv(program->uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, projection.m);
    glUniform1i(program->uniforms[UNIFORM_DIFFUSE], 0);
    
    for(int i=0;i<obj->meshes.size();i++)
    {
        glBindVertexArrayOES(obj->meshes[i].vao);
//        if(obj->meshes[i].material.diffuseTexture.textureID)
//        {
//            glActiveTexture(GL_TEXTURE0);
//            glBindTexture(GL_TEXTURE_2D, obj->meshes[i].material.diffuseTexture.textureID);
//        }
    glDrawElements(GL_TRIANGLES, obj->meshes[i].triangleCount * 3, GL_UNSIGNED_INT, NULL);
    //    glDrawArrays(GL_TRIANGLES, 0, obj->meshes[i].triangleCount * 3);
    }
}


void OGEApplication::destroy()
{

}