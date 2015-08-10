//
//  HMSLView.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "HMSLWindow.h"
#import "hmsl.h"

typedef struct hmslContext {
  NSPoint currentPoint;
  NSPoint mouseEvent;
  NSDictionary *fontAttributes;
  int32_t color;
} hmslContext;

extern NSMutableArray *hmslWindowArray;
NSMutableArray *hmslWindowArray;

extern NSMutableArray *hmslEventBuffer;
NSMutableArray *hmslEventBuffer;

extern hmslContext *gHMSLContext;
hmslContext *gHMSLContext;

extern HMSLWindow* getMainWindow( NSMutableArray *windowArray );

@interface HMSLView : NSView

@end
