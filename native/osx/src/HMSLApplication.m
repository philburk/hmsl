//
//  HMSLApplication.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import "HMSLApplication.h"
#import "HMSLWindow.h"

@implementation HMSLApplication

@synthesize font = _font;
@synthesize fontAttributes = _fontAttributes;

-(void)flushAllWindowDrawing {
  [self makeWindowsPerform:@selector(flushCurrentContext)
                   inOrder:YES];
}

@synthesize result;

@end
