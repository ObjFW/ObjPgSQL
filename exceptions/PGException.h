#import <ObjFW/ObjFW.h>

#import "PGConnection.h"

@interface PGException: OFException
{
	PGConnection *_connection;
}

#ifdef OF_HAVE_PROPERTIES
@property (readonly, retain, nonatomic) PGConnection *connection;
#endif

+ exceptionWithClass: (Class)class_
	  connection: (PGConnection*)connection;
- initWithClass: (Class)class_
     connection: (PGConnection*)connection;
- (PGConnection*)connection;
@end
