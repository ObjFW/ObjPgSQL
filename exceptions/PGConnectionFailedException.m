#import "PGConnectionFailedException.h"

@implementation PGConnectionFailedException
- (OFString*)description
{
	OFAutoreleasePool *pool;

	if (description != nil)
		return description;

	pool = [[OFAutoreleasePool alloc] init];
	description = [[OFString alloc] initWithFormat:
	    @"Establishing a PostgreSQL connection in class %@ failed:\n%s\n"
	    "Parameters: %@", inClass,
	    PQerrorMessage([connection PG_connection]),
	    [connection parameters]];
	[pool release];

	return description;
}
@end
