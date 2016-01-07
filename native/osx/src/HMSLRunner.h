//
//  HMSLRunner.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMSLRunner : NSObject {
  BOOL isRunning;
}

-(void)goForth:(NSArray*)arguments;

@property BOOL isRunning;

@end
