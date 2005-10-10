//
//  PWDarcsTagPatchTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-08.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsTagPatchTest.h"
#import "PWDarcsPatch.h"
#import "PWDarcsTagPatch.h"


@implementation PWDarcsTagPatchTest


- (void)testTagPatch
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"05-Tag-Compressed"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSError *error = nil;
	PWDarcsPatch *patch = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&error];
	STAssertNotNil(patch,
		@"Tag patch failed to initialize.");
	STAssertNil(error,
		@"Tag patch genereated an error.");
	
	STAssertEqualObjects([patch name], @"1.0 preview for darcs-users",
		@"Patch name didn't correctly parse.");
	STAssertEqualObjects([patch author], @"Jonathon Mah <jonathon@playhaus.org>",
		@"Patch author didn't correctly parse.");
	
	NSCalendarDate *targetDate = [NSCalendarDate dateWithYear:2005
	                                                    month:9
	                                                      day:22
	                                                     hour:18
	                                                   minute:10
	                                                   second:21
	                                                 timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	STAssertEqualObjects([patch date], targetDate,
		@"Patch date didn't correctly parse.");
	STAssertFalse([patch isRollbackPatch],
		@"Rollback flag didn't correctly parse.");
	STAssertEquals([patch patchType], PWDarcsTagPatchType,
		@"Patch type not correctly set.");
}


- (void)testRollbackTagPatch
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"06-Rollback-Tag-Compressed"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSError *error = nil;
	PWDarcsPatch *patch = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&error];
	STAssertNotNil(patch,
		@"Rollback tag patch failed to initialize.");
	STAssertNil(error,
		@"Rollback tag patch genereated an error.");
	
	STAssertEqualObjects([patch name], @"Rollback tag",
		@"Patch name didn't correctly parse.");
	STAssertEqualObjects([patch author], @"Other Author <author@other.com>",
		@"Patch author didn't correctly parse.");
	
	NSCalendarDate *targetDate = [NSCalendarDate dateWithYear:2005
	                                                    month:10
	                                                      day:8
	                                                     hour:8
	                                                   minute:43
	                                                   second:57
	                                                 timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	STAssertEqualObjects([patch date], targetDate,
		@"Patch date didn't correctly parse.");
	STAssertTrue([patch isRollbackPatch],
		@"Rollback flag didn't correctly parse.");
	STAssertEquals([patch patchType], PWDarcsTagPatchType,
		@"Patch type not correctly set.");
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
