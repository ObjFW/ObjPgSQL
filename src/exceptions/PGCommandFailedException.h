#import "PGException.h"

OF_ASSUME_NONNULL_BEGIN

@interface PGCommandFailedException: PGException
{
	OFString *_command;
}

@property (readonly, nonatomic) OFString *command;

+ (instancetype)exceptionWithConnection: (PGConnection *)connection
				command: (OFString *)command;
- initWithConnection: (PGConnection *)connection
	     command: (OFString *)command;
@end

OF_ASSUME_NONNULL_END
