/* @(#) pf_main.c 98/01/26 1.2 */
/***************************************************************
 ** Forth based on 'C'
 **
 ** main() routine that demonstrates how to call PForth as
 ** a module from 'C' based application.
 ** Customize this as needed for your application.
 **
 ** Author: Phil Burk
 ** Copyright 1994 3DO, Phil Burk, Larry Polansky, David Rosenboom
 **
 ** The pForth software code is dedicated to the public domain,
 ** and any third party may reproduce, distribute and modify
 ** the pForth software code or any derivative works thereof
 ** without any compensation or license.  The pForth software
 ** code is provided on an "as is" basis without any warranty
 ** of any kind, including, without limitation, the implied
 ** warranties of merchantability and fitness for a particular
 ** purpose and their equivalents under the laws of any jurisdiction.
 **
 ***************************************************************/

#if (defined(PF_NO_STDIO) || defined(PF_EMBEDDED))
#define NULL  ((void *) 0)
#define ERR(msg) /* { printf msg; } */
#else
#include <stdio.h>
#define ERR(msg) { printf msg; }
#endif

#include "pforth.h"
#import "hmsl.h"

#import <Cocoa/Cocoa.h>
#import "HMSLApplication.h"
#import "HMSLDelegate.h"

#ifndef TRUE
#define TRUE (1)
#define FALSE (0)
#endif

static HMSLDelegate* _appDelegate;

int main(int argc, const char * argv[]) {
  int result;
  @autoreleasepool {
    [HMSLApplication sharedApplication];
    _appDelegate = [[HMSLDelegate alloc] init];

    [[NSBundle mainBundle] loadNibNamed:@"MainMenu"
                                  owner:NSApp
                        topLevelObjects:nil];
    [NSApp setDelegate:_appDelegate];
    [NSApp run];
    result = ((HMSLApplication*)NSApp).result;
  }
  return result;
}
