//
//  NSData+PWzlib.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "NSData+PWzlib.h"
#import <zlib.h>


@implementation NSData (PWzlib)

#pragma mark zlib Extensions

- (NSData *)inflate
{
	// Based on public-domain code from <http://cocoadev.com/index.pl?NSDataCategory>
	
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
	
	if (inflateInit2(&strm, (15 + 32)) == Z_OK)
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
	// Based on public-domain code from <http://cocoadev.com/index.pl?NSDataCategory>
	
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
