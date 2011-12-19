//
//  PWGzipFileReader.h
//  Patchworks
//
//  Created by Jonathon Mah on 2006-01-09.
//  Copyright 2006 Playhaus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PWReader.h"
#import <zlib.h>


@interface PWGzipFileReader : NSObject <PWReader>
{
	@protected
	gzFile PW_gzFile;
	NSStringEncoding PW_fileEncoding;
	BOOL PW_isFullFileCached;
	z_off_t PW_currCachedOffset;
	NSMutableString *PW_cachedFileContent;
	unsigned int PW_cachedFileContentEndIndex;
	NSString *PW_lastLine;
	NSString *PW_rewoundLine;
	BOOL PW_isLastLineInCache;
}


#pragma mark Initialization and Deallocation
- (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)encoding error:(NSError **)outError;
- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)encoding error:(NSError **)outError; // Designated initializer

@end
