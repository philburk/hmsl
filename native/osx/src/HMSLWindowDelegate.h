//
//  HMSLWindowDelegate.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "hmsl.h"

extern NSMutableArray *hmslWindowArray;
NSMutableArray *hmslWindowArray;

extern NSMutableArray *hmslEventBuffer;
NSMutableArray *hmslEventBuffer;

NSBezierPath *currentPoint;
NSGraphicsContext *currentContext;
CGContextRef drawingContext;

@interface HMSLWindowDelegate : NSObject<NSWindowDelegate>

@end
