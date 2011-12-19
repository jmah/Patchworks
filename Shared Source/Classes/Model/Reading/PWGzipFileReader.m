//
//  PWGzipFileReader.m
//  Patchworks
//
//  Created by Jonathon Mah on 2006-01-09.
//  Copyright 2006 Playhaus. All rights reserved.
//

#import "PWGzipFileReader.h"


#define LINE_BUFFER_LENGTH 256
#define FULL_BUFFER_LENGTH 16384


@implementation PWGzipFileReader

#pragma mark Initialization and Deallocation

- (id)initWithContentsOfFile:(NSString *)path encoding:(NSStringEncoding)encoding error:(NSError **)outError
{
	return [self initWithContentsOfURL:[NSURL fileURLWithPath:path] encoding:encoding error:outError];
}


- (id)initWithContentsOfURL:(NSURL *)url encoding:(NSStringEncoding)encoding error:(NSError **)outError // Designated initializer
{
	if (self = [super init])
	{
		if (![[NSFileManager defaultManager] isReadableFileAtPath:[url path]])
		{
			[self release];
			*outError = [NSError errorWithDomain:NSCocoaErrorDomain
			                                code:NSFileReadNoSuchFileError
			                            userInfo:nil];
			return nil;
		}
		
		PW_gzFile = gzopen([[url path] cStringUsingEncoding:NSUTF8StringEncoding], "rb");
		if (!PW_gzFile)
		{
			[self release];
			*outError = [NSError errorWithDomain:NSCocoaErrorDomain
			                                code:NSFileReadUnknownError
			                            userInfo:nil];
			return nil;
		}
		
		PW_fileEncoding = encoding;
		PW_isFullFileCached = NO;
		PW_currCachedOffset = 0;
		PW_cachedFileContent = [[NSMutableString alloc] init];
		PW_cachedFileContentEndIndex = 0;
		PW_lastLine = nil;
		PW_rewoundLine = nil;
		PW_isLastLineInCache = YES;
	}
	return self;
}


- (void)dealloc
{
	if (PW_gzFile != Z_NULL)
	{
		gzclose(PW_gzFile);
		PW_gzFile = Z_NULL;
	}
	
	[PW_cachedFileContent release];
	PW_cachedFileContent = nil;
	
	[PW_lastLine release];
	PW_lastLine = nil;
	
	[PW_rewoundLine release];
	PW_rewoundLine = nil;
	
	[super dealloc];
}



#pragma mark Reading <PWReader>

- (BOOL)isEntireContentRead // <PWReader>
{
	return (PW_isFullFileCached && !PW_rewoundLine);
}


- (NSString *)cachedContent // <PWReader>
{
	return [PW_cachedFileContent substringToIndex:PW_cachedFileContentEndIndex];
}


- (NSString *)fullContent // <PWReader>
{
	if (PW_isFullFileCached)
		PW_cachedFileContentEndIndex = [PW_cachedFileContent length];
	else
	{
		z_off_t currOffset = gzseek(PW_gzFile, PW_currCachedOffset, SEEK_SET);
		NSAssert(currOffset != -1, @"Error seeking in gzip file.");
		
		NSMutableData *remainingData = [[NSMutableData alloc] initWithLength:0];
		while (!gzeof(PW_gzFile))
		{
			unsigned int oldLength = [remainingData length];
			[remainingData setLength:([remainingData length] + FULL_BUFFER_LENGTH)];
			void *readBuffer = [remainingData mutableBytes];
			readBuffer += oldLength;
			
			int byteCount = gzread(PW_gzFile, readBuffer, FULL_BUFFER_LENGTH);
			NSAssert(byteCount != -1, @"Error reading patch");
			if (byteCount < FULL_BUFFER_LENGTH)
				[remainingData setLength:([remainingData length] - (FULL_BUFFER_LENGTH - byteCount))];
		}
		PW_currCachedOffset = gztell(PW_gzFile);
		gzclose(PW_gzFile);
		PW_gzFile = Z_NULL;
		
		NSString *remainingString = [[NSString alloc] initWithData:remainingData encoding:PW_fileEncoding];
		[PW_cachedFileContent appendString:remainingString];
		[remainingData release];
		[remainingString release];
		
		[PW_lastLine release];
		PW_lastLine = nil;
		
		[PW_rewoundLine release];
		PW_rewoundLine = nil;
		
		PW_isFullFileCached = YES;
		PW_cachedFileContentEndIndex = [PW_cachedFileContent length];
		PW_isLastLineInCache = YES;
	}
	
	return [self cachedContent];
}


