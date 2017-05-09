#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

OF_ASSUME_NONNULL_BEGIN

@interface PGConnection: OFObject
{
	PGconn *_connnection;
	OFDictionary OF_GENERIC(OFString *, OFString *) *_parameters;
}

@property (nonatomic, copy)
    OFDictionary OF_GENERIC(OFString *, OFString *) *parameters;

- (void)connect;
- (void)reset;
- (void)close;
- (PGResult *)executeCommand: (OFConstantString *)command;
- (PGResult *)executeCommand: (OFConstantString *)command
		  parameters: (id)firstParameter, ... OF_SENTINEL;
- (PGconn *)PG_connection;
- (void)insertRow: (OFDictionary *)row
	intoTable: (OFString *)table;
- (void)insertRows: (OFArray OF_GENERIC(OFDictionary *) *)rows
	 intoTable: (OFString *)table;
@end

OF_ASSUME_NONNULL_END
