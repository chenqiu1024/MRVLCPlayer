//
//  OpenGLHelper.h
//  GLRecFramework
//
//  Created by FutureBoy on 9/29/15.
//  Copyright © 2015 CyberChall. All rights reserved.
//

#ifndef OpenGLHelper_h
#define OpenGLHelper_h

#include <OpenGLES/ES1/gl.h>

#ifdef DEBUG
#define CHECK_GL_ERROR_DEBUG() \
do { \
GLenum __error = glGetError(); \
if(__error) { \
NSLog(@"OpenGL error 0x%04X in %s %s %d\n", __error, __FILE__, __FUNCTION__, __LINE__); \
} \
} while (false)
#else
#define CHECK_GL_ERROR_DEBUG()
#endif

#ifdef __cplusplus
extern "C" {
#endif
    
    GLuint SizeOfGLType(GLenum type);
    
    GLuint NumComponentsOfPixelFormat(GLenum format);
    
    void GetByteWidthOfPixelFormat(int& numBytes, int& denBytes, GLenum type);
    
    GLint GetBufferBinding(GLenum target);
    
    GLint GetBufferDataSize(GLenum target);
    
    GLuint compileShader(const char* shaderSource, GLenum shaderType);
    
    GLuint compileAndLinkShader(const char* vertexShaderSource, const char* fragmentShaderSource);
    
    GLint compileShaderProgram(GLint program, const char* vertexShaderSource, const char* fragmentShaderSource);
    
    GLint  linkShaderProgram(GLint program);
    
#ifdef __cplusplus
}
#endif

#endif /* OpenGLHelper_h */
