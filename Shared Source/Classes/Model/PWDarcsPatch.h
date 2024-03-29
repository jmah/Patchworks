//
//  PWDarcsPatch.h
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import <Foundation/Foundation.h>
#import "PWReader.h"

@class PWGzipFileReader;


#define PWDarcsPatchStringEncoding NSISOLatin1StringEncoding

extern NSString *PWDarcsPatchErrorDomain;

enum {
	PWDarcsPatchUnknownTypeError = 1,
	PWDarcsPatchParseError,
};

typedef enum _PWDarcsPatchType {
	PWDarcsUnknownPatchType = 1,
	PWDarcsChangePatchType,
	PWDarcsTagPatchType,
} PWDarcsPatchType;


@interface PWDarcsPatch : NSObject
{
	@private
	NSString *PW_authorEmail; // Cached version of the author e-mail address
	NSString *PW_authorNameOnly; // Cached version of the author name only
	
	@protected
	NSObject <PWReader> *PW_patchReader;
	NSString *PW_name;
	NSString *PW_author;
	NSCalendarDate *PW_date;
	BOOL PW_isRollbackPatch;
}


#pragma mark Convenience Methods
+ (id)patchWithContentsOfFile:(NSString *)path error:(NSError **)outError;
+ (id)patchWithContentsOfURL:(NSURL *)patchURL error:(NSError **)outError;

#pragma mark Initialization and Deallocation
- (id)initWithReader:(NSObject <PWReader> *)reader error:(NSError **)outError; // Designated initializer

#pragma mark Accessor Methods
- (NSString *)patchString;
- (NSString *)name;
- (NSString *)author;
- (NSString *)authorEmail;
- (NSString *)authorNameOnly;
- (NSCalendarDate *)date;
- (PWDarcsPatchType)type;
- (BOOL)isRollbackPatch;

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
