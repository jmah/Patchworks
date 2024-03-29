//
//  PWDarcsPatchImporter.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-11.
//  Copyright Playhaus 2005. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import "PWDarcsPatchImporter.h"
#import "PWDarcsPatch.h"
#import "PWDarcsChangePatch.h"
#import "PWDarcsPatchProxy.h"


@implementation PWDarcsPatchImporter

#pragma mark Initialization and Deallocation

- (id)initWithURL:(NSURL *)proxyURL error:(NSError **)outError // Designated initializer
{
	if (self = [super init])
	{
		// Load weakly-linked frameworks
		static NSString *frameworksPath = nil;
		if (!frameworksPath)
		{
			NSString *myPath = [[NSBundle bundleForClass:[self class]] bundlePath];
			// Move from Library/Spotlight/Patchworks.mdimporter/ into Frameworks/
			frameworksPath = [[NSString pathWithComponents:[NSArray arrayWithObjects:myPath, @"..", @"..", @"..", @"Frameworks", nil]] stringByStandardizingPath];
		}
		static BOOL loadedOgreKit = NO;
		if (!loadedOgreKit)
		{
			if ([NSBundle bundleWithIdentifier:@"isao.sonobe.OgreKit"])
				loadedOgreKit = YES;
			else
			{
				NSString *ogreKitPath = [frameworksPath stringByAppendingPathComponent:@"OgreKit.framework"];
				NSBundle *ogreKitBundle = [NSBundle bundleWithPath:ogreKitPath];
				
				if (ogreKitBundle)
				{
					// Load in OgreKit classes
					[ogreKitBundle principalClass];
					loadedOgreKit = YES;
				}
				else
				{
					*outError = [NSError errorWithDomain:NSCocoaErrorDomain code:NSFileReadNoSuchFileError userInfo:nil];
					NSLog(@"Couldn't load OgreKit.framework at path: %@", ogreKitPath);
					[self release];
					return nil;
				}
			}
		}
		
		// Initialize instance variables
		PW_patchProxy = [[PWDarcsPatchProxy alloc] initWithURL:proxyURL error:outError];
		
		if (*outError)
		{
			[self release];
			self = nil;
		}
	}
	return self;
}


- (void)dealloc
{
	[PW_patchProxy release];
	
	[super dealloc];
}



#pragma mark Metadata Access

