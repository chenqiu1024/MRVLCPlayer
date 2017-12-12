//
//  EAGLLayerCapturer.m
//  MRVLCPlayer
//
//  Created by DOM QIU on 2017/11/19.
//  Copyright © 2017年 Alloc. All rights reserved.
//

#import "EAGLLayerCapturer.h"
#import "fishhook.h"
#import "OpenGLHelper.h"
#import <objc/runtime.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

typedef BOOL (*RenderbufferStoragePrototype)(id, SEL, NSUInteger, id<EAGLDrawable>);
static RenderbufferStoragePrototype orig_renderBufferStorage = NULL;

typedef BOOL (*PresentRenderbufferPrototype)(id, SEL, NSUInteger);
static PresentRenderbufferPrototype orig_presentRenderBuffer = NULL;

typedef void(*glBindFramebufferPrototype)(GLenum target, GLuint framebuffer);
static glBindFramebufferPrototype orig_glBindFramebuffer = NULL;
static glBindFramebufferPrototype orig_glBindFramebufferOES = NULL;

typedef void(*glFramebufferRenderbufferPrototype)(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer);
static glFramebufferRenderbufferPrototype orig_glFramebufferRenderbuffer = NULL;
static glFramebufferRenderbufferPrototype orig_glFramebufferRenderbufferOES = NULL;

static BOOL s_isHooked = NO;

static const char* kRenderbufferFramebufferMap = "kRenderbufferFramebufferMap";
static const char* kFinalRenderbuffer = "kFinalRenderbuffer";

/*
 glFramebuffeRenderbuffer : Framebuffer <-> Renderbuffer
 [EAGLContext renderbufferStorage] : EAGLSharegroup -> Renderbuffer
 
 on glFramebuffeRenderbuffer : if (framebuffer.renderbuffer == eaglSharegroup.renderbuffer) {...}
 on [EAGLContext renderbufferStorage] : if (eaglSharegroup.{Renderbuffer -> Framebuffer}[renderbuffer]) {...}
 
 OffscreenTexture linksTo Drawable(CAEAGLLayer);
 Renderbuffer attachesTo Drawable;
 Renderbuffer attachesTo Framebuffer;
 Anytime we find a Framebuffer -> Renderbuffer -> Drawable link, we should break it by:
 Framebuffer -> OffscreenTexture + OnscreenFramebuffer -> Renderbuffer -> Drawable;
 
 
 Condition: Binding framebuffer.colorAttachment == eaglShareGroup.finalRenderbuffer
 A:
 glBindRenderbuffer(renderbuffer);
 [EAGLContext renderbufferStorage: drawable:layer];
 glBindFramebuffer(framebuffer);
 glFramebuffeRenderbuffer(framebuffer, renderbuffer);
 DRAW;
 [EAGLContext presentRenderbuffer];
 
 B:
 glBindFramebuffer(framebuffer);
 glFramebuffeRenderbuffer(framebuffer, renderbuffer);
 DRAW;
 glBindRenderbuffer(renderbuffer);
 [EAGLContext renderbufferStorage: drawable:layer];
 DRAW;
 [EAGLContext presentRenderbuffer];
 */
BOOL EAGLLayerCapture_RenderbufferStorage(id self, SEL _cmd, NSUInteger target, id drawable)
{
    //    NSLog(@"FKC_RenderbufferStorage $ self = %@, _cmd = %s, target = %ld, drawable = %@", self,_cmd,target,drawable);
    if (s_isHooked)
    {
        EAGLContext* context = (EAGLContext*) self;
        EAGLSharegroup* shareGroup = context.sharegroup;
        
        GLint finalRenderbuffer = 0;
        glGetIntegerv(GL_RENDERBUFFER_BINDING, &finalRenderbuffer);
        NSNumber* finalRenderbufferObj = @(finalRenderbuffer);
        objc_setAssociatedObject(shareGroup, kFinalRenderbuffer, finalRenderbufferObj, OBJC_ASSOCIATION_COPY);
        NSDictionary<NSNumber*, NSNumber* >* renderbuffer2FramebufferMap = objc_getAssociatedObject(shareGroup, kRenderbufferFramebufferMap);
        if (renderbuffer2FramebufferMap)
        {
            NSNumber* framebufferObj = renderbuffer2FramebufferMap[finalRenderbufferObj];
            if (framebufferObj)
            {
                //TODO:
            }
        }
        //return [[CycordVideoRecorder sharedInstance] onRenderbufferStorage:self cmd:_cmd target:target drawable:drawable];
        return YES;
    }
    else
        return orig_renderBufferStorage(self, _cmd, target, drawable);
}

