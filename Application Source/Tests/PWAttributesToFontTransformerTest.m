//
//  PWAttributesToFontTransformerTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-12-18.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWAttributesToFontTransformerTest.h"
#import "PWAttributesToFontTransformer.h"


@implementation PWAttributesToFontTransformerTest


- (void)testTransformation
{
	PWAttributesToFontTransformer *trans = [[PWAttributesToFontTransformer alloc] init];
	
	NSFont *font = [NSFont fontWithName:@"Lucida Grande" size:13.5];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"Lucida Grande", NSFontNameAttribute, @"13.5", NSFontSizeAttribute, nil];
	
	id transformed = [trans transformedValue:attributes];
	STAssertEqualObjects(font, transformed,
		@"Transformed value was not correct.");
	STAssertTrue([transformed isKindOfClass:[PWAttributesToFontTransformer transformedValueClass]],
		@"Transformed value was not of stated class.");
	
	[trans release];
}


- (void)testReverseTransformation
{
	PWAttributesToFontTransformer *trans = [[PWAttributesToFontTransformer alloc] init];
	
	NSFont *font = [NSFont fontWithName:@"Helvetica" size:23.f];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:@"Helvetica", NSFontNameAttribute, @"23", NSFontSizeAttribute, nil];
	
	id transformed = [trans reverseTransformedValue:font];
	STAssertTrue([PWAttributesToFontTransformer allowsReverseTransformation],
		@"Reverse transformation was not allowed.");
	
	NSEnumerator *attrKeys = [attributes keyEnumerator];
	NSString *currAttrKey;
	while (currAttrKey = [attrKeys nextObject])
	{
		id attrObject = [attributes objectForKey:currAttrKey];
		id transformedObject = [transformed objectForKey:currAttrKey];
		
		if ([currAttrKey isEqual:NSFontSizeAttribute])
		{
			attrObject = [NSNumber numberWithFloat:[attrObject floatValue]];
			transformedObject = [NSNumber numberWithFloat:[transformedObject floatValue]];
		}
		
		STAssertEqualObjects(attrObject, transformedObject,
			@"Transformed value was not correct.");
	}
	
	[trans release];
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
