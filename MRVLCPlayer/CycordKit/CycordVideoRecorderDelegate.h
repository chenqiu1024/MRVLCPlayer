//
//  CycordVideoRecorderDelegate.h
//  ClumsyCopter
//
//  Created by FutureBoy on 12/22/14.
//
//

#ifndef ClumsyCopter_CycordVideoRecorderDelegate_h
#define ClumsyCopter_CycordVideoRecorderDelegate_h

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

@protocol CycordVideoRecorderDelegate <NSObject>

@optional

- (void) didRenderOneFrame:(int)elapsedMillseconds;

- (void) didRecordOneFrame:(int)recordedMillseconds;

- (void) willRecordOneFrame:(CVPixelBufferRef)pixelBuffer;

@end

#endif
