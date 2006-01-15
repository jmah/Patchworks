//
//  PWGzipFileReaderTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2006-01-10.
//  Copyright 2006 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWGzipFileReaderTest.h"
#import "PWGzipFileReader.h"


@implementation PWGzipFileReaderTest


- (void)testFullReading
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"01-Change-Compressed-NoLongComment"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSString *uncompressedPath = [myBundle pathForResource:@"01-Change-Compressed-NoLongComment"
	                                                ofType:@"txt"
	                                           inDirectory:@"Test Patches"];
	NSError *error = nil;
	PWGzipFileReader *compressedPatch = [[PWGzipFileReader alloc] initWithContentsOfFile:patchPath encoding:NSASCIIStringEncoding error:&error];
	STAssertNotNil(compressedPatch,
		@"Failed to open gzip file.");
	STAssertNil(error,
		@"Gzip file generated an error.");
	STAssertFalse([compressedPatch isEntireContentRead],
		@"Gzip file reported full content as read.");
	
	NSString *realContent = [NSString stringWithContentsOfFile:uncompressedPath
	                                                  encoding:NSASCIIStringEncoding
	                                                     error:nil];
	
	STAssertEqualObjects([compressedPatch fullContent], realContent,
		@"Gzip file was not inflated correctly.");
	STAssertTrue([compressedPatch isEntireContentRead],
		@"Gzip file reported full content as not read.");
	STAssertEqualObjects([compressedPatch fullContent], [compressedPatch cachedContent],
		@"Gzip file cached content was not full content.");
	
	[compressedPatch release];
}


- (void)testReadingByLine
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *filePath = [myBundle pathForResource:@"Test Gzip File"
	                                        ofType:@"gz"
	                                   inDirectory:nil];
	NSError *error = nil;
	PWGzipFileReader *gzipFile = [[PWGzipFileReader alloc] initWithContentsOfFile:filePath encoding:NSASCIIStringEncoding error:&error];
	STAssertNotNil(gzipFile,
		@"Failed to open gzip file.");
	STAssertNil(error,
		@"Gzip file generated an error.");
	
	// Test cached reading
	STAssertFalse([gzipFile isEntireContentRead],
		@"Gzip file reported full content read.");
	STAssertEqualObjects([gzipFile readNextLine:YES], @"This is a test file compressed with gzip.\n",
		@"Failed to read cached line.");
	STAssertEqualObjects([gzipFile readNextLine:YES], @"Line 2\n",
		@"Failed to read cached line.");
	STAssertFalse([gzipFile isEntireContentRead],
		@"Gzip file reported full content read.");
	
	STAssertEqualObjects([gzipFile cachedContent], @"This is a test file compressed with gzip.\nLine 2\n",
		@"Gzip cached content was not as read.");
	
	STAssertTrue([gzipFile rewindLine],
		@"Rewinding line failed.");
	STAssertEqualObjects([gzipFile cachedContent], @"This is a test file compressed with gzip.\n",
		@"Cached contents did not reflect rewind.");
	
	STAssertEqualObjects([gzipFile readNextLine:NO], @"Line 2\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([gzipFile cachedContent], @"This is a test file compressed with gzip.\n",
		@"Cached contents did not reflect uncached read.");
	
	STAssertEqualObjects([gzipFile readNextLine:NO], @"Line 3\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([gzipFile readNextLine:NO], @"Line 4\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([gzipFile readNextLine:NO], @"Line 5\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([gzipFile readNextLine:NO], @"Line 6\n",
		@"Failed to read uncached line.");
	STAssertEqualObjects([gzipFile readNextLine:NO], @"Last line\n",
		@"Failed to read uncached line.");
	
	STAssertFalse([gzipFile isEntireContentRead],
		@"Gzip file reported full content read.");
	STAssertTrue([gzipFile rewindLine],
		@"Gzip file failed to rewind line.");
	STAssertEqualObjects([gzipFile readNextLine:YES], @"Last line\n",
		@"Failed to read cached line.");
	
	STAssertTrue([gzipFile isEntireContentRead],
		@"Gzip file reported full content as not read.");
	
	[gzipFile release];
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
