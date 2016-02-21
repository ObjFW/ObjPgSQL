#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

@interface PGConnection: OFObject
{
	PGconn *_connnection;
	OFDictionary *_parameters;
}

@property (copy) OFDictionary *parameters;

- (void)connect;
- (void)reset;
- (void)close;
- (PGResult*)executeCommand: (OFConstantString*)command;
- (PGResult*)executeCommand: (OFConstantString*)command
		 parameters: (id)firstParameter, ... OF_SENTINEL;
- (PGconn*)PG_connection;
- (void)insertRow: (OFDictionary*)row
	intoTable: (OFString*)table;
- (void)insertRows: (OFArray*)rows
	 intoTable: (OFString*)table;
@end