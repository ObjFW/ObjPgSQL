#import "PGException.h"

@implementation PGException
+ exceptionWithClass: (Class)class
	  connection: (PGConnection*)connection
{
	return [[[self alloc] initWithClass: class
				 connection: connection] autorelease];
}

- initWithClass: (Class)class
     connection: (PGConnection*)connection
{
	self = [super initWithClass: class];

	_connection = [connection retain];

	return self;
}

- (void)dealloc
{
	[_connection release];

	[super dealloc];
}

- (OFString*)description
{
	return [OFString stringWithFormat:
	    @"A PostgreSQL operation in class %@ failed: %s", [self inClass],
	    PQerrorMessage([_connection PG_connection])];
}

- (PGConnection*)connection
{
	OF_GETTER(_connection, NO)
}
@end
