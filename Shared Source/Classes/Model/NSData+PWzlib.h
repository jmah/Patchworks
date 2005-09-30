//
//  NSData+PWzlib.h
//  Patchworks
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright 2005 Playhaus. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSData (PWzlib)

#pragma mark zlib Extensions
- (NSData *)inflate;
- (NSData *)deflate;

@end
