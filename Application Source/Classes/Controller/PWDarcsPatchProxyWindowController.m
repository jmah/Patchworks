//
//  PWDarcsPatchProxyWindowController.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-12-18.
//  Copyright Playhaus 2005. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsPatchProxyWindowController.h"
#import "PWDarcsPatchProxyDocument.h"
#import "PatchworksDefines.h"


@implementation PWDarcsPatchProxyWindowController

#pragma mark Initiailization and Deallocation

- (void)dealloc
{
	[PW_dateFormatter release];
	PW_dateFormatter = nil;
	
	[super dealloc];
}


- (void)windowDidLoad // NSWindowController
{
	PW_dateFormatter = [[NSDateFormatter alloc] init];
	[PW_dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[PW_dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[PW_dateFormatter setTimeStyle:NSDateFormatterLongStyle];
	
	[PW_dateFormatter bind:@"timeZone"
	              toObject:[NSUserDefaults standardUserDefaults]
	           withKeyPath:PWDefaultTimeZoneName
	               options:[NSDictionary dictionaryWithObject:@"PWNameToTimeZoneTransformer" forKey:NSValueTransformerNameBindingOption]];
	
	// NSDateFormatter does not update its display when its time zone changes, so we must watch it and update it as necessary
	[PW_dateFormatter addObserver:self
	                   forKeyPath:@"timeZone"
	                      options:(NSKeyValueObservingOptions)NULL
	                      context:NULL];
	[dateTextField setFormatter:PW_dateFormatter];
	[dateTextField setNeedsDisplay];
	
#warning This is a workaround for a bug in Interface Builder that doesn't allow a window's min and max width or height to be equal. This needs to be changed if the preferences window layout changes
	[[self window] setContentMaxSize:NSMakeSize(MAXFLOAT, [[self window] contentMinSize].height)];
}



#pragma mark UI Actions

- (IBAction)emailAuthor:(id)sender
{
	NSString *authorEmail = [[self document] patchAuthorEmail];
	if (authorEmail)
	{
		NSURL *authorEmailURL = [NSURL URLWithString:[@"mailto:" stringByAppendingString:authorEmail]];
		[[NSWorkspace sharedWorkspace] openURL:authorEmailURL];
	}
}


- (IBAction)showFullPatch:(id)sender
{
	[[self document] showFullPatch];
}



#pragma mark UI Management

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ((object == PW_dateFormatter) && [keyPath isEqualToString:@"timeZone"])
		[dateTextField setNeedsDisplay];
	else
		[super observeValueForKeyPath:keyPath
		                     ofObject:object
		                       change:change
		                      context:context];
}


- (NSString *)windowTitleForDocumentDisplayName:(NSString *)displayName // NSWindowController
{
	NSString *newName = displayName;
	if ([self document] && [[self document] isKindOfClass:[PWDarcsPatchProxyDocument class]])
		newName = [[self document] patchName];
	return newName;
}


- (void)windowWillClose:(NSNotification *)notification // NSWindow delegate method
{
	if ([notification object] == [self window])
	{
		[PW_dateFormatter unbind:@"timeZone"];
		[PW_dateFormatter removeObserver:self forKeyPath:@"timeZone"];
	}
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
