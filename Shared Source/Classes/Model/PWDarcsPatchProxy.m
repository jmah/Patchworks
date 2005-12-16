//
//  PWDarcsPatchProxy.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-10.
//  Copyright Playhaus 2005. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsPatchProxy.h"


@implementation PWDarcsPatchProxy

#pragma mark Initialization and Deallocation

- (id)initWithURL:(NSURL *)proxyURL error:(NSError **)outError // Designated initializer
{
	if (self = [super init])
	{
		NSString *basename = [[[proxyURL path] lastPathComponent] stringByDeletingPathExtension];
		NSString *relativePatchPath = [NSString stringWithFormat:@"../../patches/%@", [basename stringByAppendingPathExtension:@"gz"]];
		NSURL *patchURL = [NSURL URLWithString:relativePatchPath relativeToURL:proxyURL];
		
		PW_patch = [[PWDarcsPatch patchWithContentsOfURL:patchURL error:outError] retain];
		
		BOOL success = ((PW_patch != nil) && (*outError == nil));
		if (success)
		{
			PW_patchURL = [patchURL retain];
			PW_proxyURL = [proxyURL retain];
		}
		else
		{
			[self release];
			self = nil;
		}
	}
	return self;
}


- (void)dealloc
{
	[PW_patchURL release];
	[PW_proxyURL release];
	[PW_patch release];
	
	[super dealloc];
}



#pragma mark Forwarded Methods

- (NSMethodSignature *)methodSignatureForSelector:(SEL)selector // NSObject
{
	NSMethodSignature *methodSignature = [super methodSignatureForSelector:selector];
	if (!methodSignature)
		methodSignature = [[self patch] methodSignatureForSelector:selector];
	
	return methodSignature;
}


- (void)forwardInvocation:(NSInvocation *)invocation // NSObject
{
	SEL selector = [invocation selector];
	
	if ([[self patch] respondsToSelector:selector])
		[invocation invokeWithTarget:[self patch]];
	else
		[super forwardInvocation:invocation];
}



#pragma mark Accessor Methods

- (PWDarcsPatch *)patch
{
	return PW_patch;
}


- (NSURL *)proxyURL
{
	return PW_proxyURL;
}


- (NSURL *)patchURL
{
	return PW_patchURL;
}


- (NSURL *)repositoryURL
{
	// Climb out of the 'patches' and '_darcs' directories
	return [NSURL URLWithString:@"../.." relativeToURL:[self patchURL]];
}


@end



/*
 * Patchworks is licensed under the BSD license, as follows:
 * 
 * Copyright (c) 2005, Playhaus
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the Playhaus nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without
 *   specific prior written permission.
 * 
 * This software is provided by the copyright holders and contributors "as is"
 * and any express or implied warranties, including, but not limited to, the
 * implied warranties of merchantability and fitness for a particular purpose
 * are disclaimed. In no event shall the copyright owner or contributors be
 * liable for any direct, indirect, incidental, special, exemplary, or
 * consequential damages (including, but not limited to, procurement of
 * substitute goods or services; loss of use, data, or profits; or business
 * interruption) however caused and on any theory of liability, whether in
 * contract, strict liability, or tort (including negligence or otherwise)
 * arising in any way out of the use of this software, even if advised of the
 * possibility of such damage.
 */
