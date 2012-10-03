#import "PGConnection.h"

#import "PGConnectionFailedException.h"
#import "PGCommandFailedException.h"

@implementation PGConnection
- (void)dealloc
{
	[parameters release];

	if (conn != NULL)
		PQfinish(conn);

	[super dealloc];
}

- (void)setParameters: (OFDictionary*)parameters_
{
	OF_SETTER(parameters, parameters_, YES, YES)
}

- (OFDictionary*)parameters
{
	OF_GETTER(parameters, YES)
}

- (void)connect
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFEnumerator *keyEnumerator = [parameters keyEnumerator];
	OFEnumerator *objectEnumerator = [parameters objectEnumerator];
	OFMutableString *conninfo = nil;
	OFString *key, *object;

	while ((key = [keyEnumerator nextObject]) != nil &&
	    (object = [objectEnumerator nextObject]) != nil) {
		if (conninfo != nil)
			[conninfo appendFormat: @" %@=%@", key, object];
		else
			conninfo = [OFMutableString stringWithFormat:
			    @"%@=%@", key, object];
	}

	if ((conn = PQconnectdb([conninfo UTF8String])) == NULL)
		@throw [OFOutOfMemoryException
		    exceptionWithClass: [self class]];

	if (PQstatus(conn) == CONNECTION_BAD)
		@throw [PGConnectionFailedException
		    exceptionWithClass: [self class]
			    connection: self];

	[pool release];
}

- (void)reset
{
	PQreset(conn);
}

- (PGResult*)executeCommand: (OFString*)command
{
	PGresult *result = PQexec(conn, [command UTF8String]);

	if (PQresultStatus(result) == PGRES_FATAL_ERROR) {
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithClass: [self class]
			    connection: self
			       command: command];
	}

	if (PQresultStatus(result) == PGRES_TUPLES_OK)
		return [PGResult PG_resultWithResult: result];

	PQclear(result);
	return nil;
}

- (PGResult*)executeCommand: (OFString*)command
		 parameters: (OFArray*)parameters_
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	PGresult *result;
	const char **values;

	values = [self allocMemoryWithSize: sizeof(*values)
				     count: [parameters_ count]];
	@try {
		OFEnumerator *enumerator = [parameters_ objectEnumerator];
		size_t i = 0;
		id parameter;

		while ((parameter = [enumerator nextObject]) != nil) {
			if ([parameter isKindOfClass: [OFNull class]])
				values[i++] = NULL;
			else
				values[i++] = [parameter UTF8String];
		}

		result = PQexecParams(conn, [command UTF8String],
		    [parameters_ count], NULL, values, NULL, NULL, 0);
	} @finally {
		[self freeMemory: values];
	}

	[pool release];

	if (PQresultStatus(result) == PGRES_FATAL_ERROR) {
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithClass: [self class]
			    connection: self
			       command: command];
	}

	if (PQresultStatus(result) == PGRES_TUPLES_OK)
		return [PGResult PG_resultWithResult: result];

	PQclear(result);
	return nil;
}

- (PGconn*)PG_connection
{
	return conn;
}
@end
