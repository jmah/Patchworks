// MOAssertions.m
// MOKit
//
// Copyright © 2002-2005, Mike Ferris.  All rights reserved.
// See bottom of file for license and disclaimer.

#import "MOAssertions.h"
#import "MORuntimeUtilities.h"

MOKIT_EXTERN void MOPWHandleAssertionFailure(BOOL raise, SEL selector, id object, const char *functionName, const char *fileName, unsigned line, NSString *format, ...) {
    va_list   args;

    va_start(args, format);
    if (selector != NULL) {
        [[MOPWAssertionHandler currentHandler] handleFailureWithRaise:raise inMethod:selector object:object file:[NSString stringWithCString:fileName] lineNumber:line description:format arguments:args];
    }
    else {
        [[MOPWAssertionHandler currentHandler] handleFailureWithRaise:raise inFunction:[NSString stringWithCString:functionName] file:[NSString stringWithCString:fileName] lineNumber:line description:format arguments:args];
    }
    va_end(args);
    
}

@implementation MOPWAssertionHandler

static MOPWAssertionHandler *_currentHandler = nil;

+ (MOPWAssertionHandler *)currentHandler {
    if (!_currentHandler) {
        _currentHandler = [[MOPWAssertionHandler allocWithZone:NULL] init];
    }
    return _currentHandler;
}

+ (void)setCurrentHandler:(MOPWAssertionHandler *)handler {
    if (_currentHandler != handler) {
        [_currentHandler release], _currentHandler = nil;
        _currentHandler = [handler retain];
    }
}

- (void)handleFailureWithRaise:(BOOL)raise inMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format arguments:(va_list)args {
    NSString *msg;
    NSString *fullMsg;
    NSException *exception = nil;

    msg = [[NSString allocWithZone:[self zone]] initWithFormat:format arguments:args];
    fullMsg = [[NSString allocWithZone:[self zone]] initWithFormat:@"Assertion failure at %@:%u (%@ <self=0x%u>): %@", fileName, line, MOPWFullMethodName(object, selector), (unsigned)object, msg];
    [msg release];
    NSLog(@"%@", fullMsg);
    if (raise) {
        exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:fullMsg userInfo:nil];
    }
    [fullMsg release];
    [exception raise];
}

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format arguments:(va_list)args {
    [self handleFailureWithRaise:YES inMethod:selector object:object file:fileName lineNumber:line description:format arguments:args];
}

- (void)handleFailureWithRaise:(BOOL)raise inFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format arguments:(va_list)args {
    NSString *msg;
    NSString *fullMsg;
    NSException *exception = nil;

    msg = [[NSString allocWithZone:[self zone]] initWithFormat:format arguments:args];
    fullMsg = [[NSString allocWithZone:[self zone]] initWithFormat:@"Assertion failure at %@:%u (function=%@): %@", fileName, line, functionName, msg];
    [msg release];
    NSLog(@"%@", fullMsg);
    if (raise) {
        exception = [NSException exceptionWithName:NSInternalInconsistencyException reason:fullMsg userInfo:nil];
    }
    [fullMsg release];
    [exception raise];
}

- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format arguments:(va_list)args {
    [self handleFailureWithRaise:YES inFunction:functionName file:fileName lineNumber:line description:format arguments:args];
}

- (void)handleFailureWithRaise:(BOOL)raise inMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format, ... {
    va_list   args;

    va_start(args, format);
    [self handleFailureWithRaise:(BOOL)raise inMethod:selector object:object file:fileName lineNumber:line description:format arguments:args];
    va_end(args);
    
}

- (void)handleFailureInMethod:(SEL)selector object:(id)object file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format, ... {
    va_list   args;
    
    va_start(args, format);
    [self handleFailureWithRaise:YES inMethod:selector object:object file:fileName lineNumber:line description:format arguments:args];
    va_end(args);
    
}

- (void)handleFailureWithRaise:(BOOL)raise inFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format, ... {
    va_list   args;

    va_start(args, format);
    [self handleFailureWithRaise:(BOOL)raise inFunction:functionName file:fileName lineNumber:line description:format arguments:args];
    va_end(args);
}

- (void)handleFailureInFunction:(NSString *)functionName file:(NSString *)fileName lineNumber:(int)line description:(NSString *)format, ... {
    va_list   args;
    
    va_start(args, format);
    [self handleFailureWithRaise:YES inFunction:functionName file:fileName lineNumber:line description:format arguments:args];
    va_end(args);
}

@end


/*
 This file contains Original Code and/or Modifications of Original Code as defined in and that are subject to the Ferris Public Source License Version 1.2 (the 'License'). You may not use this file except in compliance with the License. Please obtain a copy of the License at http://mokit.sourceforge.net/License.html and read it before using this file.

 The Original Code and all software distributed under the License are distributed on an 'AS IS' basis, WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESS OR IMPLIED, AND MIKE FERRIS HEREBY DISCLAIMS ALL SUCH WARRANTIES, INCLUDING WITHOUT LIMITATION, ANY WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. Please see the License for the specific language governing rights and limitations under the License.
 */
