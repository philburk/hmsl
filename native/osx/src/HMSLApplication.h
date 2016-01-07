//
//  HMSLApplication.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#define APP ((HMSLApplication*)NSApp)

#import <Cocoa/Cocoa.h>

@interface HMSLApplication : NSApplication {
  int result;
  NSFont *_font;
  NSMutableDictionary *_fontAttributes;
  NSMutableDictionary *_windowDictionary;
}

-(void)flushAllWindowDrawing;

@property int result;
@property (retain) NSFont *font;
@property (retain) NSMutableDictionary *fontAttributes;
@property (retain) NSMutableDictionary *windowDictionary;

@end
