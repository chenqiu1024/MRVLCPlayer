//
//  CycordVideoRecorder.h
//  HelloOGLES2
//
//  Created by FutureBoy on 12/18/14.
//  Copyright (c) 2014 RedShore. All rights reserved.
//

#ifndef __HelloOGLES2__CycordVideoRecorder__
#define __HelloOGLES2__CycordVideoRecorder__

#import "CycordVideoRecorderDelegate.h"
#import <CoreVideo/CoreVideo.h>
#import <UIKit/UIKit.h>

@class CAEAGLLayer;
@protocol AVAudioRecorderDelegate;

@interface CycordVideoRecorder : NSObject <AVAudioRecorderDelegate>

@property (nonatomic, strong) id<CycordVideoRecorderDelegate> delegate;

@property (nonatomic, strong, readonly) NSMutableDictionary* snapshotDatas;

@property (nonatomic, assign) CVOpenGLESTextureRef renderTexture;

+ (CycordVideoRecorder*) initVideoRecorder;
+ (void) releaseVideoRecorder;

+ (CycordVideoRecorder*) sharedInstance;

+ (void) startRecording;
+ (void) startRecording : (float)fps;

+ (void) stopRecording;
+ (void) stopRecordingWithCompletionHandler:(void(^)(void))handler;

+ (void) startReplaying:(UIViewController*)parentVC;

@end

#endif /* defined(__HelloOGLES2__CycordVideoRecorder__) */
