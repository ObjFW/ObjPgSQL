#import <ObjFW/ObjFW.h>

#import "PGConnection.h"

@interface PGException: OFException
{
	PGConnection *_connection;
	OFString *_error;
}

@property (readonly, retain) PGConnection *connection;

+ (instancetype)exceptionWithConnection: (PGConnection*)connection;
- initWithConnection: (PGConnection*)connection;
@end
