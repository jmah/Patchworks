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


@implementation PWDarcsTagPatch

#pragma mark Initialization and Deallocation

- (id)initWithPatchString:(NSString *)patchString // Designated initializer
{
	if (self = [super init])
	{
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
		
		// Initialize instance variables
		PW_patchString = [patchString retain];
		
		
		// Parse patch
		// patchRegexp unescaped pattern: "^\[TAG (?<name>.*)\n(?<author>.*)\*(?<rollback_flag>\*|-)(?<date>\d{14})] \n<$)";
		OGRegularExpression *tagRegexp = [[OGRegularExpression alloc] initWithString:@"^\\[TAG (?<name>.*)\\n(?<author>.*)\\*(?<rollback_flag>\\*|-)(?<date>\\d{14})] \\n<$"
		                                                                     options:OgreCaptureGroupOption
		                                                                      syntax:OgreRubySyntax
		                                                             escapeCharacter:OgreBackslashCharacter];
		
		OGRegularExpressionMatch *match = [tagRegexp matchInString:patchString];
		if ([match count] == 0)
		{
			[tagRegexp release];
			[self release];
			self = nil;
			[NSException raise:PWDarcsPatchParseException format:@"Could not parse darcs patch"];
		}
		else
		{
			[self setName:[match substringNamed:@"name"]];
			[self setAuthor:[match substringNamed:@"author"]];
			[self setDate:[[self class] calendarDateFromDarcsDateString:[match substringNamed:@"date"]]];
			
			NSString *rollbackFlag = [match substringNamed:@"rollback_flag"];
			if ([rollbackFlag isEqualToString:@"*"])
				PW_isRollbackPatch = NO;
			else if ([rollbackFlag isEqualToString:@"-"])
				PW_isRollbackPatch = YES;
			else
				[NSException raise:NSInternalInconsistencyException
				            format:@"Patch regular expression matched patch string, but rollback_flag was '%@' instead of '*' or '-'", rollbackFlag];
		}
		
		[tagRegexp release];
	}
	return self;
}


- (void)dealloc
{
	[super dealloc];
}



#pragma mark Accessor Methods

- (PWDarcsPatchType)patchType
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
