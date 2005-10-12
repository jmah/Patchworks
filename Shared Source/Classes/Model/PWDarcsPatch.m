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


// Cache the e-mail regular expression
static OGRegularExpression *emailRegexp = nil;


@implementation PWDarcsPatch

#pragma mark Convenience Methods

+ (id)patchWithContentsOfFile:(NSString *)path error:(NSError **)outError
{
	return [[[self alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:outError] autorelease];
}


+ (id)patchWithContentsOfURL:(NSURL *)patchURL error:(NSError **)outError
{
	return [[[self alloc] initWithContentsOfURL:patchURL error:outError] autorelease];
}


+ (NSCalendarDate *)calendarDateFromDarcsDateString:(NSString *)dateString // PWDarcsPatch (ProtectedMethods)
{
	NSString *timezoneDateString = [dateString stringByAppendingString:@" +0000"]; // Append UTC timezone
	return [NSCalendarDate dateWithString:timezoneDateString calendarFormat:@"%Y%m%d%H%M%S %z"];
}


+ (NSCalendarDate *)calendarDateFromOldDarcsDateString:(NSString *)dateString // PWDarcsPatch (ProtectedMethods)
{
	return [NSCalendarDate dateWithString:dateString calendarFormat:@"%a %b %e %H:%M:%S %Z %Y"];
}



#pragma mark Initialization and Deallocation

+ (void)initialize
{
	if (!emailRegexp)
		// emailRegexp unescaped pattern: "\s*<?(?<user>[-\w+.]{1,64})(?:@|\s+at\s+)(?<host>[-\w+.]{3,255})>?\s*";
		emailRegexp = [[OGRegularExpression alloc] initWithString:@"\\s*<?(?<user>[-\\w+.]{1,64})(?:@|\\s+at\\s+)(?<host>[-\\w+.]{3,255})>?\\s*"];
}


- (id)initWithContentsOfURL:(NSURL *)patchURL error:(NSError **)outError // Designated initializer
{
	if (self = [super init])
	{
		// Do not set any instance variables on this object -- 'self' will be
		// deallocated shortly below, and so they will not hold.
		
		NSString *currPatchString = nil;
		gzFile gzPatchFile = NULL;
		
		if ([patchURL isFileURL])
		{
			if (![[NSFileManager defaultManager] isReadableFileAtPath:[patchURL path]])
			{
				[self release];
				*outError = [NSError errorWithDomain:NSCocoaErrorDomain
				                                code:NSFileReadNoSuchFileError
				                            userInfo:nil];
				return nil;
			}
			else
			{
				gzPatchFile = gzopen([[patchURL path] cStringUsingEncoding:NSUTF8StringEncoding], "rb");
				
				if (!gzPatchFile)
				{
					[self release];
					*outError = [NSError errorWithDomain:NSCocoaErrorDomain
					                                code:NSFileReadUnknownError
					                            userInfo:nil];
					return nil;
				}
				else
				{
					// Read in the first two lines of the file (as our patch type regexp needs only those two)
					NSMutableString *patchReadingString = [NSMutableString string];
					
					unsigned lineCount = 0;
					char lineBuffer[LINE_BUFFER_LENGH];
					char *line;
					
					while (lineCount < 2)
					{
						line = gzgets(gzPatchFile, lineBuffer, LINE_BUFFER_LENGH);
						if (line == Z_NULL)
						{
							gzclose(gzPatchFile);
							gzPatchFile = nil;
							[self release];
							*outError = [NSError errorWithDomain:NSCocoaErrorDomain
							                                code:NSFileReadUnknownError
							                            userInfo:nil];
							return nil;
						}
						else
						{
							[patchReadingString appendString:[NSString stringWithCString:line encoding:PATCH_STRING_ENCODING]];
							char lastChar = line[strlen(line) - 1];
							if (lastChar == '\n')
								lineCount++;
						}
					}
					
					currPatchString = patchReadingString;
				}
			}
		}
		else
		{
			// If we can't handle the URL (it isn't a file path), hand it off to NSData to worry about
			NSData *data = [NSData dataWithContentsOfURL:patchURL options:0 error:outError];
			if (*outError)
			{
				[self release];
				return nil;
			}
			else
			{
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
				
				currPatchString = [[[NSString alloc] initWithData:uncompressedData encoding:PATCH_STRING_ENCODING] autorelease];
				
			}
		}
		
		// We have at least two lines -- Find the appropriate patch concrete subclass
		Class concretePatchClass = nil;
		PWDarcsPatch *newPatch = nil; // This will be a concrete subclass of PWDarcsPatch
		
		static OGRegularExpression *patchTypeRegexp = nil;
		if (!patchTypeRegexp)
			// patchTypeRegexp unescaped pattern: "^\[(?<is_tag>TAG )?.+?\n.*?\*(?:\*|-)(?:\d{14}|\w{3} \w{3} [\d ]\d \d\d:\d\d:\d\d \w+ \d{4})(?:\] (?: < > )?{?)?$";
			patchTypeRegexp = [[OGRegularExpression alloc] initWithString:@"^\\[(?<is_tag>TAG )?.+?\\n.*?\\*(?:\\*|-)(?:\\d{14}|\\w{3} \\w{3} [\\d ]\\d \\d\\d:\\d\\d:\\d\\d \\w+ \\d{4})(?:\\] (?: < > )?{?)?$"];
		
		OGRegularExpressionMatch *match = [patchTypeRegexp matchInString:currPatchString];
		if (match && [match count] > 0)
		{
			if ([[match substringNamed:@"is_tag"] isEqualToString:@"TAG "])
				concretePatchClass = [PWDarcsTagPatch class];
			else
				concretePatchClass = [PWDarcsChangePatch class];
		}
		
		if (concretePatchClass)
		{
			if (gzPatchFile)
				newPatch = [[concretePatchClass alloc] initWithOpenGzFile:gzPatchFile alreadyReadString:currPatchString error:outError];
			else
				// We have the full patch string already
				newPatch = [[concretePatchClass alloc] initWithFullPatchString:currPatchString error:outError];
		}
		else
			*outError = [NSError errorWithDomain:PWDarcsPatchErrorDomain
			                                code:PWDarcsPatchUnknownTypeError
			                            userInfo:nil];
		
		[self release];
		self = newPatch;
	}
	return self;
}


- (void)dealloc
{
	if (PW_gzPatchFile)
	{
		int closeErrorCode = gzclose(PW_gzPatchFile);
		PW_gzPatchFile = nil;
		NSAssert1(closeErrorCode == Z_OK, @"Gzip file had error on close (%d)", closeErrorCode);
	}
	
	if (PW_isFullPatchRead)
	{
		[PW_fullPatchString release];
		PW_fullPatchString = nil;
	}
	else
	{
		[PW_currPatchString release];
		PW_currPatchString = nil;
	}
	
	[PW_fullPatchString release];
	PW_fullPatchString = nil;
	
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
	if (!PW_isFullPatchRead)
	{
		NSMutableData *remainingData = [[NSMutableData alloc] initWithCapacity:FULL_BUFFER_LENGTH];
		while (!gzeof(PW_gzPatchFile))
		{
			char readBuffer[FULL_BUFFER_LENGTH];
			int byteCount = gzread(PW_gzPatchFile, readBuffer, FULL_BUFFER_LENGTH);
			NSAssert(byteCount != -1, @"Error reading patch");
			if (byteCount > 0)
				[remainingData appendBytes:readBuffer length:byteCount];
		}
		gzclose(PW_gzPatchFile);
		PW_gzPatchFile = nil;
		
		NSString *remainingPatchString = [[NSString alloc] initWithData:remainingData encoding:PATCH_STRING_ENCODING];
		[remainingData release];
		
		PW_fullPatchString = [[PW_currPatchString stringByAppendingString:remainingPatchString] retain];
		[remainingPatchString release];
		[PW_currPatchString release];
		PW_currPatchString = nil;
		
		PW_isFullPatchRead = YES;
	}
	
	return PW_fullPatchString;
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
		OGRegularExpressionMatch *match = [emailRegexp matchInString:[self author]];
		if ([match count] > 0)
			// The following format string is unfortunate. It represents:
			// [string]@[string]
			PW_authorEmail = [[NSString alloc] initWithFormat:@"%@@%@", [match substringNamed:@"user"], [match substringNamed:@"host"]];
		else
			PW_authorEmail = [[NSString alloc] init];
	}
	return PW_authorEmail;
}


- (NSString *)authorNameOnly
{
	// Cache the trimming character set
	static NSMutableCharacterSet *trimCharacterSet = nil;
	if (!trimCharacterSet)
	{
		trimCharacterSet = [[NSCharacterSet whitespaceCharacterSet] mutableCopy];
		[trimCharacterSet addCharactersInString:@"<>"];
	}
	
	if (!PW_authorNameOnly)
	{
		// Try to parse only the author name (excluding the e-mail address) out of the author field
		OGRegularExpressionMatch *match = [emailRegexp matchInString:[self author]];
		NSString *prematchString = ([match prematchString] ? [match prematchString] : @"");
		NSString *postmatchString = ([match postmatchString] ? [match postmatchString] : @"");
		NSString *author = [[NSString stringWithFormat:@"%@ %@", prematchString, postmatchString] stringByTrimmingCharactersInSet:trimCharacterSet];
		
		if ([author length] > 0)
			PW_authorNameOnly = [author retain];
		else
			PW_authorNameOnly = [[[self author] stringByTrimmingCharactersInSet:trimCharacterSet] retain];
	}
	
	return PW_authorNameOnly;
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
