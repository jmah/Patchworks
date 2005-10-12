//
//  PWDarcsChangePatch.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsChangePatch.h"
#import "PWDarcsPatch+ProtectedMethods.h"
#import <OgreKit/OgreKit.h>


@interface PWDarcsChangePatch (PrivateMethods)

#pragma mark Accessor Methods
- (void)setLongDescription:(NSString *)newLongDescription;

@end


/*
 * Change Patch Formats
 * ====================
 * 
 * No long comment
 * ---------------
 * [Patch name
 * author**1999010816123000] {
 * (hunks)
 * }
 * 
 * With long comment
 * -----------------
 * [Patch name
 * author**1999010816123000
 *  long description indented by a space
 * ] {
 * (hunks)
 * }
 * 
 * Rollback patch
 * --------------
 * [Patch name
 * author*-1999010816123000
 *  long description indented by a space
 * ] {
 * (inverse hunks)
 * }
 */


@implementation PWDarcsChangePatch

#pragma mark Initialization and Deallocation

- (id)initWithOpenGzFile:(gzFile)gzPatchFile alreadyReadString:(NSString *)currPatchString error:(NSError **)outError // Designated initializer
{
	if (self = [super init])
	{
		// Initialize instance variables
		PW_longDescription = nil;
		PW_gzPatchFile = gzPatchFile;
		PW_isFullPatchRead = (PW_gzPatchFile ? gzeof(PW_gzPatchFile) : YES);
		
		if (PW_isFullPatchRead)
		{
			if (PW_gzPatchFile)
			{
				int closeError = gzclose(PW_gzPatchFile);
				PW_gzPatchFile = nil;
				NSAssert(closeError == Z_OK, @"Patch file failed to close");
			}
			
			PW_fullPatchString = [currPatchString retain];
		}
		else
			PW_currPatchString = [currPatchString mutableCopy];
		
		
		// Parse patch
		// Cache the patch regular expression
		static OGRegularExpression *patchRegexp = nil;
		if (!patchRegexp)
			// patchRegexp unescaped pattern: "^\[(?<name>.*?)\n(?<author>.*?)\*(?<rollback_flag>\*|-)((?<new_date>\d{14})|(?<old_date>\w{3} \w{3} [\d ]\d \d\d:\d\d:\d\d \w+ \d{4}))(?:] (?: < > )?{|\n(?<long_description>(?:.|\n)*?)\n?\] (?: < > )?{$)";
			patchRegexp = [[OGRegularExpression alloc] initWithString:@"^\\[(?<name>.*?)\\n(?<author>.*?)\\*(?<rollback_flag>\\*|-)((?<new_date>\\d{14})|(?<old_date>\\w{3} \\w{3} [\\d ]\\d \\d\\d:\\d\\d:\\d\\d \\w+ \\d{4}))(?:] (?: < > )?{|\\n(?<long_description>(?:.|\\n)*?)\\n?\\] (?: < > )?{$)"];
		
		OGRegularExpressionMatch *match = nil;
		
		BOOL doesMatch = NO, definitelyDoesNotMatch = NO;
		do
		{
			if (PW_isFullPatchRead)
			{
				match = [patchRegexp matchInString:PW_fullPatchString];
				doesMatch = ([match count] > 0);
				definitelyDoesNotMatch = !doesMatch;
			}
			else
			{
				// Check if the current patch string matches. If it doesn't, read some more and try again.
				match = [patchRegexp matchInString:PW_currPatchString];
				doesMatch = ([match count] > 0);
				if (!doesMatch)
				{
					// Read in the next line of the patch. If we read "] {\n" then we know this patch will definitely never match the regexp.
					char lineBuffer[LINE_BUFFER_LENGH];
					char *line = gzgets(PW_gzPatchFile, lineBuffer, LINE_BUFFER_LENGH);
					if (line == Z_NULL)
					{
						// This is contrary to the zlib.h file, but this can often signal the end-of-file, so we need to check it here
						if (gzeof(PW_gzPatchFile))
						{
							PW_isFullPatchRead = YES;
							int closeError = gzclose(PW_gzPatchFile);
							NSAssert(closeError == Z_OK, @"Patch file failed to close");
							PW_gzPatchFile = nil;
							
							PW_fullPatchString = [currPatchString retain];
							[PW_currPatchString release];
							PW_currPatchString = nil;
						}
						else
						{
							PW_gzPatchFile = nil;
							[self release];
							*outError = [NSError errorWithDomain:NSCocoaErrorDomain
							                                code:NSFileReadUnknownError
							                            userInfo:nil];
							return nil;
						}
					}
					else
					{
						NSString *newLine = [NSString stringWithCString:line encoding:PATCH_STRING_ENCODING];
						[PW_currPatchString appendString:newLine];
						if ([newLine isEqualToString:@"] {\n"])
						{
							match = [patchRegexp matchInString:PW_currPatchString];
							doesMatch = ([match count] > 0);
							definitelyDoesNotMatch = !doesMatch;
						}
						
						// Since we just read in a chunk, check if we reached the end of file
						if (gzeof(PW_gzPatchFile))
						{
							PW_isFullPatchRead = YES;
							int closeError = gzclose(PW_gzPatchFile);
							NSAssert(closeError == Z_OK, @"Patch file failed to close");
							PW_gzPatchFile = nil;
							
							PW_fullPatchString = [currPatchString retain];
							[PW_currPatchString release];
							PW_currPatchString = nil;
						}
					}
				}
			}
		} while (!doesMatch && !definitelyDoesNotMatch);
		
		
		if (!match || [match count] == 0)
		{
			[self release];
			self = nil;
			*outError = [NSError errorWithDomain:PWDarcsPatchErrorDomain
			                                code:PWDarcsPatchParseError
			                            userInfo:nil];
		}
		else
		{
			[self setName:[match substringNamed:@"name"]];
			[self setAuthor:[match substringNamed:@"author"]];
			if ([match substringNamed:@"old_date"])
				[self setDate:[[self class] calendarDateFromOldDarcsDateString:[match substringNamed:@"old_date"]]];
			else
				[self setDate:[[self class] calendarDateFromDarcsDateString:[match substringNamed:@"new_date"]]];
			[self setLongDescription:[match substringNamed:@"long_description"]]; // Can be nil
			
			NSString *rollbackFlag = [match substringNamed:@"rollback_flag"];
			if ([rollbackFlag isEqualToString:@"*"])
				[self setRollbackPatch:NO];
			else if ([rollbackFlag isEqualToString:@"-"])
				[self setRollbackPatch:YES];
			else
				[NSException raise:NSInternalInconsistencyException
				            format:@"Patch regular expression matched patch string, but rollback_flag was '%@' instead of '*' or '-'", rollbackFlag];
		}
	}
	else
		if (gzPatchFile)
			gzclose(gzPatchFile);
	return self;
}


