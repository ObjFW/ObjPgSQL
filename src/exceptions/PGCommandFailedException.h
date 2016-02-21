#import "PGException.h"

@interface PGCommandFailedException: PGException
{
	OFString *_command;
}

@property (readonly, copy) OFString *command;

+ (instancetype)exceptionWithConnection: (PGConnection*)connection
				command: (OFString*)command;
- initWithConnection: (PGConnection*)connection
	     command: (OFString*)command;
@end
