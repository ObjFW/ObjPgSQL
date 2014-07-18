#import "PGException.h"

@interface PGCommandFailedException: PGException
{
	OFString *_command;
}

#ifdef OF_HAVE_PROPERTIES
@property (readonly, copy, nonatomic) OFString *command;
#endif

+ (instancetype)exceptionWithConnection: (PGConnection*)connection
				command: (OFString*)command;
- initWithConnection: (PGConnection*)connection
	     command: (OFString*)command;
- (OFString*)command;
@end
