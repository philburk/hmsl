//
//  HMSLWindowDelegate.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NSMutableArray *hmslWindowArray;
NSBezierPath *currentPoint;
NSGraphicsContext *currentContext;
CGContextRef drawingContext;

@interface HMSLWindowDelegate : NSObject<NSWindowDelegate>

@end