BOOL EAGLLayerCapture_PresentRenderbuffer(id self, SEL _cmd, NSUInteger target)
{
    if (s_isHooked)
        //return [[CycordVideoRecorder sharedInstance] onPresentRenderbuffer:self cmd:_cmd target:target];
        return YES;
    else
        return orig_presentRenderBuffer(self, _cmd, target);
}

void EAGLLayerCapture_glBindFramebuffer(GLenum target, GLuint framebuffer) {
    NSLog(@"EAGLLayerCapture_glBindFramebuffer(%x, %d)", target, framebuffer);
    orig_glBindFramebuffer(target, framebuffer);
}

void EAGLLayerCapture_glFramebufferRenderbuffer(GLenum target, GLenum attachment, GLenum renderbuffertarget, GLuint renderbuffer) {
    NSLog(@"EAGLLayerCapture_glFramebufferRenderbuffer(%x, %x, %x, %d)", target, attachment, renderbuffertarget, renderbuffer);
    orig_glFramebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
}

@implementation EAGLLayerCapturer

+ (void) beginHooking {
    @synchronized (self)
    {
        if (s_isHooked)
            return;
        //*
        rebind_symbols((struct rebinding[])
        {
            {"glBindFramebuffer", (void*)EAGLLayerCapture_glBindFramebuffer, (void**)&orig_glBindFramebuffer},
            {"glBindFramebufferOES", (void*)EAGLLayerCapture_glBindFramebuffer, (void**)&orig_glBindFramebufferOES},
            {"glFramebufferRenderbuffer", (void*)EAGLLayerCapture_glFramebufferRenderbuffer, (void**)&orig_glFramebufferRenderbuffer},
            {"glFramebufferRenderbufferOES", (void*)EAGLLayerCapture_glFramebufferRenderbuffer, (void**)&orig_glFramebufferRenderbufferOES},
        }, 4);
        /*
        Class clsEAGLContext = objc_getClass("EAGLContext");
        
        orig_presentRenderBuffer = (PresentRenderbufferPrototype)class_getMethodImplementation(clsEAGLContext, @selector(presentRenderbuffer:));
        Method mtdPresentRenderBuffer = class_getInstanceMethod(clsEAGLContext, @selector(presentRenderbuffer:));
        class_replaceMethod(clsEAGLContext, @selector(presentRenderbuffer:), IMP(EAGLLayerCapture_PresentRenderbuffer), method_getTypeEncoding(mtdPresentRenderBuffer));
        
        orig_renderBufferStorage = (RenderbufferStoragePrototype)class_getMethodImplementation(clsEAGLContext, @selector(renderbufferStorage:fromDrawable:));
        Method mtdRenderBufferStorage = class_getInstanceMethod(clsEAGLContext, @selector(renderbufferStorage:fromDrawable:));
        class_replaceMethod(clsEAGLContext, @selector(renderbufferStorage:fromDrawable:), IMP(EAGLLayerCapture_RenderbufferStorage), method_getTypeEncoding(mtdRenderBufferStorage));
        
        objc_registerClassPair(clsEAGLContext);
        //*/
        s_isHooked = YES;
    }
}

+ (void) endHooking {
    @synchronized (self)
    {
        if (!s_isHooked)
            return;
        
        Class clsEAGLContext = objc_getClass("EAGLContext");
        
        //gSuperPresentRenderBuffer = class_getMethodImplementation(clsEAGLContext, @selector(presentRenderbuffer:));
        Method mtdPresentRenderBuffer = class_getInstanceMethod(clsEAGLContext, @selector(presentRenderbuffer:));
        class_replaceMethod(clsEAGLContext, @selector(presentRenderbuffer:), (IMP)orig_presentRenderBuffer, method_getTypeEncoding(mtdPresentRenderBuffer));
        
        //gSuperRenderBufferStorage = class_getMethodImplementation(clsEAGLContext, @selector(renderbufferStorage:fromDrawable:));
        Method mtdRenderBufferStorage = class_getInstanceMethod(clsEAGLContext, @selector(renderbufferStorage:fromDrawable:));
        class_replaceMethod(clsEAGLContext, @selector(renderbufferStorage:fromDrawable:), (IMP)orig_renderBufferStorage, method_getTypeEncoding(mtdRenderBufferStorage));
        
        objc_registerClassPair(clsEAGLContext);
        
        s_isHooked = NO;
    }
}

@end
