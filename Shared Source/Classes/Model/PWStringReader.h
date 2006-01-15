//
//  PWStringReader.h
//  Patchworks
//
//  Created by Jonathon Mah on 2006-01-15.
//  Copyright 2006 Playhaus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PWReader.h"


@interface PWStringReader : NSObject <PWReader>
{
	@protected
	NSString *PW_string;
	unsigned int PW_cachedIndex;
	unsigned int PW_currReadIndex;
	BOOL PW_hasRewoundLine;
	unsigned int PW_lastLineLength;
	BOOL PW_isLastLineInCache;
}


#pragma mark Initialization and Deallocation
- (id)initWithString:(NSString *)string; // Designated initializer

@end
