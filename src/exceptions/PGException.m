#import "PGException.h"

@implementation PGException
@synthesize connection = _connection;

+ (instancetype)exceptionWithConnection: (PGConnection*)connection
{
	return [[[self alloc] initWithConnection: connection] autorelease];
}

- initWithConnection: (PGConnection*)connection
{
	self = [super init];

	@try {
		_connection = [connection retain];
		_error = [[OFString alloc]
		    initWithCString: PQerrorMessage([_connection PG_connection])
			   encoding: [OFSystemInfo native8BitEncoding]];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_connection release];
	[_error release];

	[super dealloc];
}

- (OFString*)description
{
	return [OFString stringWithFormat: @"A PostgreSQL operation failed: %@",
					   _error];
}
@end