- (NSDictionary *)metadataDictionary
{
	static NSBundle *myBundle = nil;
	if (!myBundle)
		myBundle = [NSBundle bundleForClass:[self class]];
	
	NSString *localizedType = nil;
	NSString *displayNamePrefix = @"";
	switch ([PW_patchProxy type])
	{
		case PWDarcsChangePatchType:
			localizedType = [myBundle localizedStringForKey:@"Change" value:@"Change patch type" table:nil];
			break;
		case PWDarcsTagPatchType:
			localizedType = [myBundle localizedStringForKey:@"Tag" value:@"Tag patch type" table:nil];
			displayNamePrefix = @"TAG ";
			break;
		default: // Code shared with PWDarcsUnknownPatchType
		case PWDarcsUnknownPatchType:
			localizedType = [myBundle localizedStringForKey:@"Unknown" value:@"Unknown patch type" table:nil];
			break;
	}
	
	if ([PW_patchProxy isRollbackPatch])
		displayNamePrefix = [NSString stringWithFormat:@"UNDO: %@", displayNamePrefix];
	
	NSMutableDictionary *mdDictionary = [NSMutableDictionary dictionary];
	
	[mdDictionary setObject:[displayNamePrefix stringByAppendingString:[PW_patchProxy name]] forKey:(NSString *)kMDItemDisplayName];
	[mdDictionary setObject:[PW_patchProxy name] forKey:(NSString *)kMDItemTitle];
	[mdDictionary setObject:[NSArray arrayWithObject:[PW_patchProxy authorNameOnly]] forKey:(NSString *)kMDItemAuthors];
	[mdDictionary setObject:localizedType forKey:@"org_playhaus_patchworks_darcs_PatchType"];
	[mdDictionary setObject:[NSNumber numberWithBool:[PW_patchProxy isRollbackPatch]] forKey:@"org_playhaus_patchworks_darcs_IsRollbackPatch"];
	[mdDictionary setObject:[PW_patchProxy date] forKey:(NSString *)kMDItemContentCreationDate];
	[mdDictionary setObject:[PW_patchProxy date] forKey:(NSString *)kMDItemContentModificationDate];
	[mdDictionary setObject:[PW_patchProxy date] forKey:(NSString *)kMDItemLastUsedDate];
	[mdDictionary setObject:@"darcs" forKey:(NSString *)kMDItemCreator];
	[mdDictionary setObject:[NSArray arrayWithObject:[PW_patchProxy authorEmail]] forKey:(NSString *)kMDItemEmailAddresses];
	[mdDictionary setObject:[NSArray arrayWithObject:[PW_patchProxy authorEmail]] forKey:(NSString *)kMDItemWhereFroms];
#warning Set changed filenames for kMDItemKeywords
	// NSArray *changedFilenamesArray = ...;
	// [mdDictionary setObject:changedFilenamesArray forKey:(NSString *)kMDItemKeywords];
	NSString *repoName = [[[PW_patchProxy repositoryURL] path] lastPathComponent];
	[mdDictionary setObject:[NSArray arrayWithObject:repoName] forKey:(NSString *)kMDItemProjects];
	
	if ([PW_patchProxy type] == PWDarcsChangePatchType)
		if ([(id)PW_patchProxy longComment])
			[mdDictionary setObject:[(id)PW_patchProxy cleanedLongComment] forKey:(NSString *)kMDItemComment];
	
	return mdDictionary;
}


- (void)addMetadataToCFDictionary:(CFMutableDictionaryRef)dictionary
{
	NSDictionary *mdDictionary = [self metadataDictionary];
	NSEnumerator *metadataKeys = [mdDictionary keyEnumerator];
	NSString *currKey = nil;
	while (currKey = [metadataKeys nextObject])
	{
		BOOL isAttributeMultiValued;
		
		CFDictionaryRef metaAttributes = MDSchemaCopyMetaAttributesForAttribute((CFStringRef)currKey);
		if (!metaAttributes)
		{
			// We are probably dealing with one of our custom attributes, and the importer is not currently installed (so the metadata system knows nothing about them). If so, fake it manually:
			if ([currKey isEqualToString:@"org_playhaus_patchworks_darcs_IsRollbackPatch"])
			{
				NSLog(@"Faking meta-attributes for attribute %@. This should only happen when the importer is not installed.", currKey);
				isAttributeMultiValued = NO;
			}
			else if ([currKey isEqualToString:@"org_playhaus_patchworks_darcs_PatchType"])
			{
				NSLog(@"Faking meta-attributes for attribute %@. This should only happen when the importer is not installed.", currKey);
				isAttributeMultiValued = NO;
			}
			else
				NSAssert1(NO, @"Copying meta-attributes failed for attribute %@.", currKey);
		}
		else
		{
			isAttributeMultiValued = CFBooleanGetValue(CFDictionaryGetValue(metaAttributes, kMDAttributeMultiValued));
			CFRelease(metaAttributes);
		}
		
		if (isAttributeMultiValued && CFDictionaryContainsKey(dictionary, currKey))
		{
			// Merge our array with the supplied array
			NSMutableArray *newArray = [(NSArray *)CFDictionaryGetValue(dictionary, currKey) mutableCopy];
			NSEnumerator *newArrayEnumerator = [[mdDictionary objectForKey:currKey] objectEnumerator];
			id currObject = nil;
			while (currObject = [newArrayEnumerator nextObject])
				if (![newArray containsObject:currObject])
					[newArray addObject:currObject];
			
			CFDictionarySetValue(dictionary, currKey, newArray);
			
			[newArray release];
		}
		else
			CFDictionarySetValue(dictionary, currKey, [mdDictionary objectForKey:currKey]);
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
