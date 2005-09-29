#import <CoreFoundation/CoreFoundation.h>
#import <CoreServices/CoreServices.h> 

/*
 * -----------------------------------------------------------------------------
 * If you have defined new attributes, update the schema.xml file
 *
 * Edit the schema.xml file to include the metadata keys that your importer returns.
 * Add them to the <allattrs> and <displayattrs> elements.
 *
 * Add any custom types that your importer requires to the <attributes> element
 *
 * <attribute name="com_mycompany_metadatakey" type="CFString" multivalued="true"/>
 *
 * -----------------------------------------------------------------------------
 */



// This function's job is to extract useful information your file format
// supports and add it to a dictionary

Boolean GetMetadataForFile(void *thisInterface,
                           CFMutableDictionaryRef attributes,
                           CFStringRef contentTypeUTI,
                           CFStringRef pathToFile)
{
	/* Pull any available metadata from the file at the specified path */
	/* Return the attribute keys and attribute values in the dict */
	/* Return TRUE if successful, FALSE if there was no data provided */
	
	#warning To complete your importer please implement the function GetMetadataForFile in GetMetadataForFile.m
	
	return FALSE;
}
