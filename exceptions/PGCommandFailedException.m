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

- initWithClass: (Class)class_
     connection: (PGConnection*)connection_
	command: (OFString*)command_
{
	self = [super initWithClass: class_
			 connection: connection_];

	@try {
		command = [command_ copy];
	} @catch (id e) {
		[self release];
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	[command release];

	[super dealloc];
}

- (OFString*)description
{
	if (description != nil)
		return description;

	description = [[OFString alloc] initWithFormat:
	    @"A PostgreSQL command in class %@ failed: %s\nCommand: %@",
	    inClass, PQerrorMessage([connection PG_connection]), command];

	return description;
}

- (OFString*)command
{
	OF_GETTER(command, NO)
}
@end
