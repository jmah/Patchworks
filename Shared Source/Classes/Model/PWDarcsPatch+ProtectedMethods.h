//
//  PWDarcsPatch+ProtectedMethods.h
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-08.
//  Copyright 2005 Playhaus. All rights reserved.
//

#import "PWDarcsPatch.h"


// Methods for use by concrete subclasses of PWDarcsPatch

@interface PWDarcsPatch (ProtectedMethods)

#pragma mark Accessor Methods
- (void)setName:(NSString *)newName;
- (void)setAuthor:(NSString *)newAuthor;
- (void)setDate:(NSCalendarDate *)newDate;

@end
