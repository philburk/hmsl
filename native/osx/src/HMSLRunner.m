//
//  HMSLRunner.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 3DO. All rights reserved.
//

#include <stdio.h>
#include "pforth.h"

#ifndef PF_DEFAULT_DICTIONARY
#define PF_DEFAULT_DICTIONARY "pforth.dic"
#endif

#import "HMSLRunner.h"
#import "HMSLApplication.h"

@implementation HMSLRunner

-(void)goForth {
  const char *DicName = PF_DEFAULT_DICTIONARY;
  const char *SourceName = NULL;
  char IfInit = FALSE;
  int Result;
  Result = pfDoForth( DicName, SourceName, IfInit);
  [[HMSLApplication sharedApplication] setResult:Result];
  [NSApp terminate:self];
}

@end
