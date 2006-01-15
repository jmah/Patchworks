//
//  PWDarcsTagPatch.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsTagPatch.h"
#import "PWDarcsPatch+PWProtectedMethods.h"
#import "PWGzipFileReader.h"
#import <OgreKit/OgreKit.h>


@interface PWDarcsTagPatch (PWPrivateMethods)

#pragma mark Initialization and Deallocation
- (id)commonInitError:(NSError **)outError;

@end


/*
 * Tag Patch Formats
 * =================
 * 
 * Normal tag (note spaces after ']' characters)
 * ----------
 * [TAG Tag name
 * author**1999010816123000] 
 * <
 * [First change patch
 * author**20051008080552] 
 * [Second change patch
 * author**20051008080552
 *  Long comment
 *  indented by one space
 * ] 
 * (other patches)
 * [TAG Previous tag if any
 * author**20051008080552] 
 * > {
 * }
 * 
 * Rollback tag
 * ------------
 * [TAG Tag name
 * author*-1999010816123000] 
 * <
 * [First change patch
 * author*-20051008080552] 
 * [Second change patch
 * author*-20051008080552
 *  Long comment
 *  indented by one space
 * ] 
 * (other rollback patches)
 * [TAG Previous tag if any
 * author*-20051008080552] 
 * > {
 * }
 */


@implementation PWDarcsTagPatch

#pragma mark Initialization and Deallocation

- (id)initWithReader:(NSObject <PWReader> *)reader error:(NSError **)outError // Designated initializer
{
	if (self = [super init])
	{
		PW_patchReader = [reader retain];
		
		// Parse patch
		// Cache the tag regular expression
		static OGRegularExpression *tagRegexp = nil;
		if (!tagRegexp)
			// tagRegexp unescaped pattern: "^\[TAG (?<name>.*?)\n(?<author>.*?)\*(?<rollback_flag>\*|-)((?<new_date>\d{14})|(?<old_date>\w{3} \w{3} [\d ]\d \d\d:\d\d:\d\d \w+ \d{4}))] \n<$)";
			tagRegexp = [[OGRegularExpression alloc] initWithString:@"^\\[TAG (?<name>.*?)\\n(?<author>.*?)\\*(?<rollback_flag>\\*|-)((?<new_date>\\d{14})|(?<old_date>\\w{3} \\w{3} [\\d ]\\d \\d\\d:\\d\\d:\\d\\d \\w+ \\d{4}))] \\n<$"];
		
		OGRegularExpressionMatch *match = nil;
		
		BOOL doesMatch = NO, definitelyDoesNotMatch = NO;
		
		// Check if the existing string is enough to be certain of a match
		NSString *currPatchString = [reader cachedContent];
		unsigned int currPatchStringLength = [currPatchString length];
		if ((currPatchStringLength >= 3) && ([[currPatchString substringFromIndex:(currPatchStringLength - 3)] isEqualToString:@"\n<\n"]))
		{
			match = [tagRegexp matchInString:currPatchString];
			doesMatch = ([match count] > 0);
			definitelyDoesNotMatch = !doesMatch;
		}
		
		// Read in more lines to see if we get a match
		while (!doesMatch && !definitelyDoesNotMatch)
		{
			if ([reader isEntireContentRead])
			{
				match = [tagRegexp matchInString:[reader fullContent]];
				doesMatch = ([match count] > 0);
				definitelyDoesNotMatch = !doesMatch;
			}
			else
			{
				// Read in the next line of the patch. If we read "<\n" then we know this patch will definitely never match the regexp.
				NSString *newLine = [reader readNextLine:YES];
				if (!newLine)
				{
					[self release];
					*outError = [NSError errorWithDomain:NSCocoaErrorDomain
					                                code:NSFileReadUnknownError
					                            userInfo:nil];
					return nil;
				}
				else
				{
					if ([newLine isEqualToString:@"<\n"])
					{
						match = [tagRegexp matchInString:[reader cachedContent]];
						doesMatch = ([match count] > 0);
						definitelyDoesNotMatch = !doesMatch;
					}
				}
			}
		} while (!doesMatch && !definitelyDoesNotMatch);
		
		
		if (!match || ([match count] == 0))
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
			
			NSString *rollbackFlag = [match substringNamed:@"rollback_flag"];
			if ([rollbackFlag isEqualToString:@"*"])
				PW_isRollbackPatch = NO;
			else if ([rollbackFlag isEqualToString:@"-"])
				PW_isRollbackPatch = YES;
			else
				[NSException raise:NSInternalInconsistencyException
				            format:@"Patch regular expression matched patch string, but rollback_flag was '%@' instead of '*' or '-'", rollbackFlag];
		}
	}
	return self;
}


- (void)dealloc
{
	[super dealloc];
}



#pragma mark Accessor Methods

- (PWDarcsPatchType)type
{
	return PWDarcsTagPatchType;
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
