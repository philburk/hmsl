//
//  HMSLView.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "hmsl.h"

@interface HMSLView : NSView

- (HMSLPoint)flipEventCoordinates:(NSEvent *)event;

@end
