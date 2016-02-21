#import "PGCommandFailedException.h"

@implementation PGCommandFailedException
@synthesize command = _command;

+ (instancetype)exceptionWithConnection: (PGConnection*)connection
				command: (OFString*)command
{
	return [[[self alloc] initWithConnection: connection
					 command: command] autorelease];
}

- initWithConnection: (PGConnection*)connection
	     command: (OFString*)command
{
	self = [super initWithConnection: connection];

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
	return [OFString stringWithFormat: @"A PostgreSQL command failed: %@\n"
					   @"Command: %@", _error, _command];
}
@end
