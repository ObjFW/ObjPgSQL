#import <ObjFW/ObjFW.h>

#import "PGConnection.h"

OF_ASSUME_NONNULL_BEGIN

@interface PGException: OFException
{
	PGConnection *_connection;
	OFString *_error;
}

@property (readonly, nonatomic) PGConnection *connection;

+ (instancetype)exceptionWithConnection: (PGConnection *)connection;
- initWithConnection: (PGConnection *)connection;
@end

OF_ASSUME_NONNULL_END
