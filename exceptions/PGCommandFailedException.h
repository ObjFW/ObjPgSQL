#import "PGException.h"

@interface PGCommandFailedException: PGException
{
	OFString *_command;
}

#ifdef OF_HAVE_PROPERTIES
@property (readonly, copy, nonatomic) OFString *command;
#endif

+ exceptionWithClass: (Class)class_
	  connection: (PGConnection*)connection
	     command: (OFString*)command;
- initWithClass: (Class)class_
     connection: (PGConnection*)connection
	command: (OFString*)command;
- (OFString*)command;
@end
