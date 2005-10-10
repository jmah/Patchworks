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
#import "PatchworksDefines.h"
#import "PWDarcsPatch.h"
#import "PWDarcsChangePatch.h"
#import "PWDarcsTagPatch.h"
#import "PWTimeZoneWrapper.h"


@interface PWDarcsPatchProxyDocument (PrivateMethods)

#pragma mark Accessor Methods
- (NSFontDescriptor *)fullPatchFontDescriptor;
- (void)setFullPatchFontDescriptor:(NSFontDescriptor *)newFontDescriptor;

@end


@implementation PWDarcsPatchProxyDocument

#pragma mark Initialization and Deallocation

+ (void)initialize
{
	// Set KVO dependent keys
	[self setKeys:[NSArray arrayWithObject:@"currentTimeZoneWrapper"] triggerChangeNotificationsForDependentKey:@"patchDate"];
	[self setKeys:[NSArray arrayWithObject:@"fullPatchFontDescriptor"] triggerChangeNotificationsForDependentKey:@"fullPatchFont"];
}


- (id)init // Designated Initializer
{
	if (self = [super init])
	{
		NSString *defaultTimeZoneName = [[NSUserDefaults standardUserDefaults] objectForKey:PWDefaultTimeZoneName];
		
		// Initialize instance variables
		PW_fullPatchFontDescriptor = [[NSFontDescriptor fontDescriptorWithFontAttributes:[[NSUserDefaults standardUserDefaults] objectForKey:PWFullPatchFontDescriptorAttributes]] retain];
		
		PW_patch = nil;
		PW_patchURL = nil;
		[self setCurrentTimeZoneWrapper:[PWTimeZoneWrapper timeZoneWrapperWithName:defaultTimeZoneName]];
		
		PW_dateFormatter = [[NSDateFormatter alloc] init];
		[PW_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
		[PW_dateFormatter setDateStyle:NSDateFormatterShortStyle];
		[PW_dateFormatter setTimeStyle:NSDateFormatterLongStyle];
		[PW_dateFormatter bind:@"timeZone"
		              toObject:self
		           withKeyPath:@"currentTimeZoneWrapper.timeZone"
		               options:nil];
		
		// Observe objects
		[[NSUserDefaults standardUserDefaults] addObserver:self
		                                        forKeyPath:PWDefaultTimeZoneName
		                                           options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld)
		                                           context:NULL];
		[[NSUserDefaults standardUserDefaults] addObserver:self
		                                        forKeyPath:PWFullPatchFontDescriptorAttributes
		                                           options:NSKeyValueObservingOptionNew
		                                           context:NULL];
	}
	return self;
}


- (void)dealloc
{
	[PW_fullPatchFontDescriptor release];
	PW_fullPatchFontDescriptor = nil;
	
	[PW_patch release];
	PW_patch = nil;
	
	[PW_patchURL release];
	PW_patchURL = nil;
	
	[PW_currentTimeZoneWrapper release];
	PW_currentTimeZoneWrapper = nil;
	
	[PW_dateFormatter release];
	PW_dateFormatter = nil;
	
	[super dealloc];
}



#pragma mark UI Management

- (NSString *)windowNibName // NSDocument
{
	return @"PWDarcsPatchProxyDocument";
}


- (void)windowControllerDidLoadNib:(NSWindowController *)controller // NSDocument
{
	[super windowControllerDidLoadNib:controller];
	
	// Watch the current time zone so we can update the formatter as necessary
	[PW_dateFormatter addObserver:self
	                   forKeyPath:@"timeZone"
	                      options:(NSKeyValueObservingOptions)NULL
	                      context:NULL];
	[dateTextField setFormatter:PW_dateFormatter];
	[dateTextField setNeedsDisplay];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ((object == PW_dateFormatter) && [keyPath isEqualToString:@"timeZone"])
		[dateTextField setNeedsDisplay];
	else if ((object == [NSUserDefaults standardUserDefaults]) && [keyPath isEqualToString:PWFullPatchFontDescriptorAttributes])
	{
		NSFontDescriptor *newFontDescriptor = [NSFontDescriptor fontDescriptorWithFontAttributes:[change objectForKey:NSKeyValueChangeNewKey]];
		[self setFullPatchFontDescriptor:newFontDescriptor];
	}
	else if ((object == [NSUserDefaults standardUserDefaults]) && [keyPath isEqualToString:PWDefaultTimeZoneName])
	{
		// The default time zone was changed. If we were set to the previous default, update our time zone.
		NSString *oldTimeZoneName = [change objectForKey:NSKeyValueChangeOldKey];
		if ([[[self currentTimeZoneWrapper] name] isEqualToString:oldTimeZoneName])
			[self setCurrentTimeZoneWrapper:[PWTimeZoneWrapper timeZoneWrapperWithName:[change objectForKey:NSKeyValueChangeNewKey]]];
	}
	else
		[super observeValueForKeyPath:keyPath
		                     ofObject:object
		                       change:change
		                      context:context];
}



