//
//  PWzlibTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright 2005 Playhaus. All rights reserved.
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
	
	NSData *originalData = [sourceString dataUsingEncoding:NSUTF8StringEncoding];
	// originalData has length of 98825 bytes
	
	
	// Deflate the data
	NSData *deflatedData = [originalData deflate];
	STAssertNotNil(deflatedData, @"Deflated data was nil.");
	// STAssertTrue([deflatedData length] <= [originalData length], @"Deflated data was larger than original data");
	
	
	// Inflate the data
	NSData *inflatedData = [deflatedData inflate];
	STAssertNotNil(inflatedData, @"Inflated data was nil.");
	STAssertEquals([inflatedData length], [originalData length], @"Inflated data differed in length from original data.");
	STAssertEqualObjects(inflatedData, originalData, @"Inflated data was not equal to original data.");
}


@end
