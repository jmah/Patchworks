//
//  PWDarcsPatchProxyTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-10.
//  Copyright Playhaus 2005. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsPatchProxyTest.h"
#import "PWDarcsPatchProxy.h"
#import "PWDarcsPatch.h"


@implementation PWDarcsPatchProxyTest


- (void)testPatchProxyLoading
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *proxyPath = [myBundle pathForResource:@"20050921185738-39b7c-f542daa22cf0b6005eba8536150de8b36bf44b2d"
	                                         ofType:@"darcspatchproxy"
	                                    inDirectory:@"Test Repository/darcs/patchworks"];
	NSString *patchPath = [myBundle pathForResource:@"20050921185738-39b7c-f542daa22cf0b6005eba8536150de8b36bf44b2d"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Repository/darcs/patches"];
	NSString *repoPath = [[myBundle resourcePath] stringByAppendingPathComponent:@"Test Repository"];
	NSError *proxyError = nil;
	PWDarcsPatchProxy *patchProxy = [[PWDarcsPatchProxy alloc] initWithURL:[NSURL fileURLWithPath:proxyPath] error:&proxyError];
	STAssertNotNil(patchProxy,
		@"Patch proxy failed to initialize.");
	STAssertNil(proxyError,
		@"Patch proxy generated an error.");
	
	NSError *patchError = nil;
	PWDarcsPatch *patch = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&patchError];
	STAssertNotNil(patch,
		@"Patch failed to initialize.");
	STAssertNil(patchError,
		@"Patch generated an error.");
	
	STAssertEqualObjects([[patchProxy proxyURL] absoluteURL], [[NSURL fileURLWithPath:proxyPath] absoluteURL],
		@"Proxy URL was not as expected.");
	STAssertEqualObjects([[patchProxy patchURL] absoluteURL], [[NSURL fileURLWithPath:patchPath] absoluteURL],
		@"Patch URL was not as expected.");
	STAssertEqualObjects([[patchProxy repositoryURL] absoluteURL], [[NSURL fileURLWithPath:repoPath] absoluteURL],
		@"Repository URL was not as expected.");
	
	STAssertEqualObjects([patchProxy patch], patch,
		@"Proxy's patch was not the same as separately-loaded patch.");
	
	[patchProxy release];
}


- (void)testMessageForwarding
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *proxyPath = [myBundle pathForResource:@"20050921202143-39b7c-447d042ca05732eef5811e9cf80114117532a2d4"
	                                         ofType:@"darcspatchproxy"
	                                    inDirectory:@"Test Repository/darcs/patchworks"];
	NSError *proxyError = nil;
	PWDarcsPatchProxy *patchProxy = [[PWDarcsPatchProxy alloc] initWithURL:[NSURL fileURLWithPath:proxyPath] error:&proxyError];
	STAssertNotNil(patchProxy,
		@"Patch proxy failed to initialize.");
	STAssertNil(proxyError,
		@"Patch proxy generated an error.");
	
	NSError *patchError = nil;
	NSString *patchPath = [myBundle pathForResource:@"20050921202143-39b7c-447d042ca05732eef5811e9cf80114117532a2d4"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Repository/darcs/patches"];
	PWDarcsPatch *patch = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&patchError];
	STAssertNotNil(patch,
		@"Patch failed to initialize.");
	STAssertNil(patchError,
		@"Patch generated an error.");
	
	STAssertEqualObjects([patchProxy patchString], [patch patchString],
		@"Patch string was not as expected.");
	STAssertEqualObjects([patchProxy name], [patch name],
		@"Patch name was not as expected.");
	STAssertEqualObjects([patchProxy author], [patch author],
		@"Patch author was not as expected.");
	STAssertEqualObjects([patchProxy authorEmail], [patch authorEmail],
		@"Patch author e-mail was not as expected.");
	STAssertEqualObjects([patchProxy date], [patch date],
		@"Patch date was not as expected.");
	STAssertEquals([patchProxy type], [patch type],
		@"Patch type was not as expected.");
	STAssertEquals([patchProxy isRollbackPatch], [patch isRollbackPatch],
		@"Patch rollback status was not as expected.");
	
	[patchProxy release];
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
