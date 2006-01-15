//
//  PWStringReaderTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2006-01-15.
//  Copyright 2006 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWStringReaderTest.h"
#import "NSData+PWzlib.h"
#import "PWStringReader.h"


@implementation PWStringReaderTest


- (void)testReadingByLine
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *filePath = [myBundle pathForResource:@"Test Gzip File"
	                                        ofType:@"gz"
	                                   inDirectory:nil];
	
	NSData *inflatedFile = [[NSData dataWithContentsOfFile:filePath] inflate];
	NSString *string = [[NSString alloc] initWithData:inflatedFile encoding:NSASCIIStringEncoding];
	PWStringReader *reader = [[PWStringReader alloc] initWithString:string];
	[string release];
	
	STAssertNotNil(reader,
		@"Failed to create string reader.");
	
	// Test cached reading
	STAssertFalse([reader isEntireContentRead],
		@"String reader reported full content read.");
	STAssertEqualObjects([reader readNextLine:YES], @"This is a test file compressed with gzip.\n",
		@"Failed to read cached line.");
	STAssertEqualObjects([reader readNextLine:YES], @"Line 2\n",
		@"Failed to read cached line.");
	STAssertFalse([reader isEntireContentRead],
		@"String reader reported full content read.");
	
	STAssertEqualObjects([reader cachedContent], @"This is a test file compressed with gzip.\nLine 2\n",
		@"Cached content was not as read.");
	
	STAssertTrue([reader rewindLine],
		@"Rewinding line failed.");
	STAssertEqualObjects([reader cachedContent], @"This is a test file compressed with gzip.\n",
		@"Cached contents did not reflect rewind.");
	
	STAssertEqualObjects([reader readNextLine:NO], @"Line 2\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([reader cachedContent], @"This is a test file compressed with gzip.\n",
		@"Cached contents did not reflect uncached read.");
	
	STAssertEqualObjects([reader readNextLine:NO], @"Line 3\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([reader readNextLine:NO], @"Line 4\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([reader readNextLine:NO], @"Line 5\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([reader readNextLine:NO], @"Line 6\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([reader readNextLine:NO], @"Last line\n",
		@"Failed to read uncached line.");
	
	STAssertFalse([reader isEntireContentRead],
		@"String reader reported full content read.");
	STAssertTrue([reader rewindLine],
		@"String reader failed to rewind line.");
	STAssertEqualObjects([reader readNextLine:YES], @"Last line\n",
		@"Failed to read cached line.");
	
	STAssertTrue([reader isEntireContentRead],
		@"String reader reported full content as not read.");
	
	[reader release];
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
