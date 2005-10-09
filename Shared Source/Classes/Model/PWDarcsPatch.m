//
//  PWDarcsPatch.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsPatch.h"
#import "PWDarcsPatch+ProtectedMethods.h"
#import "PWDarcsChangePatch.h"
#import "PWDarcsTagPatch.h"
#import "NSData+PWzlib.h"
#import <OgreKit/OgreKit.h>


NSString *PWDarcsPatchParseException = @"PWDarcsPatchParseException";


@implementation PWDarcsPatch

#pragma mark Convenience Methods

+ (id)patchWithContentsOfFile:(NSString *)path error:(NSError **)errorPtr
{
	NSData *data = [NSData dataWithContentsOfFile:path options:(unsigned int)NULL error:errorPtr];
	return [[[self alloc] initWithData:data] autorelease];
}


+ (id)patchWithContentsOfURL:(NSURL *)aURL error:(NSError **)errorPtr
{
	NSData *data = [NSData dataWithContentsOfURL:aURL options:(unsigned int)NULL error:errorPtr];
	return [[[self alloc] initWithData:data] autorelease];
}


+ (NSCalendarDate *)calendarDateFromDarcsDateString:(NSString *)dateString // PWDarcsPatch (ProtectedMethods)
{
	NSString *timezoneDateString = [dateString stringByAppendingString:@" +0000"]; // Append UTC timezone
	return [NSCalendarDate dateWithString:timezoneDateString calendarFormat:@"%Y%m%d%H%M%S %z"];
}



#pragma mark Initialization and Deallocation

- (id)initWithData:(NSData *)data // Designated initializer
{
	if (self = [super init])
	{
		// Do not set any instance variables on this object -- 'self' will be
		// deallocated shortly below, and so they will not hold.
		
		NSData *uncompressedData;
		
		// Check if data is compressed by testing the first character
		char firstChar;
		[data getBytes:&firstChar length:1];
		if (firstChar == '[')
			// Data is uncompressed
			uncompressedData = data;
		else
			// Data is compressed
			uncompressedData = [data inflate];
		
		Class concretePatchClass = nil;
		PWDarcsPatch *newPatch = nil; // This will be a concrete subclass of PWDarcsPatch
		
		// Check if the first five characters are '[TAG '
		NSString *patchString = [[NSString alloc] initWithData:uncompressedData encoding:NSUTF8StringEncoding];
		NSString *patchStartString = [patchString substringToIndex:5];
		
		if ([patchStartString isEqualToString:@"[TAG "])
			concretePatchClass = [PWDarcsTagPatch class];
		else if ([patchStartString characterAtIndex:0] == '[')
			concretePatchClass = [PWDarcsChangePatch class];
		
		if (concretePatchClass)
			newPatch = [[concretePatchClass alloc] initWithPatchString:patchString];
		
		[patchString release];
		
		[self release];
		self = newPatch;
	}
	return self;
}


- (void)dealloc
{
	[PW_patchString release];
	[self setName:nil];
	[self setAuthor:nil];
	[self setDate:nil];
	
	[super dealloc];
}



#pragma mark Accessor Methods

- (NSString *)patchString
{
	return PW_patchString;
}


- (void)setName:(NSString *)newName // PWDarcsPatch (ProtectedMethods)
{
	[newName retain];
	[PW_name release];
	PW_name = newName;
}


- (NSString *)name
{
	return PW_name;
}


- (void)setAuthor:(NSString *)newAuthor // PWDarcsPatch (ProtectedMethods)
{
	[newAuthor retain];
	[PW_author release];
	PW_author = newAuthor;
	
	[PW_authorEmail release];
	PW_authorEmail = nil;
}


- (NSString *)author
{
	return PW_author;
}


- (NSString *)authorEmail
{
	if (!PW_authorEmail)
	{
		// Try to parse the e-mail address out of the author field
		OGRegularExpression *emailRegexp = [[OGRegularExpression alloc] initWithString:@"([-\\w+.]{1,64}@[-\\w+.]{1,255})"];
		OGRegularExpressionMatch *match = [emailRegexp matchInString:[self author]];
		if ([match count] > 0)
			PW_authorEmail = [[match lastMatchSubstring] retain];
		[emailRegexp release];
	}
	return PW_authorEmail;
}


- (void)setDate:(NSCalendarDate *)newDate // PWDarcsPatch (ProtectedMethods)
{
	[newDate retain];
	[PW_date release];
	PW_date = newDate;
}


- (NSCalendarDate *)date
{
	return PW_date;
}


- (PWDarcsPatchType)patchType
{
	[NSException raise:NSObjectNotAvailableException format:@"-[PWDarcsPatch patchType] not defined for abstract class"];
	return PWDarcsUnknownPatchType;
}


- (void)setRollbackPatch:(BOOL)isRollbackPatch // PWDarcsPatch (ProtectedMethods)
{
	PW_isRollbackPatch = isRollbackPatch;
}


- (BOOL)isRollbackPatch
{
	return PW_isRollbackPatch;
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
