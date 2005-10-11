//
//  PWDarcsPatch+TestingMethods.h
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-08.
//  Copyright 2005 Playhaus. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PWDarcsPatch.h"


@interface PWDarcsPatch (TestingMethods)

#pragma mark Initialization and Deallocation
- (id)initWithName:(NSString *)name author:(NSString *)author date:(NSCalendarDate *)date;

@end
