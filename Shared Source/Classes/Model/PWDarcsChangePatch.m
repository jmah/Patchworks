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


@implementation PWDarcsChangePatch

#pragma mark Initialization and Deallocation

- (id)initWithPatchString:(NSString *)patchString error:(NSError **)outError // Designated initializer
{
	if (self = [super init])
	{
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
		
		// Initialize instance variables
		PW_patchString = [patchString retain];
		PW_longDescription = nil;
		
		
		// Parse patch
		// Cache the patch regular expression
		static OGRegularExpression *patchRegexp = nil;
		if (!patchRegexp)
			// patchRegexp unescaped pattern: "^\[(?<name>.*?)\n(?<author>.*?)\*(?<rollback_flag>\*|-)(?<date>\d{14})(?:] {|\n(?<long_description>(?:.|\n)*?)\n\] {$)";
			patchRegexp = [[OGRegularExpression alloc] initWithString:@"^\\[(?<name>.*?)\\n(?<author>.*?)\\*(?<rollback_flag>\\*|-)(?<date>\\d{14})(?:] {|\\n(?<long_description>(?:.|\\n)*?)\\n\\] {$)"
			                                                  options:OgreCaptureGroupOption
			                                                   syntax:OgreRubySyntax
			                                          escapeCharacter:OgreBackslashCharacter];
		
		OGRegularExpressionMatch *match = [patchRegexp matchInString:patchString];
		if ([match count] == 0)
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
			[self setDate:[[self class] calendarDateFromDarcsDateString:[match substringNamed:@"date"]]];
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
	return self;
}


- (void)dealloc
{
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
