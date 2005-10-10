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


NSString *PWDarcsPatchErrorDomain = @"PWDarcsPatchErrorDomain";


@implementation PWDarcsPatch

#pragma mark Convenience Methods

+ (id)patchWithContentsOfFile:(NSString *)path error:(NSError **)outError
{
	NSData *data = [NSData dataWithContentsOfFile:path options:(unsigned int)NULL error:outError];
	if (*outError != nil)
		return nil;
	else
		return [[[self alloc] initWithData:data error:outError] autorelease];
}


+ (id)patchWithContentsOfURL:(NSURL *)aURL error:(NSError **)outError
{
	NSData *data = [NSData dataWithContentsOfURL:aURL options:(unsigned int)NULL error:outError];
	if (*outError != nil)
		return nil;
	else
		return [[[self alloc] initWithData:data error:outError] autorelease];
}


+ (NSCalendarDate *)calendarDateFromDarcsDateString:(NSString *)dateString // PWDarcsPatch (ProtectedMethods)
{
	NSString *timezoneDateString = [dateString stringByAppendingString:@" +0000"]; // Append UTC timezone
	return [NSCalendarDate dateWithString:timezoneDateString calendarFormat:@"%Y%m%d%H%M%S %z"];
}



#pragma mark Initialization and Deallocation

- (id)initWithData:(NSData *)data error:(NSError **)outError // Designated initializer
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
		static OGRegularExpression *patchTypeRegexp = nil;
		if (!patchTypeRegexp)
			// patchTypeRegexp unescaped pattern: "^\[(?<is_tag>TAG )?.+\n.*\*(?:\*|-)\d{14}(?:\] \{?)?$";
			patchTypeRegexp = [[OGRegularExpression alloc] initWithString:@"^\\[(?<is_tag>TAG )?.+\\n.*\\*(?:\\*|-)\\d{14}(?:\\] \\{?)?$"
			                                                      options:OgreCaptureGroupOption
			                                                       syntax:OgreRubySyntax
			                                              escapeCharacter:OgreBackslashCharacter];
		
		NSString *patchString = [[NSString alloc] initWithData:uncompressedData encoding:NSUTF8StringEncoding];
		OGRegularExpressionMatch *match = [patchTypeRegexp matchInString:patchString];
		if ([match count] > 0)
		{
			if ([[match substringNamed:@"is_tag"] isEqualToString:@"TAG "])
				concretePatchClass = [PWDarcsTagPatch class];
			else
				concretePatchClass = [PWDarcsChangePatch class];
		}
		
		if (concretePatchClass)
			newPatch = [[concretePatchClass alloc] initWithPatchString:patchString error:outError];
		else
			*outError = [NSError errorWithDomain:PWDarcsPatchErrorDomain
			                                code:PWDarcsPatchUnknownTypeError
			                            userInfo:nil];
		
		[patchString release];
		
		[self release];
		self = newPatch;
	}
	return self;
}


- (void)dealloc
{
	[PW_patchString release];
	PW_patchString = nil;
	
	[self setName:nil];
	[self setAuthor:nil];
	[self setDate:nil];
	
	[super dealloc];
}



#pragma mark Comparison

- (BOOL)isEqual:(id)otherObject
{
	BOOL equal = NO;
	
	if ([otherObject isKindOfClass:[PWDarcsPatch class]])
	{
		equal = [[(PWDarcsPatch *)otherObject patchString] isEqualToString:[self patchString]];
	}
	
	return equal;
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
	// Cache the e-mail regular expression
	static OGRegularExpression *emailRegexp = nil;
	if (!emailRegexp)
		emailRegexp = [[OGRegularExpression alloc] initWithString:@"([-\\w+.]{1,64}@[-\\w+.]{1,255})"];
	
	if (!PW_authorEmail)
	{
		// Try to parse the e-mail address out of the author field
		OGRegularExpressionMatch *match = [emailRegexp matchInString:[self author]];
		if ([match count] > 0)
			PW_authorEmail = [[match lastMatchSubstring] retain];
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


- (PWDarcsPatchType)type
{
	[NSException raise:NSObjectNotAvailableException format:@"-[PWDarcsPatch type] not defined for abstract class"];
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
