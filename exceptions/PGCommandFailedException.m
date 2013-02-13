#import "PGCommandFailedException.h"

@implementation PGCommandFailedException
+ exceptionWithClass: (Class)class
	  connection: (PGConnection*)connection
	     command: (OFString*)command
{
	return [[[self alloc] initWithClass: class
				 connection: connection
				    command: command] autorelease];
}

- initWithClass: (Class)class
     connection: (PGConnection*)connection
	command: (OFString*)command
{
	self = [super initWithClass: class
			 connection: connection];

	@try {
		_command = [command copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[_command release];

	[super dealloc];
}

- (OFString*)description
{
	return [OFString stringWithFormat:
	    @"A PostgreSQL command in class %@ failed: %s\nCommand: %@",
	    [self inClass], PQerrorMessage([_connection PG_connection]),
	    _command];
}

- (OFString*)command
{
	OF_GETTER(_command, NO)
}
@end