- (NSString *)readNextLine:(BOOL)cacheText // <PWReader>
{
	if ([self isEntireContentRead])
		return nil;
	
	if (cacheText && (PW_currCachedOffset != gztell(PW_gzFile)))
		[self cacheUpToIndex:([self currentIndex] + [PW_lastLine length])];
	
	if (PW_rewoundLine)
	{
		[PW_lastLine release];
		PW_lastLine = PW_rewoundLine;
		PW_rewoundLine = nil;
		if (cacheText)
		{
			PW_isLastLineInCache = YES;
			PW_cachedFileContentEndIndex = [PW_cachedFileContent length];
		}
	}
	else
	{
		if (gzeof(PW_gzFile))
			return nil;
		
		NSMutableString *lineString = [NSMutableString string];
		char lineBuffer[LINE_BUFFER_LENGTH];
		char *line;
		BOOL readFullLine = NO;
		
		while (!readFullLine)
		{
			line = gzgets(PW_gzFile, lineBuffer, LINE_BUFFER_LENGTH);
			// zlib.h says gzgets should never return Z_NULL, but this can often signal the end-of-file, so we need to check it here
			if (line == Z_NULL)
			{
				if (gzeof(PW_gzFile))
					readFullLine = YES;
				else
					NSAssert(line != Z_NULL, @"Failed to read line from gzip file.");
			}
			else
			{
				[lineString appendString:[NSString stringWithCString:line encoding:PW_fileEncoding]];
				char lastChar = line[strlen(line) - 1];
				if (lastChar == '\n')
					readFullLine = YES;
			}
		}
		
		[PW_lastLine release];
		PW_lastLine = [lineString retain];
		
		if (cacheText)
		{
			[PW_cachedFileContent appendString:PW_lastLine];
			PW_cachedFileContentEndIndex = [PW_cachedFileContent length];
			PW_isLastLineInCache = YES;
			PW_currCachedOffset = gztell(PW_gzFile);
			
			if (gzeof(PW_gzFile))
			{
				gzclose(PW_gzFile);
				PW_gzFile = Z_NULL;
				
				PW_isFullFileCached = YES;
			}
		}
		else
			PW_isLastLineInCache = NO;
	}
	
	return PW_lastLine;
}


- (unsigned int)currentIndex // <PWReader>
{
	unsigned int index;
	if (PW_gzFile)
#warning This assumes there is a one-to-one relationship between characters and bytes, which is not true
		index = (unsigned int)gztell(PW_gzFile);
	else
		index = [PW_cachedFileContent length];
	
	if (PW_rewoundLine)
		index -= [PW_lastLine length];
	
	return index;
}


- (void)cacheUpToIndex:(unsigned int)index // <PWReader>
{
#warning This assumes there is a one-to-one relationship between characters and bytes, which is not true
	z_off_t offset = index;
	if (offset > PW_currCachedOffset)
	{
		z_off_t currOffset = gzseek(PW_gzFile, PW_currCachedOffset, SEEK_SET);
		NSAssert(currOffset != -1, @"Error seeking in gzip file.");
		
		long remainingLength = offset - currOffset;
		NSMutableData *data = [[NSMutableData alloc] initWithLength:remainingLength];
		void *readBuffer = [data mutableBytes];
		int byteCount = gzread(PW_gzFile, readBuffer, remainingLength);
		NSAssert(byteCount != -1, @"Error reading gzip file.");
		
		NSString *newString = [[NSString alloc] initWithData:data encoding:PW_fileEncoding];
		[PW_cachedFileContent appendString:newString];
		[data release];
		[newString release];
		
		PW_currCachedOffset = gztell(PW_gzFile);
		
		NSAssert(PW_currCachedOffset == offset, @"Offsets should be equal after reading.");
		
		if (gzeof(PW_gzFile))
		{
			gzclose(PW_gzFile);
			PW_gzFile = Z_NULL;
			
			[PW_lastLine release];
			PW_lastLine = nil;
			
			PW_isFullFileCached = YES;
			PW_cachedFileContentEndIndex = [PW_cachedFileContent length];
			PW_isLastLineInCache = YES;
		}
	}
}


- (BOOL)rewindLine // <PWReader>
{
	BOOL success = NO;
	
	if (!PW_rewoundLine && PW_lastLine)
	{
		if (PW_isLastLineInCache)
			PW_cachedFileContentEndIndex = [PW_cachedFileContent length] - [PW_lastLine length];
		PW_rewoundLine = [PW_lastLine retain];
		success = YES;
	}
	
	return success;
}


@end
