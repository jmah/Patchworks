//
//  PWStringReader.m
//  Patchworks
//
//  Created by Jonathon Mah on 2006-01-15.
//  Copyright 2006 Playhaus. All rights reserved.
//

#import "PWStringReader.h"


@implementation PWStringReader

#pragma mark Initialization and Deallocation

- (id)initWithString:(NSString *)string // Designated initializer
{
	if (self = [super init])
	{
		// We retain instead of copying for sake of efficiency
		PW_string = [string retain];
		
		PW_cachedIndex = 0;
		PW_currReadIndex = 0;
		PW_hasRewoundLine = NO;
		PW_lastLineLength = NO;
		PW_isLastLineInCache = YES;
	}
	return self;
}


- (void)dealloc
{
	[PW_string release];
	PW_string = nil;
	
	[super dealloc];
}



#pragma mark Reading <PWReader>

- (BOOL)isEntireContentRead // <PWReader>
{
	return (!PW_hasRewoundLine && (PW_cachedIndex == [PW_string length]));
}


- (NSString *)cachedContent // <PWReader>
{
	return [PW_string substringToIndex:PW_cachedIndex];
}


- (NSString *)fullContent // <PWReader>
{
	PW_currReadIndex = [PW_string length];
	PW_cachedIndex = PW_currReadIndex;
	PW_hasRewoundLine = NO;
	PW_lastLineLength = 0;
	
	return PW_string;
}


- (NSString *)readNextLine:(BOOL)cacheText // <PWReader>
{
	if ([self isEntireContentRead])
		return nil;
	
	NSString *nextLine = nil;
	
	if (PW_hasRewoundLine)
	{
		NSRange lastLineRange = NSMakeRange(PW_currReadIndex - PW_lastLineLength, PW_lastLineLength);
		nextLine = [PW_string substringWithRange:lastLineRange];
		PW_hasRewoundLine = NO;
		if (cacheText)
			PW_cachedIndex = PW_currReadIndex;
	}
	else
	{
		NSRange nextLineRange = [PW_string lineRangeForRange:NSMakeRange(PW_currReadIndex, 1)];
		nextLine = [PW_string substringWithRange:nextLineRange];
		PW_lastLineLength = [nextLine length];
		PW_currReadIndex += PW_lastLineLength;
	}
	
	if (cacheText)
		[self cacheUpToIndex:[self currentIndex]];
	
	return nextLine;
}


- (unsigned int)currentIndex // <PWReader>
{
	return (PW_currReadIndex - (PW_hasRewoundLine ? PW_lastLineLength : 0));
}


- (void)cacheUpToIndex:(unsigned int)index // <PWReader>
{
	if (index > PW_cachedIndex)
	{
		NSAssert(index <= [PW_string length], @"index must not be beyond the end of the content");
		PW_cachedIndex = index;
	}
}


- (BOOL)rewindLine // <PWReader>
{
	BOOL success = NO;
	
	if (!PW_hasRewoundLine && (PW_currReadIndex > 0))
	{
		PW_hasRewoundLine = YES;
		if (PW_isLastLineInCache)
			PW_cachedIndex -= PW_lastLineLength;
		success = YES;
	}
	
	return success;
}


@end
