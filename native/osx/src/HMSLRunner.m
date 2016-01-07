//
//  HMSLRunner.m
//  HMSL-OSX
//
//  Created by Andrew C Smith on 2/22/15.
//  Copyright (c) 2015 Andrew C Smith. All rights reserved.
//

#import <stdio.h>
#import "pforth.h"
#import "hmsl.h"

#import "HMSLRunner.h"
#import "HMSLApplication.h"

@implementation HMSLRunner

-(void)goForth:(NSArray*)arguments {
  __block char *DicName = PF_DEFAULT_DICTIONARY;
  __block char *SourceName = NULL;
  __block char IfInit = FALSE;
  __block int Result;
  
  // Enumerate over arguments
  [arguments enumerateObjectsUsingBlock: ^(id obj, NSUInteger idx, BOOL *stop)
  {
    // Skip the first argument (the filename)
    if (idx == 0) return;
    // NSLog(@"%@", arguments);
    NSString *arg = (NSString*)obj;

    if ( [arg characterAtIndex:0] == '-' ) {
      char c = [arg characterAtIndex:1];
      switch (c)
      {
        case 'i':
          IfInit = TRUE;
          DicName = NULL;
          break;
          
        case 'q':
          pfSetQuiet(TRUE);
          break;
          
        case 'd':
          if( arg.length > 2 ) {
            DicName = malloc(arg.length - 1);
            [[arg substringWithRange:NSMakeRange(2, arg.length-2)] getCString:DicName maxLength:(arg.length - 1) encoding:NSASCIIStringEncoding];
          }
          /* Allow space after -d (Thanks Aleksej Saushev) */
          /* Make sure there is another argument. */
//          else if( (i+1) < argc )
//          {
//            DicName = argv[++i];
//          }
//          
//          if (DicName == NULL || *DicName == '\0')
//          {
//            DicName = PF_DEFAULT_DICTIONARY;
//          }
          break;
          
        default:
          NSLog(@"Unrecognized option!\n");
          NSLog(@"pforth {-i} {-q} {-dfilename.dic} {sourcefilename}\n");
          APP.result = 1;
          [NSApp terminate:self];
          [NSThread exit];
          break;
      }
    } else {
      SourceName = (char*)[arg cStringUsingEncoding:NSASCIIStringEncoding];
    }
  }];
  

  Result = pfDoForth( DicName, SourceName, IfInit);
  APP.result = Result;
  [NSApp terminate:self];
  [NSThread exit];
}

@synthesize isRunning;

@end
