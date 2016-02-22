//
//  OGEOBJ.cpp
//  es2
//
//  Created by wangyang on 15/9/10.
//  Copyright (c) 2015年 wangyang. All rights reserved.
//

#include "OGEOBJ.h"
#include "tiny_obj_loader.h"
#include "OGEMesh.h"
#include "OGEMaterial.h"
#include "OGEFile.h"
#include "OGETexture.h"
#include "OGEDefines.h"

template <class T>
std::vector<T> OGEOBJ::listToVector(std::list<T> list) {
    std::vector<T> vec;
    for(auto it = list.begin();it != list.end();it++)
    {
        vec.push_back(*it);
    }
    return vec;
}

OGEOBJ::~OGEOBJ()
{
    
}
//
//GLuint processVertex(OBJ::VertexList vertices)
//{
//    GLuint vertexVBO;
//    unsigned long bufferSize = vertices.size() * 3;
//    GLfloat* buffer = (GLfloat*)calloc(vertices.size() * 3, sizeof(GLfloat));
//    GLfloat* bufferStart = buffer;
//    for(auto it = vertices.begin();it != vertices.end();++it)
//    {
//        memcpy(buffer, *it, 3 * sizeof(GLfloat));
//        buffer+=3;
//    }
//    glGenBuffers(1, &vertexVBO);
//    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
//    glBufferData(GL_ARRAY_BUFFER,bufferSize , bufferStart, GL_STATIC_DRAW);
//
//    free(bufferStart);
//    return vertexVBO;
//}
//
//GLuint processTexcood()
//{
//    GLuint vertexVBO;
//    unsigned long bufferSize = 3 * 2;
//    GLfloat* buffer = (GLfloat*)calloc(3 * 2, sizeof(GLfloat));
//    GLfloat* bufferStart = buffer;
////    for(auto it = vertices.begin();it != vertices.end();++it)
////    {
////        memcpy(buffer, *it, 3 * sizeof(GLfloat));
////        buffer+=3;
////    }
//    bufferStart[0] = 0;
//    bufferStart[1] = 0;
//    bufferStart[2] = 0;
//    bufferStart[3] = 1;
//    bufferStart[4] = 1;
//    bufferStart[5] = 1;
//
//    glGenBuffers(1, &vertexVBO);
//    glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
//    glBufferData(GL_ARRAY_BUFFER,bufferSize , bufferStart, GL_STATIC_DRAW);
//
//    free(bufferStart);
//    return vertexVBO;
//}
//
//GLuint processIndices(OBJ::IndicesList indexList)
//{
//    GLuint vbo;
//    unsigned long bufferSize = indexList.size() * sizeof(unsigned short);
//    unsigned short* buffer = (unsigned short*)calloc(indexList.size(), sizeof(unsigned short));
//    unsigned short* bufferStart = buffer;
//    for(auto it = indexList.begin();it != indexList.end();++it)
//    {
//        unsigned short index = (unsigned short)(*it)[0];
//        index -= 1;
//        printf("-- > %d",index);
//        memcpy(buffer, &index, sizeof(unsigned short));
//        buffer++;
//    }
//
//    bufferStart[0] = 0;
//    bufferStart[1] = 1;
//    bufferStart[2] = 2;
//
//    glGenBuffers(1, &vbo);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, vbo);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER,bufferSize , bufferStart, GL_STATIC_DRAW);
//
//    free(bufferStart);
//    return vbo;
//}

void OGEOBJ::parse(const char *objfile)
{
    std::string path(objfile);
    auto result = path.find_last_of("/");
    std::string basePath = std::string(path.begin(),path.begin() + result);
    basePath += '/';
    
    std::vector<tinyobj::shape_t> shapes;
    std::vector<tinyobj::material_t> materials;
    tinyobj::LoadObj(shapes, materials, objfile);
    for (auto it = shapes.begin();it != shapes.end();++it)
    {
        unsigned long vertexCount = it->mesh.positions.size() / 3;
        long bufferSize = vertexCount * sizeof(GLfloat) * (3 * 3 + 3 * 3 + 3 * 2);
        unsigned char* buffer = (unsigned char*)malloc(bufferSize);
        unsigned char* bufferStart = buffer;
        for(int i = 0;i < vertexCount;i++)
        {
            memcpy(buffer, &(it->mesh.positions[i * 3]), 3 * sizeof(GLfloat));
            buffer+=3 * sizeof(GLfloat);
            
            if(it->mesh.normals.size() > 0)
            {
            memcpy(buffer, &(it->mesh.normals[i * 3]) , 3 * sizeof(GLfloat));
            }
            else
                 memset(buffer, 0 , 3 * sizeof(GLfloat));
            buffer+=3 * sizeof(GLfloat);
            
            memcpy(buffer, &(it->mesh.texcoords[i * 2]), 2 * sizeof(GLfloat));
            printf("uv:%f , %f\n",*((GLfloat*)buffer),*((GLfloat*)buffer + 1));
            buffer+=2 * sizeof(GLfloat);
        }
        
        OGEMesh mesh;
        GLuint vao,vertexVBO,indicesVBO;
        glGenVertexArraysOES(1, &vao);
        glBindVertexArrayOES(vao);
        
        glGenBuffers(1, &vertexVBO);
        glBindBuffer(GL_ARRAY_BUFFER, vertexVBO);
        glBufferData(GL_ARRAY_BUFFER,bufferSize , bufferStart, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(OGEGLAttributePosition);
        glVertexAttribPointer(OGEGLAttributePosition, 3, GL_FLOAT, GL_FALSE,8 * sizeof(GLfloat), 0);
        
        glEnableVertexAttribArray(OGEGLAttributeNormal);
        glVertexAttribPointer(OGEGLAttributeNormal, 3, GL_FLOAT, GL_FALSE,8* sizeof(GLfloat), (char*)NULL + sizeof(GLfloat) * 3);
        
        glEnableVertexAttribArray(OGEGLAttributeTexcoord0);
        glVertexAttribPointer(OGEGLAttributeTexcoord0, 2, GL_FLOAT, GL_FALSE,8 * sizeof(GLfloat), (char*)NULL + sizeof(GLfloat) * 6);
        
        mesh.vao = vao;
        mesh.triangleCount = it->mesh.indices.size() / 3;
        
        glGenBuffers(1, &indicesVBO);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indicesVBO);
        glBufferData(GL_ELEMENT_ARRAY_BUFFER,it->mesh.indices.size() * sizeof(unsigned int) , &(it->mesh.indices[0]), GL_STATIC_DRAW);
        
        glBindVertexArrayOES(0);
        
        
                if(it->mesh.material_ids.size() > 0)
                {
                    tinyobj::material_t material = materials[0];
                    mesh.material.diffuseTexture.init((basePath + material.diffuse_texname).data());
                }
        
        meshes.push_back(mesh);
    }
    
    //    delete obj;
}