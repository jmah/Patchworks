//
//  PWDarcsPatchTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-03.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsPatchTest.h"
#import "PWDarcsPatch.h"
#import "PWDarcsPatch+TestingMethods.h"


@implementation PWDarcsPatchTest


- (void)testAuthorEmail
{
	NSDictionary *emailByAuthor = [NSDictionary dictionaryWithObjectsAndKeys:
		@"jonathon@playhaus.org", @"Jonathon Mah <jonathon@playhaus.org>",
		@"bracketed@example.org", @"<bracketed@example.org>",
		@"plain@example.org", @"plain@example.org",
		@"first@example.com", @"<first@example.com> <second@example.com>",
		@"mailfirst@domain.com", @"<mailfirst@domain.com> Name Second",
		@"spamproof@domain.com", @"Don't Spam Me <spamproof at domain.com>",
		@"", @"No Address",
		nil];
	NSEnumerator *authorEnum = [emailByAuthor keyEnumerator];
	NSString *author = nil;
	unsigned count = 0u;
	while (author = [authorEnum nextObject])
	{
		count++;
		NSString *name = [NSString stringWithFormat:@"Patch %u", count];
		PWDarcsPatch *patch = [[PWDarcsPatch alloc] initWithName:name
		                                                  author:author
		                                                    date:[NSCalendarDate calendarDate]];
		STAssertEqualObjects([patch authorEmail], [emailByAuthor objectForKey:author],
			@"Author e-mail didn't correctly parse.");
	}
	
	STAssertEquals(count, [emailByAuthor count],
		@"All authors and e-mails weren't processed.");
}


- (void)testAuthorNameOnly
{
	NSDictionary *nameByAuthor = [NSDictionary dictionaryWithObjectsAndKeys:
		@"Jonathon Mah", @"Jonathon Mah <jonathon@playhaus.org>",
		@"bracketed@example.org", @"<bracketed@example.org>",
		@"plain@example.org", @"plain@example.org",
		@"User Name", @"User <nickname@address.org> Name",
		@"Name Second", @"<mailfirst@domain.com> Name Second",
		@"Don't Spam Me", @"Don't Spam Me <spamproof at domain.com>",
		@"No Address", @"No Address",
		nil];
	NSEnumerator *authorEnum = [nameByAuthor keyEnumerator];
	NSString *author = nil;
	unsigned count = 0u;
	while (author = [authorEnum nextObject])
	{
		count++;
		NSString *name = [NSString stringWithFormat:@"Patch %u", count];
		PWDarcsPatch *patch = [[PWDarcsPatch alloc] initWithName:name
		                                                  author:author
		                                                    date:[NSCalendarDate calendarDate]];
		STAssertEqualObjects([patch authorNameOnly], [nameByAuthor objectForKey:author],
			@"Author name didn't correctly parse.");
	}
	
	STAssertEquals(count, [nameByAuthor count],
		@"All authors and names weren't processed.");
}


- (void)testEquality
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"03-Change-Compressed-LongDescription"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSError *error1 = nil;
	PWDarcsPatch *patch1 = [PWDarcsPatch patchWithContentsOfFile:patchPath error:&error1];
	STAssertNotNil(patch1,
				   @"Patch failed to initialize.");
	STAssertNil(error1,
				@"Patch genereated an error.");
	
	NSError *error2 = nil;
	PWDarcsPatch *patch2 = [PWDarcsPatch patchWithContentsOfURL:[NSURL fileURLWithPath:patchPath] error:&error2];
	STAssertNotNil(patch2,
		@"Patch failed to initialize.");
	STAssertNil(error2,
		@"Patch genereated an error.");
	
	STAssertEqualObjects(patch1, patch2,
		@"Identical patches were not equal.");
}


- (void)testBadPatch
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSArray *badPatchNames = [NSArray arrayWithObjects:@"07-Bad", @"08-Bad-Change", @"09-Bad-Tag", nil];
	NSEnumerator *badPatchNameEnumerator = [badPatchNames objectEnumerator];
	NSString *currBadPatchName = nil;
	while (currBadPatchName = [badPatchNameEnumerator nextObject])
	{
		NSString *patchPath = [myBundle pathForResource:currBadPatchName
		                                         ofType:@"gz"
		                                    inDirectory:@"Test Patches"];
		NSError *error = nil;
		PWDarcsPatch *patch = [[PWDarcsPatch alloc] initWithContentsOfURL:[NSURL fileURLWithPath:patchPath] error:&error];
		
		STAssertNil(patch,
			@"Initializing a bad patch should return nil.");
		STAssertNotNil(error,
			@"Initializing a bad patch should generate an error.");
		STAssertEqualObjects([error domain], PWDarcsPatchErrorDomain,
			@"Error should be in the PWDarcsPatchErrorDomain.");
		STAssertEquals([error code], PWDarcsPatchUnknownTypeError,
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
