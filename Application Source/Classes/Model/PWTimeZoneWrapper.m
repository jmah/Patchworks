//
//  PWTimeZoneWrapper.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-09.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWTimeZoneWrapper.h"


static NSMutableDictionary *existingWrappers = nil; // Initialized in +initialize


@implementation PWTimeZoneWrapper


#pragma mark Convenience Methods

+ (id)timeZoneWrapperWithTimeZone:(NSTimeZone *)timeZone
{
	return [[[self alloc] initWithTimeZone:timeZone] autorelease];
}


+ (id)timeZoneWrapperWithName:(NSString *)name
{
	return [[[self alloc] initWithName:name] autorelease];
}


+ (NSArray *)knownTimeZoneWrappers
{
	NSEnumerator *nameEnum = [[NSTimeZone knownTimeZoneNames] objectEnumerator];
	NSString *currName = nil;
	while (currName = [nameEnum nextObject])
	{
		// Avoid possible bug in NSTimeZone
		if ([currName isEqualToString:@"zone.tab"])
			break;
		
		NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:currName];
		if (![existingWrappers objectForKey:timeZone])
			[existingWrappers setObject:[self timeZoneWrapperWithTimeZone:timeZone] forKey:timeZone];
	}
	
	return [existingWrappers allValues];
}



#pragma mark Initialization and Deallocation

+ (void)initialize
{
	if ([self class] == [PWTimeZoneWrapper class])
	{
		existingWrappers = [[NSMutableDictionary alloc] init];
	}
}


- (id)initWithTimeZone:(NSTimeZone *)timeZone // Designated initializer
{
	if (self = [super init])
	{
		PWTimeZoneWrapper *existingWrapper = [existingWrappers objectForKey:timeZone];
		if (existingWrapper)
		{
			[self release];
			self = existingWrapper;
		}
		else
		{
			// Create the wrapper (self) and add it to the existing wrappers
			PW_timeZone = [timeZone retain];
			[existingWrappers setObject:self forKey:timeZone];
		}
	}
	return self;
}


- (id)initWithName:(NSString *)name
{
	return [self initWithTimeZone:[NSTimeZone timeZoneWithName:name]];
}


- (void)dealloc
{
	[PW_timeZone release];
	
	[super dealloc];
}



#pragma mark Accessor Methods

- (NSTimeZone *)timeZone
{
	return PW_timeZone;
}


- (NSString *)abbreviation
{
	return [[self timeZone] abbreviation];
}


- (NSString *)abbreviationForDate:(NSDate *)date
{
	return [[self timeZone] abbreviationForDate:date];
}


- (NSString *)name
{
	return [[self timeZone] name];
}


- (int)secondsFromGMT
{
	return [[self timeZone] secondsFromGMT];
}


- (int)secondsFromGMTForDate:(NSDate *)date
{
	return [[self timeZone] secondsFromGMTForDate:date];
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
