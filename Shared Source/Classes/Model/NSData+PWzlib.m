//
//  NSData+PWzlib.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright 2005 Playhaus. All rights reserved.
//

#import "NSData+PWzlib.h"
#import <zlib.h>


@implementation NSData (PWzlib)

#pragma mark zlib Extensions

- (NSData *)inflate
{
	// Based on code from <http://cocoadev.com/index.pl?NSDataCategory>
	
	if ([self length] == 0)
		return [[self retain] autorelease];
	
	
	unsigned fullLength = [self length];
	unsigned halfLength = fullLength / 2;
	
	NSMutableData *decompressedData = nil;
	
	z_stream strm;
	strm.next_in = (Bytef *)[self bytes];
	strm.avail_in = fullLength;
	strm.total_out = 0;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	
	if (inflateInit(&strm) == Z_OK)
	{
		decompressedData = [NSMutableData dataWithLength:(fullLength + halfLength)];
		BOOL done = NO;
		int status;
		
		while (!done)
		{
			// Make sure we have enough room
			if (strm.total_out >= [decompressedData length])
				[decompressedData increaseLengthBy:halfLength];
			
			strm.next_out = [decompressedData mutableBytes] + strm.total_out;
			strm.avail_out = [decompressedData length] - strm.total_out;
			
			// Inflate another chunk
			status = inflate(&strm, Z_SYNC_FLUSH);
			
			if (status == Z_STREAM_END)
			{
				done = YES;
				[decompressedData setLength:strm.total_out];
			}
			else if (status != Z_OK)
			{
				done = YES;
				decompressedData = nil;
			}
		}
		
		if (inflateEnd(&strm) != Z_OK)
			decompressedData = nil;
	}
	return decompressedData;
}


- (NSData *)deflate
{
	// Based on code from <http://cocoadev.com/index.pl?NSDataCategory>
	
	if ([self length] == 0)
		return [[self retain] autorelease];
	
	
	z_stream strm;
	strm.zalloc = Z_NULL;
	strm.zfree = Z_NULL;
	strm.opaque = Z_NULL;
	strm.total_out = 0;
	strm.next_in=(Bytef *)[self bytes];
	strm.avail_in = [self length];
	
	NSMutableData *compressedData = nil;
	
	if (deflateInit(&strm, Z_DEFAULT_COMPRESSION) == Z_OK)
	{
		compressedData = [NSMutableData dataWithLength:16384]; // 16K chuncks for expansion
		BOOL done = NO;
		int status;
		
		while (!done)
		{
			// Make sure we have enough room
			if (strm.total_out >= [compressedData length])
				[compressedData increaseLengthBy:16384];
			
			strm.next_out = [compressedData mutableBytes] + strm.total_out;
			strm.avail_out = [compressedData length] - strm.total_out;
			
			// Deflat another chunk
			status = deflate(&strm, Z_FINISH);
			
			if (status == Z_STREAM_END)
			{
				done = YES;
				[compressedData setLength:strm.total_out];
			}
			else if (status != Z_OK)
			{
				done = YES;
				compressedData = nil;
			}
		}
		
		if (deflateEnd(&strm) != Z_OK)
			compressedData = nil;
	}
	return compressedData;
}


@end