- (id)initWithFullPatchString:(NSString *)patchString error:(NSError **)outError
{
	return [self initWithOpenGzFile:NULL alreadyReadString:patchString error:outError];
}


- (void)dealloc
{
	[PW_cleanedLongDescription release];
	PW_cleanedLongDescription = nil;
	
	[self setLongDescription:nil];
	
	[super dealloc];
}



#pragma mark Accessor Methods

- (void)setLongDescription:(NSString *)newLongDescription // PWDarcsChangePatch (PrivateMethods)
{
	[newLongDescription retain];
	[PW_longDescription release];
	PW_longDescription = newLongDescription;
}


- (NSString *)longDescription
{
	return PW_longDescription;
}


- (NSString *)cleanedLongDescription
{
	if (!PW_cleanedLongDescription && [self longDescription])
	{
		// Remove newlines from the long description (in a mostly sensible manner)
		OGRegularExpression *continuingLineRegexp = [OGRegularExpression regularExpressionWithString:@"([^:\\\\])\\n ([^-\\s\\*+])"];
		OGReplaceExpression *replaceExp = [OGReplaceExpression replaceExpressionWithString:@"\\`\\1 \\2\\'"];
		OGRegularExpressionMatch *match = nil;
		NSString *cleanedLongDescription = [self longDescription];
		
		do
		{
			match = [continuingLineRegexp matchInString:cleanedLongDescription];
			if (match && ([match count] > 0))
				cleanedLongDescription = [replaceExp replaceMatchedStringOf:match];
		} while (match && ([match count] > 0));
		
		// Remove initial space
		PW_cleanedLongDescription = [[cleanedLongDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] retain];
	}
	
	return PW_longDescription;
}


- (PWDarcsPatchType)type // PWDarcsPatch
{
	return PWDarcsChangePatchType;
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
