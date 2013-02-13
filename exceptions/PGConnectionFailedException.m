#import "PGConnectionFailedException.h"

@implementation PGConnectionFailedException
- (OFString*)description
{
	return [OFString stringWithFormat:
	    @"Establishing a PostgreSQL connection in class %@ failed:\n%s\n"
	    "Parameters: %@", [self inClass],
	    PQerrorMessage([_connection PG_connection]),
	    [_connection parameters]];
}
@end
