//
//  HMSLRunner.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#import <stdio.h>
#import "pforth.h"
#import "hmsl.h"

#import "HMSLRunner.h"
#import "HMSLApplication.h"

@implementation HMSLRunner

-(void)goForth {
  const char *DicName = PF_DEFAULT_DICTIONARY;
  const char *SourceName = NULL;
  char IfInit = FALSE;
  int Result;
  Result = pfDoForth( DicName, SourceName, IfInit);
  APP.result = Result;
  [NSApp terminate:self];
  [NSThread exit];
}

@synthesize isRunning;

@end
