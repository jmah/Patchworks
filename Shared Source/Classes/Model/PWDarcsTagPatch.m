//
//  PWDarcsTagPatch.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsTagPatch.h"
#import "PWDarcsPatch+ProtectedMethods.h"
#import <OgreKit/OgreKit.h>


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
 *  Long description
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
 *  Long description
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

- (id)initWithOpenGzFile:(gzFile)gzPatchFile alreadyReadString:(NSString *)currPatchString error:(NSError **)outError // Designated initializer
{
	if (self = [super init])
	{
		// Initialize instance variables
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
		// Cache the tag regular expression
		static OGRegularExpression *tagRegexp = nil;
		if (!tagRegexp)
			// tagRegexp unescaped pattern: "^\[TAG (?<name>.*?)\n(?<author>.*?)\*(?<rollback_flag>\*|-)((?<new_date>\d{14})|(?<old_date>\w{3} \w{3} [\d ]\d \d\d:\d\d:\d\d \w+ \d{4}))] \n<$)";
			tagRegexp = [[OGRegularExpression alloc] initWithString:@"^\\[TAG (?<name>.*?)\\n(?<author>.*?)\\*(?<rollback_flag>\\*|-)((?<new_date>\\d{14})|(?<old_date>\\w{3} \\w{3} [\\d ]\\d \\d\\d:\\d\\d:\\d\\d \\w+ \\d{4}))] \\n<$"];
		
		OGRegularExpressionMatch *match = nil;
		
		BOOL doesMatch = NO, definitelyDoesNotMatch = NO;
		do
		{
			if (PW_isFullPatchRead)
			{
				match = [tagRegexp matchInString:PW_fullPatchString];
				doesMatch = ([match count] > 0);
				definitelyDoesNotMatch = !doesMatch;
			}
			else
			{
				// Check if the current patch string matches. If it doesn't, read some more and try again.
				match = [tagRegexp matchInString:PW_currPatchString];
				doesMatch = ([match count] > 0);
				if (!doesMatch)
				{
					// Read in the next line of the patch. If we read "<\n" then we know this patch will definitely never match the regexp.
					char lineBuffer[LINE_BUFFER_LENGH];
					char *line = gzgets(PW_gzPatchFile, lineBuffer, LINE_BUFFER_LENGH);
					if (line == Z_NULL)
					{
						gzclose(PW_gzPatchFile);
						PW_gzPatchFile = nil;
						[self release];
						*outError = [NSError errorWithDomain:NSCocoaErrorDomain
						                                code:NSFileReadUnknownError
						                            userInfo:nil];
						return nil;
					}
					else
					{
						NSString *newLine = [NSString stringWithCString:line encoding:PATCH_STRING_ENCODING];
						[PW_currPatchString appendString:newLine];
						if ([newLine isEqualToString:@"<\n"])
						{
							match = [tagRegexp matchInString:PW_currPatchString];
							doesMatch = ([match count] > 0);
							definitelyDoesNotMatch = !doesMatch;
						}
						
						// Since we just read in a chunk, check if we reached the end of file
						if (gzeof(PW_gzPatchFile))
						{
							PW_isFullPatchRead = YES;
							int closeError = gzclose(PW_gzPatchFile);
							PW_gzPatchFile = nil;
							NSAssert(closeError == Z_OK, @"Patch file failed to close");
							
							PW_fullPatchString = [currPatchString retain];
							[PW_currPatchString release];
							PW_currPatchString = nil;
						}
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
