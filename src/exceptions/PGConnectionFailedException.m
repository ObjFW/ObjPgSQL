#import "PGConnectionFailedException.h"

@implementation PGConnectionFailedException
- (OFString *)description
{
	return [OFString stringWithFormat:
	    @"Establishing a PostgreSQL connection failed:\n%@\n"
	    "Parameters: %@", _error, [_connection parameters]];
}
@end
