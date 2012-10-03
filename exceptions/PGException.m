#import "PGException.h"

@implementation PGException
+ exceptionWithClass: (Class)class
	  connection: (PGConnection*)connection
{
	return [[[self alloc] initWithClass: class
				 connection: connection] autorelease];
}

- initWithClass: (Class)class_
     connection: (PGConnection*)connection_
{
	self = [super initWithClass: class_];

	connection = [connection_ retain];

	return self;
}

- (void)dealloc
{
	[connection release];

	[super dealloc];
}

- (OFString*)description
{
	if (description != nil)
		return description;

	description = [[OFString alloc] initWithFormat:
	    @"A PostgreSQL operation in class %@ failed: %s", inClass,
	    PQerrorMessage([connection PG_connection])];

	return description;
}

- (PGConnection*)connection
{
	OF_GETTER(connection, NO)
}
@end
