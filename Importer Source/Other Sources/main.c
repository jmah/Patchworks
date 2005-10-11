//
//  main.c
//  Patchworks Importer
//
//  Created by Jonathon Mah on 2005-09-30.
//  Copyright (c) 2005 Playhaus. All rights reserved.
//  License information is contained at the bottom of this file and in the
//  'LICENSE.txt' file.
//

#include <CoreFoundation/CoreFoundation.h>
#include <CoreFoundation/CFPlugInCOM.h>
#include <CoreServices/CoreServices.h>


/*
 * This is the default file provided by the Spotlight Importer project
 * template, edited to fit in more with the project's coding style.
 */


#pragma mark Constants

#define PLUGIN_ID "418D378D-EA9E-4B56-98AE-0B19AE279A90"


//
// Below is the generic glue code for all plug-ins.
//
// You should not have to modify this code aside from changing names if you
// decide to change the names defined in the Info.plist.
//



#pragma mark Typedefs

// The layout for an instance of MetaDataImporterPlugIn 
typedef struct __MetadataImporterPluginType
{
	MDImporterInterfaceStruct *conduitInterface;
	CFUUIDRef factoryID;
	UInt32 refCount;
} MetadataImporterPluginType;



#pragma mark Prototypes

// The import function to be implemented in GetMetadataForFile.m
Boolean GetMetadataForFile(void *thisInterface,
                           CFMutableDictionaryRef attributes,
                           CFStringRef contentTypeUTI,
                           CFStringRef pathToFile);

MetadataImporterPluginType *AllocMetadataImporterPluginType(CFUUIDRef inFactoryID);
void DeallocMetadataImporterPluginType(MetadataImporterPluginType *thisInstance);
HRESULT MetadataImporterQueryInterface(void *thisInstance, REFIID iid, LPVOID *ppv);
void *MetadataImporterPluginFactory(CFAllocatorRef allocator, CFUUIDRef typeID);
ULONG MetadataImporterPluginAddRef(void *thisInstance);
ULONG MetadataImporterPluginRelease(void *thisInstance);



#pragma mark Implementations

// The TestInterface function table.
static MDImporterInterfaceStruct testInterfaceFtbl = {
	NULL,
	MetadataImporterQueryInterface,
	MetadataImporterPluginAddRef,
	MetadataImporterPluginRelease,
	GetMetadataForFile
};


// Utility function that allocates a new instance.
//   You can do some initial setup for the importer here if you wish like
//   allocating globals etc...

MetadataImporterPluginType *AllocMetadataImporterPluginType(CFUUIDRef inFactoryID)
{
	MetadataImporterPluginType *theNewInstance = (MetadataImporterPluginType *)malloc(sizeof(MetadataImporterPluginType));
	memset(theNewInstance, 0, sizeof(MetadataImporterPluginType));
	
	/* Point to the function table */
	theNewInstance->conduitInterface = &testInterfaceFtbl;
	
	/* Retain and keep an open instance refcount for each factory. */
	theNewInstance->factoryID = CFRetain(inFactoryID);
	CFPlugInAddInstanceForFactory(inFactoryID);
	
	/* This function returns the IUnknown interface so set the refCount to one. */
	theNewInstance->refCount = 1;
	return theNewInstance;
}


// Utility function that deallocates the instance when the refCount goes to
// zero.
//   In the current implementation importer interfaces are never deallocated but
//   implement this as this might change in the future

void DeallocMetadataImporterPluginType(MetadataImporterPluginType *thisInstance)
{
	CFUUIDRef theFactoryID = thisInstance->factoryID;
	free(thisInstance);
	
	if (theFactoryID)
	{
		CFPlugInRemoveInstanceForFactory(theFactoryID);
		CFRelease(theFactoryID);
	}
}


// Implementation of the IUnknown QueryInterface function.

HRESULT MetadataImporterQueryInterface(void *thisInstance, REFIID iid, LPVOID *ppv)
{
	CFUUIDRef interfaceID = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault, iid);
	
	if (CFEqual(interfaceID, kMDImporterInterfaceID) || CFEqual(interfaceID, IUnknownUUID))
	{
		/*
		 * If the right interface was requested, bump the ref count, set the ppv
		 * parameter equal to the instance, and return good status.
		 */
		((MetadataImporterPluginType *)thisInstance)->conduitInterface->AddRef(thisInstance);
		*ppv = thisInstance;
		CFRelease(interfaceID);
		return S_OK;
	}
	else
	{
		/* Requested interface unknown, bail with error. */
		*ppv = NULL;
		CFRelease(interfaceID);
		return E_NOINTERFACE;
	}
}


// Implementation of reference counting for this type. Whenever an interface is
// requested, bump the refCount for the instance. NOTE: returning the refcount
// is a convention but is not required so don't rely on it.

ULONG MetadataImporterPluginAddRef(void *thisInstance)
{
	((MetadataImporterPluginType *)thisInstance )->refCount += 1;
	return ((MetadataImporterPluginType *)thisInstance)->refCount;
}


// When an interface is released, decrement the refCount.
// If the refCount goes to zero, deallocate the instance.

ULONG MetadataImporterPluginRelease(void *thisInstance)
{
	((MetadataImporterPluginType *)thisInstance)->refCount -= 1;
	
	if (((MetadataImporterPluginType *)thisInstance)->refCount == 0)
	{
		DeallocMetadataImporterPluginType((MetadataImporterPluginType *)thisInstance);
		return 0;
	}
	else
		return ((MetadataImporterPluginType *)thisInstance)->refCount;
}


// Implementation of the factory function for this type.

void *MetadataImporterPluginFactory(CFAllocatorRef allocator, CFUUIDRef typeID)
{
	MetadataImporterPluginType *result;
	CFUUIDRef uuid;
	
	/*
	 * If correct type is being requested, allocate an instance of TestType and
	 * return the IUnknown interface.
	 */
	if (CFEqual(typeID, kMDImporterTypeID))
	{
		uuid = CFUUIDCreateFromString(kCFAllocatorDefault, CFSTR(PLUGIN_ID));
		result = AllocMetadataImporterPluginType(uuid);
		CFRelease(uuid);
		return result;
	}
	else
		/* If the requested type is incorrect, return NULL. */
		return NULL;
}



/*
 * Patchworks is licensed under the BSD license, as follows:
 * 
 * Copyright (c) 2005, Playhaus
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice, this
 *   list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the Playhaus nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without
 *   specific prior written permission.
 * 
 * This software is provided by the copyright holders and contributors "as is"
 * and any express or implied warranties, including, but not limited to, the
 * implied warranties of merchantability and fitness for a particular purpose
 * are disclaimed. In no event shall the copyright owner or contributors be
 * liable for any direct, indirect, incidental, special, exemplary, or
 * consequential damages (including, but not limited to, procurement of
 * substitute goods or services; loss of use, data, or profits; or business
 * interruption) however caused and on any theory of liability, whether in
 * contract, strict liability, or tort (including negligence or otherwise)
 * arising in any way out of the use of this software, even if advised of the
 * possibility of such damage.
 */
