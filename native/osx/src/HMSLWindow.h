//
//  HMSLWindow.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 8/7/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "hmsl.h"

@interface HMSLWindow : NSWindow {
  NSGraphicsContext *_graphicsContext;
}

@property (retain) NSGraphicsContext* graphicsContext;

+ (NSMutableDictionary*)windowDictionary;
+ (void) hmslWindowWithTitle: (NSString*) title
                             frame: (NSRect) frame
                         windowPtr: (HMSLWindow**) windowPtr;

- (void) drawRectangle: (HMSLRect) rect;
- (void) drawLineFrom: (HMSLPoint) start to: (HMSLPoint) end;
- (void) drawText: (NSString*) text atPoint: (NSPoint) point;
- (void) flushCurrentContext;
- (void) hmslDrawingMode: (int32_t) mode;
- (void) hmslDrawingColor: (const double*) color;
- (void) hmslBackgroundColor: (const double*) color;

@end
