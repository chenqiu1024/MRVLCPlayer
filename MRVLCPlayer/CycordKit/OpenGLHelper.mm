//
//  OpenGLHelper.c
//  GLRecFramework
//
//  Created by FutureBoy on 9/29/15.
//  Copyright © 2015 CyberChall. All rights reserved.
//

#include "OpenGLHelper.h"
#include <Foundation/Foundation.h>
#include <OpenGLES/ES2/gl.h>
#include <stdlib.h>
#include <string.h>

GLuint SizeOfGLType(GLenum type)
{
    switch (type)
    {
        case GL_BYTE:
            return sizeof(GLbyte);
        case GL_UNSIGNED_BYTE:
            return sizeof(GLubyte);
        case GL_SHORT:
            return sizeof(GLshort);
        case GL_UNSIGNED_SHORT:
            return sizeof(GLushort);
        case GL_FLOAT:
            return sizeof(GLfloat);
        case GL_FIXED:
            return sizeof(GLfixed);
        case GL_INT:
            return sizeof(GLint);
        case GL_UNSIGNED_INT:
            return sizeof(GLuint);
        case GL_BOOL:
            return sizeof(GLboolean);
        default:
            return sizeof(GLint);
    }
}

GLuint NumComponentsOfPixelFormat(GLenum format)
{
    int nComponents = 1;
    switch (format)
    {
        case GL_RGB:
            //case GL_BGR:
            //case GL_BGR_EXT:
            nComponents = 3;
            break;
        case GL_RGBA:
            //case GL_BGRA:
            //case GL_BGRA_EXT:
            nComponents = 4;
            break;
        case GL_ALPHA:
        case GL_LUMINANCE:
            //case GL_STENCIL_INDEX:
            //case GL_DEPTH_COMPONENT:
            //case GL_RED:
            //case GL_GREEN:
            //case GL_BLUE:
            nComponents = 1;
            break;
        case GL_LUMINANCE_ALPHA:
            nComponents = 2;
            break;
    }
    return nComponents;
}

void GetByteWidthOfPixelFormat(int& numBytes, int& denBytes, GLenum type)
{
    numBytes = 1, denBytes = 1;
    switch (type)
    {
        case GL_UNSIGNED_BYTE:
        case GL_BYTE:
            numBytes = 1;
            break;
        case GL_UNSIGNED_SHORT_4_4_4_4:
        case GL_UNSIGNED_SHORT_5_5_5_1:
            denBytes = 2;
            break;
        case GL_UNSIGNED_SHORT_5_6_5:
            numBytes = 2;
            denBytes = 3;
            break;
            /*
             case GL_BITMAP:
             numBytes = 1;
             denBytes = 8;
             break;*/
        case GL_UNSIGNED_SHORT:
        case GL_SHORT:
            numBytes = 2;
            break;
            /*case GL_UNSIGNED_INT:
             case GL_INT:
             numBytes = 4;
             break;*/
        case GL_FLOAT:
            numBytes = 4;
            break;
        case GL_FIXED:
            numBytes = 4;///???
            break;
    }
}

GLint GetBufferBinding(GLenum target)
{
    GLint bufferBinding;
    switch (target)
    {
        case GL_ARRAY_BUFFER:
            glGetIntegerv(GL_ARRAY_BUFFER_BINDING, &bufferBinding);
            break;
        case GL_ELEMENT_ARRAY_BUFFER:
            glGetIntegerv(GL_ELEMENT_ARRAY_BUFFER_BINDING, &bufferBinding);
            break;
        default:
            bufferBinding = -1;
            break;
    }
    return bufferBinding;
}

GLint GetBufferDataSize(GLenum target)
{
    GLint size;
    glGetBufferParameteriv(target, GL_BUFFER_SIZE, &size);
    return size;
}

GLuint compileShader(const char* shaderSource, GLenum shaderType)
{
    GLuint shaderHandle = glCreateShader(shaderType);
    
    GLchar * source = (GLchar*)shaderSource;
    
    if (!source)
    {
        ///        CCLog("Error loading shader: %s", shaderFileName);
        exit(1);
    }
    
    //const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int) strlen(source);
    glShaderSource(shaderHandle, 1, &source, &shaderStringLength);
    
    glCompileShader(shaderHandle);
    
    GLint logLength;
    glGetShaderiv(shaderHandle, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetShaderInfoLog(shaderHandle, logLength, &logLength, log);
        NSLog(@"Shader compiling log:\n%s", log);
        free(log);
    }
    
    return shaderHandle;
}

GLint compileShaderProgram(GLint program, const char* vertexShaderSource, const char* fragmentShaderSource)
{
    GLuint vertexShader = compileShader(vertexShaderSource, GL_VERTEX_SHADER);
    GLuint fragmentShader = compileShader(fragmentShaderSource, GL_FRAGMENT_SHADER);
    // 2
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    GLint logLength, status;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        NSLog(@"Failed to link program");
    }
    
    glValidateProgram(program);
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    if (status == 0)
    {
        NSLog(@"Failed to validate program");
    }
    
    return status;
}

GLint  linkShaderProgram(GLint program)
{
    glLinkProgram(program);
    
    GLint logLength, status;
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar*)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == 0)
    {
        NSLog(@"Failed to link program");
    }
    
    glValidateProgram(program);
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    if (status == 0)
    {
        NSLog(@"Failed to validate program");
    }
    
    return status;
}

GLuint compileAndLinkShader(const char* vertexShaderSource, const char* fragmentShaderSource) {
    GLuint program = glCreateProgram();
    compileShaderProgram(program, vertexShaderSource, fragmentShaderSource);
    linkShaderProgram(program);
    return program;
}
