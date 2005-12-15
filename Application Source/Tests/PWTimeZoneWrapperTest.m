//
//  PWTimeZoneWrapperTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-09.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWTimeZoneWrapperTest.h"
#import "PWTimeZoneWrapper.h"


@implementation PWTimeZoneWrapperTest


- (void)testUTCTimeZoneWrapper
{
	PWTimeZoneWrapper *utcWrapper = [PWTimeZoneWrapper timeZoneWrapperWithName:@"UTC"];
	STAssertNotNil(utcWrapper,
		@"UTC wrapper was nil.");
	STAssertEqualObjects([utcWrapper name], @"UTC",
		@"Wrapper name was not as initialized.");
	STAssertEquals([utcWrapper secondsFromGMT], 0,
		@"Seconds from GMT was not correct.");
	STAssertEqualObjects([utcWrapper abbreviation], @"UTC",
		@"Wrapper abbreviation was not correct.");
	
	NSTimeZone *utcTimeZone = [NSTimeZone timeZoneWithName:@"UTC"];
	STAssertEqualObjects([utcWrapper timeZone], utcTimeZone,
		@"Time zone was not correct.");
}


- (void)testAdelaideTimeZoneWrapper
{
	PWTimeZoneWrapper *adelaideWrapper = [PWTimeZoneWrapper timeZoneWrapperWithName:@"Australia/Adelaide"];
	STAssertNotNil(adelaideWrapper,
		@"Adelaide wrapper was nil.");
	STAssertEqualObjects([adelaideWrapper name], @"Australia/Adelaide",
		@"Wrapper name was not as initialized.");
	int secondsFromGMT = 9.5 * 60 * 60;
	if ([[NSTimeZone timeZoneWithName:@"Australia/Adelaide"] isDaylightSavingTime])
		secondsFromGMT += 1 * 60 * 60;
	STAssertEquals([adelaideWrapper secondsFromGMT], secondsFromGMT,
		@"Seconds from GMT was not correct.");
	STAssertEqualObjects([adelaideWrapper abbreviation], @"CST",
		@"Wrapper abbreviation was not correct.");
	
	NSTimeZone *adelaideTimeZone = [NSTimeZone timeZoneWithName:@"Australia/Adelaide"];
	STAssertEqualObjects([adelaideWrapper timeZone], adelaideTimeZone,
		@"Time zone was not correct.");
}


- (void)testKnownTimeZones
{
	STAssertEquals([[PWTimeZoneWrapper knownTimeZoneWrappers] count], [[NSTimeZone knownTimeZoneNames] count] - [[PWTimeZoneWrapper ignoredTimeZoneNames] count],
		@"Known time zone wrappers differed in number to known time zone names.");
	STAssertTrue([[PWTimeZoneWrapper knownTimeZoneWrappers] containsObject:[PWTimeZoneWrapper timeZoneWrapperWithName:@"US/Pacific"]],
		@"Wrapper for US/Pacific not included in known wrappers.");
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
