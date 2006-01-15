//
//  PWReader.h
//  Patchworks
//
//  Created by Jonathon Mah on 2006-01-15.
//  Copyright 2006 Playhaus. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol PWReader

#pragma mark Reading
/*
 * Returns YES if the entire content has been read and cached. If this returns
 * YES, both -cachedContent and -fullContent will return the same NSString
 * object.
 */
- (BOOL)isEntireContentRead;

/*
 * Returns the current cached text that has been read. This text has been read
 * with the method -readNextLine:YES.
 */
- (NSString *)cachedContent;

/*
 * Reads and caches the remainder of the content, if necessary, and returns
 * it.  After calling this method, -isEntireContentRead will return YES.
 */
- (NSString *)fullContent;

/*
 * Reads and returns the next line. If YES is passed as an argument, the line
 * will be cached. If not, it will be returned uncached. If -readNextLine: is
 * asked to cache a line after some uncached reads, the text up until the
 * current line will first be cached. If -isEntireContentRead returns YES,
 * -readNextLine: will return nil, but will first honor the caching argument.
 */
- (NSString *)readNextLine:(BOOL)cacheText;

/*
 * Returns the current character index of the reader. The first character of
 * the next line read will have this index in the content. That is,
 * unsigned int prevIndex = [reader currentIndex];
 * [[reader readNextLine:YES] characterAtIndex:0];
 * returns the same character as:
 * [[reader fullContent] characterAtIndex:prevIndex].
 */
- (unsigned int)currentIndex;

/*
 * Caches the content from the beginning until the given index. If this
 * portion has already been cached, no action will be taken.  The index
 * argument must not be longer than the length of the content.
 */
- (void)cacheUpToIndex:(unsigned int)index;

/*
 * Removes the last line from the cache (if necessary), and ensures that the
 * next call to -readNextLine: will return the last line read. -rewindLine can
 * only be called once consecutively. If -rewindLine succeeded, it will return
 * YES. It will return NO if called more than once consecutively, or if at the
 * beginning of the file. Calling -rewindLine may cause the value of
 * -isEntireContentRead to change from YES to NO.
 */
- (BOOL)rewindLine;

@end
