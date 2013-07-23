#import "PGException.h"

@implementation PGException
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
			   encoding: OF_STRING_ENCODING_NATIVE];
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

- (PGConnection*)connection
{
	OF_GETTER(_connection, NO)
}
@end