#pragma mark Persistence

- (BOOL)readFromURL:(NSURL *)proxyURL ofType:(NSString *)typeName error:(NSError **)outError // NSDocument
{
	*outError = nil;
	
	NSString *basename = [[[proxyURL absoluteString] lastPathComponent] stringByDeletingPathExtension];
	NSString *relativePatchPath = [NSString stringWithFormat:@"../patches/%@", [basename stringByAppendingPathExtension:@"gz"]];
	NSURL *patchURL = [NSURL URLWithString:relativePatchPath relativeToURL:proxyURL];
	
	if (PW_patch)
		[PW_patch release];
	PW_patch = [[PWDarcsPatch patchWithContentsOfURL:patchURL error:outError] retain];
	
	BOOL success = ((PW_patch != nil) && (*outError == nil));
	if (success)
	{
		[PW_patchURL release];
		PW_patchURL = [patchURL retain];
	}
	
	return success;
}



#pragma mark UI Actions

- (IBAction)emailAuthor:(id)sender
{
	if ([self patchAuthorEmail])
	{
		NSURL *authorEmailURL = [NSURL URLWithString:[@"mailto:" stringByAppendingString:[self patchAuthorEmail]]];
		[[NSWorkspace sharedWorkspace] openURL:authorEmailURL];
	}
}



#pragma mark Accessor Methods

- (NSString *)patchName
{
	return [PW_patch name];
}


- (NSString *)localizedPatchType
{
	NSString *typeString = nil;
	
	switch ([PW_patch patchType])
	{
		case PWDarcsUnknownPatchType:
			if ([PW_patch isRollbackPatch])
				typeString = NSLocalizedStringFromTable(@"Unknown (Rollback)", @"PWDarcsPatch", @"Unknown rollback patch type");
			else
				typeString = NSLocalizedStringFromTable(@"Unknown", @"PWDarcsPatch", @"Unknown patch type");
			break;
		case PWDarcsChangePatchType:
			if ([PW_patch isRollbackPatch])
				typeString = NSLocalizedStringFromTable(@"Change (Rollback)", @"PWDarcsPatch", @"Change rollback patch type");
			else
				typeString = NSLocalizedStringFromTable(@"Change", @"PWDarcsPatch", @"Change patch type");
			break;
		case PWDarcsTagPatchType:
			if ([PW_patch isRollbackPatch])
				typeString = NSLocalizedStringFromTable(@"Tag (Rollback)", @"PWDarcsPatch", @"Tag rollback patch type");
			else
				typeString = NSLocalizedStringFromTable(@"Tag", @"PWDarcsPatch", @"Tag patch type");
			break;
	}
	
	return typeString;
}


- (NSString *)patchAuthor
{
	return [PW_patch author];
}


- (NSString *)patchAuthorEmail
{
	return [PW_patch authorEmail];
}


- (NSString *)emailAuthorButtonToolTip
{
	return [NSString stringWithFormat:NSLocalizedStringFromTable(@"Send e-mail to <%@>", @"PWDarcsPatch", @"E-mail author button tool tip format"), [self patchAuthorEmail]];
}


- (NSCalendarDate *)patchDate
{
	NSCalendarDate *dateWithTimeZone = [[PW_patch date] copy];
	[dateWithTimeZone setTimeZone:[[self currentTimeZoneWrapper] timeZone]];
	return dateWithTimeZone;
}


- (NSString *)patchString
{
	return [PW_patch patchString];
}


- (NSFont *)fullPatchFont
{
	return [NSFont fontWithDescriptor:[self fullPatchFontDescriptor] size:[[self fullPatchFontDescriptor] pointSize]];
}


- (void)setCurrentTimeZoneWrapper:(PWTimeZoneWrapper *)timeZoneWrapper
{
	[timeZoneWrapper retain];
	[PW_currentTimeZoneWrapper release];
	PW_currentTimeZoneWrapper = timeZoneWrapper;
}


- (PWTimeZoneWrapper *)currentTimeZoneWrapper
{
	return PW_currentTimeZoneWrapper;
}


- (NSURL *)repositoryURL
{
	return [NSURL URLWithString:@"../.." relativeToURL:PW_patchURL]; // Climb out of the 'patches' and '_darcs' directories
}


- (NSString *)repositoryPath
{
	return [[self repositoryURL] path];
}


- (NSFontDescriptor *)fullPatchFontDescriptor // PWDarcsPatchProxyDocument (PrivateMethods)
{
	return PW_fullPatchFontDescriptor;
}


- (void)setFullPatchFontDescriptor:(NSFontDescriptor *)newFontDescriptor // PWDarcsPatchProxyDocument (PrivateMethods)
{
	[newFontDescriptor retain];
	[PW_fullPatchFontDescriptor release];
	PW_fullPatchFontDescriptor = newFontDescriptor;
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
