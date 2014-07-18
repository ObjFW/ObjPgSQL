#import <ObjFW/ObjFW.h>

#import "PGConnection.h"

@interface PGException: OFException
{
	PGConnection *_connection;
	OFString *_error;
}

#ifdef OF_HAVE_PROPERTIES
@property (readonly, retain, nonatomic) PGConnection *connection;
#endif

+ (instancetype)exceptionWithConnection: (PGConnection*)connection;
- initWithConnection: (PGConnection*)connection;
- (PGConnection*)connection;
@end
