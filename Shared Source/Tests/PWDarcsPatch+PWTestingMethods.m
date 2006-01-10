//
//  PWDarcsPatch+PWTestingMethods.m
//  Patchworks
//
//  Created by Jonathon Mah on 2005-10-08.
//  Copyright 2005 Playhaus. All rights reserved.
//

#import "PWDarcsPatch+PWTestingMethods.h"
#import "PWDarcsPatch+PWProtectedMethods.h"


@implementation PWDarcsPatch (PWTestingMethods)

#pragma mark Initialization and Deallocation

- (id)initWithName:(NSString *)name author:(NSString *)author date:(NSCalendarDate *)date
{
	if (self = [super init])
	{
		[self setName:name];
		[self setAuthor:author];
		[self setDate:date];
	}
	return self;
}


@end
