//
//  PWDarcsPatch+ProtectedMethods.h
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-08.
//  Copyright 2005 Playhaus. All rights reserved.
//

#import "PWDarcsPatch.h"


#define LINE_BUFFER_LENGH 256
#define FULL_BUFFER_LENGTH 16384
#define PATCH_STRING_ENCODING NSISOLatin1StringEncoding


// Methods for use by concrete subclasses of PWDarcsPatch

@interface PWDarcsPatch (ProtectedMethods)

#pragma mark Convenience Methods
+ (NSCalendarDate *)calendarDateFromDarcsDateString:(NSString *)dateString;
+ (NSCalendarDate *)calendarDateFromOldDarcsDateString:(NSString *)dateString;

#pragma mark Accessor Methods
- (void)setName:(NSString *)newName;
- (void)setAuthor:(NSString *)newAuthor;
- (void)setDate:(NSCalendarDate *)newDate;
- (void)setRollbackPatch:(BOOL)isRollbackPatch;

@end
