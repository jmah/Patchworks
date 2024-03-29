//
//  PWDarcsPatchProxy.h
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-10.
//  Copyright Playhaus 2005. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#import <Foundation/Foundation.h>
#import "PWDarcsPatch.h"


/*
 * This class represents a darcs patch proxy file, with extension
 * .darcsPatchProxy. This class allows access to the represented patch, and
 * other filesystem-based information such as the path to the repository.
 */


@interface PWDarcsPatchProxy : NSObject
{
	@protected
	NSURL *PW_proxyURL;
	NSURL *PW_patchURL;
	PWDarcsPatch *PW_patch;
}


#pragma mark Initialization and Deallocation
- (id)initWithURL:(NSURL *)proxyURL error:(NSError **)outError; // Designated initializer

#pragma mark Accessor Methods
- (PWDarcsPatch *)patch;
- (NSURL *)proxyURL;
- (NSURL *)patchURL;
- (NSURL *)repositoryURL;

@end


@interface PWDarcsPatchProxy (PWForwardedMessages)

#pragma mark Forwarded Messages
// These messsages are forwarded to the underlying PWDarcsPatch
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
