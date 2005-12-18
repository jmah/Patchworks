//
//  PWNameToTimeZoneTransformerTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-12-18.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWNameToTimeZoneTransformerTest.h"
#import "PWNameToTimeZoneTransformer.h"


@implementation PWNameToTimeZoneTransformerTest


- (void)testTransformation
{
	PWNameToTimeZoneTransformer *trans = [[PWNameToTimeZoneTransformer alloc] init];
	
	NSString *zoneName = @"Australia/Adelaide";
	NSTimeZone *adelaide = [NSTimeZone timeZoneWithName:zoneName];
	id transformed = [trans transformedValue:zoneName];
	STAssertEqualObjects(adelaide, transformed,
		@"Transformed value was not correct.");
	STAssertTrue([transformed isKindOfClass:[PWNameToTimeZoneTransformer transformedValueClass]],
		@"Transformed value was not of stated class.");
	
	[trans release];
}


- (void)testReverseTransformation
{
	PWNameToTimeZoneTransformer *trans = [[PWNameToTimeZoneTransformer alloc] init];
	
	NSString *zoneName = @"UTC";
	NSTimeZone *utc = [NSTimeZone timeZoneWithName:zoneName];
	id transformed = [trans reverseTransformedValue:utc];
	STAssertTrue([PWNameToTimeZoneTransformer allowsReverseTransformation],
		@"Reverse transformation was not allowed.");
	STAssertEqualObjects(zoneName, transformed,
		@"Reversed transformed value was not correct.");
	
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
