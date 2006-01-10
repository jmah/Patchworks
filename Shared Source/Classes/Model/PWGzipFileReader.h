//

//  PWGzipFileReader.h
//  Patchworks
//
//  Created by Jonathon Mah on 2006-01-09.
//  Copyright 2006 Playhaus. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <zlib.h>


@interface PWGzipFileReader : NSObject
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
	unsigned int PW_lastLineLength;
}


#pragma mark Initialization and Deallocation
- (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)encoding error:(NSError **)outError;
- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)encoding error:(NSError **)outError; // Designated initializer

#pragma mark Reading
/*
 * Returns YES if the entire content of the gzip file has been read and
 * cached. If this returns true, both -cachedFileContent and -fullFileContent
 * will return the same NSString object.
 */
- (BOOL)isFullFileRead;

/*
 * Returns the current cached text that has been read from the file. This text
 * has been read with the method -readNextLine:YES.
 */
- (NSString *)cachedFileContent;

/*
 * Reads and caches the remainder of the file, if necessary, and returns it.
 * After calling this method, -isFullFileRead will return YES.
 */
- (NSString *)fullFileContent;

/*
 * Reads and returns the next line in the file. If YES is passed as an
 * argument, the read line will be cached. If not, it will be returned
 * uncached. If -readNextLine: is asked to cache a line after some uncached
 * reads, the text up until the current line will first be cached. If
 * -isFullFileRead returns YES, -readNextLine: will return nil, but will first
 *  honor the caching argument.
 */
- (NSString *)readNextLine:(BOOL)cacheText;

/*
 * Removes the last line from the cache (if necessary), and ensures that the
 * next call to -readNextLine: will return the last line read. -rewindLine can
 * only be calledonce consecutively. If -rewindLine succeeded, it will return
 * YES. It will return NO if called more than once consecutively, or if at the
 * beginning of the file. Calling -rewindLine can cause the value of
 * -isFullFileRead to change from YES to NO.
 */
- (BOOL)rewindLine;

@end
