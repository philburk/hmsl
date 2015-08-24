//
//  HMSLRunner.h
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMSLRunner : NSObject {
  BOOL isRunning;
}

-(void)goForth;

@property BOOL isRunning;

@end
