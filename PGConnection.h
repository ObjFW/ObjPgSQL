#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

@interface PGConnection: OFObject
{
	PGconn *conn;
	OFDictionary *parameters;
}

#ifdef OF_HAVE_PROPERTIES
@property (copy) OFDictionary *parameters;
#endif

- (void)setParameters: (OFDictionary*)parameters;
- (OFDictionary*)parameters;
- (void)connect;
- (void)reset;
- (PGResult*)executeCommand: (OFString*)command;
- (PGResult*)executeCommand: (OFString*)command
		 parameters: (id)firstParameter, ...;
- (PGconn*)PG_connection;
- (void)insertRow: (OFDictionary*)row
	intoTable: (OFString*)table;
- (void)insertRows: (OFArray*)rows
	 intoTable: (OFString*)table;
@end
