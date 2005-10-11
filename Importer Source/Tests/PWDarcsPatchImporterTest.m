//
//  PWDarcsPatchImporterTest.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-11.
//  Copyright Playhaus 2005. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsPatchImporterTest.h"
#import "PWDarcsPatchImporter.h"
#import "PWDarcsPatchProxy.h"


@implementation PWDarcsPatchImporterTest


- (void)testMetadataDictionary
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *proxyPath = [myBundle pathForResource:@"20050921202143-39b7c-447d042ca05732eef5811e9cf80114117532a2d4"
	                                         ofType:@"darcsPatchProxy"
	                                    inDirectory:@"Test Repository/darcs/patchworks"];
	NSError *error = nil;
	PWDarcsPatchImporter *importer = [[PWDarcsPatchImporter alloc] initWithURL:[NSURL fileURLWithPath:proxyPath] error:&error];
	STAssertNotNil(importer,
		@"importer failed to initialize.");
	STAssertNil(error,
		@"Importer generated an error.");
	
	NSDictionary *mdDictionary = nil;
	STAssertNoThrow(mdDictionary = [importer metadataDictionary],
		@"Getting metadata dictionary threw an exception.");
	STAssertNotNil(mdDictionary,
		@"Metadata dictionary was nil.");
	
	[importer release];
}


- (void)testAddingMetadataDictionary
{
	NSBundle *myBundle = [NSBundle bundleForClass:[self class]];
	NSString *proxyPath = [myBundle pathForResource:@"20050921202143-39b7c-447d042ca05732eef5811e9cf80114117532a2d4"
	                                         ofType:@"darcsPatchProxy"
	                                    inDirectory:@"Test Repository/darcs/patchworks"];
	NSError *error = nil;
	PWDarcsPatchImporter *importer = [[PWDarcsPatchImporter alloc] initWithURL:[NSURL fileURLWithPath:proxyPath] error:&error];
	STAssertNotNil(importer,
		@"importer failed to initialize.");
	STAssertNil(error,
		@"Importer generated an error.");
	
	NSError *proxyError = nil;
	PWDarcsPatchProxy *proxy = [[PWDarcsPatchProxy alloc] initWithURL:[NSURL fileURLWithPath:proxyPath] error:&proxyError];
	
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
		@"Old title", (NSString *)kMDItemTitle,
		[NSArray arrayWithObject:@"Old author"], (NSString *)kMDItemAuthors,
		@"Custom string", @"Custom attribute",
		nil];
	
	STAssertNoThrow([importer addMetadataToCFDictionary:(CFDictionaryRef)dictionary],
		@"Adding metadata to dictionary threw an exception.");
	
	STAssertEqualObjects([dictionary objectForKey:(NSString *)kMDItemTitle], [proxy name],
		@"Item title was not changed by importer.");
	
	NSArray *newAuthors = [NSArray arrayWithObjects:@"Old author", [proxy authorNameOnly], nil];
	STAssertEqualObjects([dictionary objectForKey:(NSString *)kMDItemAuthors], newAuthors,
		@"Item author was not appended to old author list.");
	STAssertEqualObjects([dictionary objectForKey:@"Custom attribute"], @"Custom string",
		@"Custom attribute was incorrectly changed by importer.");
	
	[proxy release];
	[importer release];
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
