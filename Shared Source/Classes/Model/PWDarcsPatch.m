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
	[self setName:nil];
	[self setAuthor:nil];
	[self setDate:nil];
	
	[super dealloc];
}



#pragma mark Accessor Methods

- (void)setName:(NSString *)newName // PWDarcsPatch (ProtectedMethods)
{
	[newName retain];
	[_name release];
	_name = newName;
}


- (NSString *)name
{
	return _name;
}


- (void)setAuthor:(NSString *)newAuthor // PWDarcsPatch (ProtectedMethods)
{
	[newAuthor retain];
	[_author release];
	_author = newAuthor;
	
	[_authorEmail release];
	_authorEmail = nil;
}


- (NSString *)author
{
	return _author;
}


- (NSString *)authorEmail
{
	if (!_authorEmail)
	{
		// Try to parse the e-mail address out of the author field
		OGRegularExpression *emailRegexp = [[OGRegularExpression alloc] initWithString:@"([-\\w+.]{1,64}@[-\\w+.]{1,255})"];
		OGRegularExpressionMatch *match = [emailRegexp matchInString:[self author]];
		if ([match count] > 0)
			_authorEmail = [[match lastMatchSubstring] retain];
		[emailRegexp release];
	}
	return _authorEmail;
}


- (void)setDate:(NSCalendarDate *)newDate // PWDarcsPatch (ProtectedMethods)
{
	[newDate retain];
	[_date release];
	_date = newDate;
}


- (NSCalendarDate *)date
{
	return _date;
}


- (PWDarcsPatchType)patchType
{
	[NSException raise:NSObjectNotAvailableException format:@"-[PWDarcsPatch patchType] not defined for abstract class"];
	return PWDarcsUnknownPatchType;
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
