//
//  PWDarcsPatchProxyDocument.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-09.
//  Copyright Playhaus 2005. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsPatchProxyDocument.h"
#import "PWDarcsPatchProxyWindowController.h"
#import "PatchworksDefines.h"
#import "PWDarcsPatch.h"
#import "PWDarcsPatchProxy.h"
#import "PWTimeZoneWrapper.h"


@implementation PWDarcsPatchProxyDocument

#pragma mark Initialization and Deallocation

- (id)init // Designated Initializer
{
	if (self = [super init])
	{
		// Initialize instance variables
		PW_patchProxy = nil;
	}
	return self;
}


- (void)dealloc
{
	[PW_patchProxy release];
	PW_patchProxy = nil;
	
	[super dealloc];
}



#pragma mark UI Management

- (void)makeWindowControllers // NSDocument
{
	[self addWindowController:[[[PWDarcsPatchProxyWindowController alloc] initWithWindowNibName:@"PWDarcsPatchProxyDocument"] autorelease]];
}



#pragma mark Persistence

- (BOOL)readFromURL:(NSURL *)proxyURL ofType:(NSString *)typeName error:(NSError **)outError // NSDocument
{
	*outError = nil;
	[PW_patchProxy release];
	PW_patchProxy = [[PWDarcsPatchProxy alloc] initWithURL:proxyURL error:outError];
	
	BOOL success = ((PW_patchProxy != nil) && (*outError == nil));
	return success;
}



#pragma mark Accessor Methods

- (NSString *)patchName
{
	return [PW_patchProxy name];
}


- (NSString *)localizedPatchType
{
	NSString *typeString = nil;
	
	switch ([PW_patchProxy type])
	{
		case PWDarcsChangePatchType:
			if ([PW_patchProxy isRollbackPatch])
				typeString = NSLocalizedStringFromTable(@"Change (Rollback)", @"PWDarcsPatch", @"Change rollback patch type");
			else
				typeString = NSLocalizedStringFromTable(@"Change", @"PWDarcsPatch", @"Change patch type");
			break;
		case PWDarcsTagPatchType:
			if ([PW_patchProxy isRollbackPatch])
				typeString = NSLocalizedStringFromTable(@"Tag (Rollback)", @"PWDarcsPatch", @"Tag rollback patch type");
			else
				typeString = NSLocalizedStringFromTable(@"Tag", @"PWDarcsPatch", @"Tag patch type");
			break;
		default: // Code shared with PWDarcsUnknownPatchType
		case PWDarcsUnknownPatchType:
			if ([PW_patchProxy isRollbackPatch])
				typeString = NSLocalizedStringFromTable(@"Unknown (Rollback)", @"PWDarcsPatch", @"Unknown rollback patch type");
			else
				typeString = NSLocalizedStringFromTable(@"Unknown", @"PWDarcsPatch", @"Unknown patch type");
			break;
	}
	
	return typeString;
}


- (NSString *)patchAuthor
{
	return [PW_patchProxy authorNameOnly];
}


- (NSString *)patchAuthorEmail
{
	return [PW_patchProxy authorEmail];
}


- (NSString *)emailAuthorButtonToolTip
{
	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Send e-mail to <%@>", @"PWDarcsPatch", @"E-mail author button tool tip format"), [self patchAuthorEmail]];
}


- (NSCalendarDate *)patchDate
{
	NSCalendarDate *dateWithTimeZone = [[PW_patchProxy date] copy];
	[dateWithTimeZone setTimeZone:[NSTimeZone timeZoneWithName:[[NSUserDefaults standardUserDefaults] objectForKey:PWDefaultTimeZoneName]]];
	return dateWithTimeZone;
}


- (NSString *)patchString
{
	return [PW_patchProxy patchString];
}


- (NSString *)repositoryPath
{
	return [[PW_patchProxy repositoryURL] path];
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
