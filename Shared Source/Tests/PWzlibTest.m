//
//  PWzlibTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWzlibTest.h"
#import "NSData+PWzlib.h"


@implementation PWzlibTest


- (void)testDeflateInflate
{
	// Create a reasonably long string (longer than 16KB) to test deflate and inflate
	NSMutableString *sourceString = [NSMutableString string];
	unsigned i, sum = 0;
	for (i = 0; i < 2000; i++)
	{
		sum += i;
		[sourceString appendFormat:@"This is line %u, and the current sum is %u.\n", i, sum];
	}
	
	NSData *originalData = [sourceString dataUsingEncoding:NSISOLatin1StringEncoding];
	// originalData has length of 98825 bytes
	
	STAssertFalse([originalData isZlibCompressed],
		@"Uncompressed data incorrectly reported as compressed.");
	
	// Deflate the data
	NSData *deflatedData = [originalData deflate];
	STAssertNotNil(deflatedData, @"Deflated data was nil.");
	STAssertTrue([deflatedData isZlibCompressed],
		@"Deflated data incorrectly reported as uncompressed.");
	
	
	// Inflate the data
	NSData *inflatedData = [deflatedData inflate];
	STAssertNotNil(inflatedData, @"Inflated data was nil.");
	STAssertFalse([inflatedData isZlibCompressed],
		@"Inflated data incorrectly reported as compressed.");
	STAssertEquals([inflatedData length], [originalData length], @"Inflated data differed in length from original data.");
	STAssertEqualObjects(inflatedData, originalData, @"Inflated data was not equal to original data.");
}


- (void)testCompressedPatchInflate
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *patchPath = [myBundle pathForResource:@"01-Change-Compressed-NoLongComment"
	                                         ofType:@"gz"
	                                    inDirectory:@"Test Patches"];
	NSString *uncompressedPath = [myBundle pathForResource:@"01-Change-Compressed-NoLongComment"
	                                                ofType:@"txt"
	                                           inDirectory:@"Test Patches"];
	NSData *compressedPatch = [NSData dataWithContentsOfFile:patchPath];
	STAssertNotNil(compressedPatch, @"Failed to load compressed patch.");
	
	NSData *inflatedPatch = [compressedPatch inflate];
	STAssertNotNil(inflatedPatch, @"Failed to inflate patch.");
	
	NSString *inflatedContents = [[[NSString alloc] initWithData:inflatedPatch encoding:NSASCIIStringEncoding] autorelease];
	NSString *realContents = [NSString stringWithContentsOfFile:uncompressedPath
	                                                   encoding:NSASCIIStringEncoding
	                                                      error:nil];
	
	STAssertEqualObjects(inflatedContents, realContents, @"Patch was not inflated correctly.");
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
