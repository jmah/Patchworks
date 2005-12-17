//
//  PWDarcsChangePatchTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-08.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsChangePatchTest.h"
#import "PWDarcsPatch.h"
#import "PWDarcsChangePatch.h"


@implementation PWDarcsChangePatchTest


- (void)testCompressedChangePatch
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"01-Change-Compressed-NoLongComment"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSError *error = nil;
	PWDarcsPatch *patch = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&error];
	STAssertNotNil(patch,
		@"Compressed patch failed to initialize.");
	STAssertNil(error,
		@"Compressed patch genereated an error.");
	
	STAssertEqualObjects([patch name], @"Removed pragma mark separators and standardized file spacing",
		@"Patch name didn't correctly parse.");
	STAssertEqualObjects([patch author], @"Jonathon Mah <jonathon@playhaus.org>",
		@"Patch author didn't correctly parse.");
	STAssertEqualObjects([patch authorEmail], @"jonathon@playhaus.org",
		@"Author e-mail didn't correctly parse.");
	
	NSCalendarDate *targetDate = [NSCalendarDate dateWithYear:2005
	                                                    month:9
	                                                      day:30
	                                                     hour:0
	                                                   minute:37
	                                                   second:38
	                                                 timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	STAssertEqualObjects([patch date], targetDate,
		@"Patch date didn't correctly parse.");
	STAssertFalse([patch isRollbackPatch],
		@"Rollback flag didn't correctly parse.");
	STAssertEquals([patch type], PWDarcsChangePatchType,
		@"Patch type not correctly set.");
	STAssertNil([(PWDarcsChangePatch *)patch longComment],
		@"Long comment didn't correctly parse.");
}


- (void)testCompressedChangePatchWithLongComment
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"03-Change-Compressed-LongComment"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSError *error = nil;
	PWDarcsPatch *patch = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&error];
	STAssertNotNil(patch,
		@"Compressed patch failed to initialize.");
	STAssertNil(error,
		@"Compressed patch genereated an error.");
	
	STAssertEqualObjects([patch name], @"Disabled missing newline warnings due to some OgreKit headers",
		@"Patch name didn't correctly parse.");
	STAssertEqualObjects([patch author], @"Jonathon Mah <jonathon@playhaus.org>",
		@"Patch author didn't correctly parse.");
	
	NSCalendarDate *targetDate = [NSCalendarDate dateWithYear:2005
	                                                    month:10
	                                                      day:7
	                                                     hour:14
	                                                   minute:30
	                                                   second:15
	                                                 timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	STAssertEqualObjects([patch date], targetDate,
		@"Patch date didn't correctly parse.");
	STAssertFalse([patch isRollbackPatch],
		@"Rollback flag didn't correctly parse.");
	STAssertEquals([patch type], PWDarcsChangePatchType,
		@"Patch type not correctly set.");
	STAssertEqualObjects([(PWDarcsChangePatch *)patch longComment], @" Some or all of the OgreKit framework's headers have no newlines at the end of\n the file. Enabling this warning triggers it every time one of Patchworks's\n source files includes an OgreKit header. And it's not a big deal anyway.",
		@"Long comment didn't correctly parse.");
	}


- (void)testUncompressedChangePatch
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"02-Change-Uncompressed-NoLongComment"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSError *error = nil;
	PWDarcsPatch *patch = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&error];
	STAssertNotNil(patch,
		@"Uncompressed patch failed to initialize.");
	STAssertNil(error,
		@"Uncompressed patch genereated an error.");
	
	STAssertEqualObjects([patch name], @"Sample patch name",
		@"Patch name didn't correctly parse.");
	STAssertEqualObjects([patch author], @"Faux patch author <user@example.com>",
		@"Patch author didn't correctly parse.");
	
	NSCalendarDate *targetDate = [NSCalendarDate dateWithYear:2005
	                                                    month:9
	                                                      day:30
	                                                     hour:9
	                                                   minute:48
	                                                   second:10
	                                                 timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	STAssertEqualObjects([patch date], targetDate,
		@"Patch date didn't correctly parse.");
	STAssertFalse([patch isRollbackPatch],
		@"Rollback flag didn't correctly parse.");
	STAssertEquals([patch type], PWDarcsChangePatchType,
		@"Patch type not correctly set.");
	STAssertNil([(PWDarcsChangePatch *)patch longComment],
		@"Long comment didn't correctly parse.");
}


- (void)testRollbackChangePatch
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"04-Rollback-Uncompressed-LongComment"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSError *error = nil;
	PWDarcsPatch *patch = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&error];
	STAssertNotNil(patch,
		@"Rollback patch failed to initialize.");
	STAssertNil(error,
		@"Rollback patch genereated an error.");
	
	STAssertEqualObjects([patch name], @"Rolled back patch",
		@"Patch name didn't correctly parse.");
	STAssertEqualObjects([patch author], @"Author <email@unoriginal.com>",
		@"Patch author didn't correctly parse.");
	
	NSCalendarDate *targetDate = [NSCalendarDate dateWithYear:2005
	                                                    month:10
	                                                      day:2
	                                                     hour:17
	                                                   minute:31
	                                                   second:15
	                                                 timeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
	STAssertEqualObjects([patch date], targetDate,
		@"Patch date didn't correctly parse.");
	STAssertTrue([patch isRollbackPatch],
		@"Rollback flag didn't correctly parse.");
	STAssertEquals([patch type], PWDarcsChangePatchType,
		@"Patch type not correctly set.");
	STAssertEqualObjects([(PWDarcsChangePatch *)patch longComment], @" A long comment",
		@"Long comment didn't correctly parse.");
}


- (void)testBadChangePatch
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSArray *badPatchNames = [NSArray arrayWithObjects:@"10-Bad-Change-LongComment", @"11-Very-Bad-Change", nil];
	NSEnumerator *badPatchNameEnumerator = [badPatchNames objectEnumerator];
	NSString *currBadPatchName = nil;
	while (currBadPatchName = [badPatchNameEnumerator nextObject])
	{
		NSString *patchPath = [myBundle pathForResource:currBadPatchName
		                                         ofType:@"gz"
		                                    inDirectory:@"Test Patches"];
		NSError *error = nil;
		PWDarcsPatch *patch = [(PWDarcsPatch *)[PWDarcsPatch alloc] initWithContentsOfURL:[NSURL fileURLWithPath:patchPath] error:&error];
		
		STAssertNil(patch,
					@"Initializing a bad patch should return nil.");
		STAssertNotNil(error,
					   @"Initializing a bad patch should generate an error.");
		STAssertEqualObjects([error domain], PWDarcsPatchErrorDomain,
							 @"Error should be in the PWDarcsPatchErrorDomain.");
		STAssertEquals([error code], PWDarcsPatchParseError,
					   @"Error should be an unknown type error.");
	}
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
