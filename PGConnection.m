#import "PGConnection.h"

#import "PGConnectionFailedException.h"
#import "PGCommandFailedException.h"

@implementation PGConnection
- (void)dealloc
{
	[_parameters release];

	[self close];

	[super dealloc];
}

- (void)setParameters: (OFDictionary*)parameters
{
	OF_SETTER(_parameters, parameters, YES, YES)
}

- (OFDictionary*)parameters
{
	OF_GETTER(_parameters, YES)
}

- (void)connect
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFEnumerator *keyEnumerator = [_parameters keyEnumerator];
	OFEnumerator *objectEnumerator = [_parameters objectEnumerator];
	OFMutableString *connectionInfo = nil;
	OFString *key, *object;

	while ((key = [keyEnumerator nextObject]) != nil &&
	    (object = [objectEnumerator nextObject]) != nil) {
		if (connectionInfo != nil)
			[connectionInfo appendFormat: @" %@=%@", key, object];
		else
			connectionInfo = [OFMutableString stringWithFormat:
			    @"%@=%@", key, object];
	}

	if ((_connnection = PQconnectdb([connectionInfo UTF8String])) == NULL)
		@throw [OFOutOfMemoryException
		    exceptionWithClass: [self class]];

	if (PQstatus(_connnection) == CONNECTION_BAD)
		@throw [PGConnectionFailedException
		    exceptionWithClass: [self class]
			    connection: self];

	[pool release];
}

- (void)reset
{
	PQreset(_connnection);
}

- (void)close
{
	if (_connnection != NULL)
		PQfinish(_connnection);

	_connnection = NULL;
}

- (PGResult*)executeCommand: (OFConstantString*)command
{
	PGresult *result = PQexec(_connnection, [command UTF8String]);

	if (PQresultStatus(result) == PGRES_FATAL_ERROR) {
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithClass: [self class]
			    connection: self
			       command: command];
	}

	switch (PQresultStatus(result)) {
	case PGRES_TUPLES_OK:
		return [PGResult PG_resultWithResult: result];
	case PGRES_COMMAND_OK:
		PQclear(result);
		return nil;
	default:
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithClass: [self class]
			    connection: self
			       command: command];
	}
}

- (PGResult*)executeCommand: (OFConstantString*)command
		 parameters: (id)parameter, ...
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	PGresult *result;
	const char **values;
	va_list args, args2;
	int argsCount;

	va_start(args, parameter);
	va_copy(args2, args);

	for (argsCount = 1; va_arg(args2, id) != nil; argsCount++);

	values = [self allocMemoryWithSize: sizeof(*values)
				     count: argsCount];
	@try {
		size_t i = 0;

		do {
			if ([parameter isKindOfClass: [OFString class]])
				values[i++] = [parameter UTF8String];
			else if ([parameter isKindOfClass: [OFNumber class]]) {
				switch ([parameter type]) {
				case OF_NUMBER_BOOL:
					if ([parameter boolValue])
						values[i++] = "t";
					else
						values[i++] = "f";
					break;
				default:
					values[i++] = [[parameter description]
					    UTF8String];
					break;
				}
			} else if ([parameter isKindOfClass: [OFNull class]])
				values[i++] = NULL;
			else
				values[i++] = [[parameter description]
				    UTF8String];
		} while ((parameter = va_arg(args, id)) != nil);

		result = PQexecParams(_connnection, [command UTF8String],
		    argsCount, NULL, values, NULL, NULL, 0);
	} @finally {
		[self freeMemory: values];
	}

	[pool release];

	switch (PQresultStatus(result)) {
	case PGRES_TUPLES_OK:
		return [PGResult PG_resultWithResult: result];
	case PGRES_COMMAND_OK:
		PQclear(result);
		return nil;
	default:
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithClass: [self class]
			    connection: self
			       command: command];
	}
}

- (void)insertRow: (OFDictionary*)row
	intoTable: (OFString*)table
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFMutableString *command;
	OFEnumerator *enumerator;
	const char **values;
	PGresult *result;
	OFString *key, *value;
	size_t i, count;

	command = [OFMutableString stringWithString: @"INSERT INTO "];
	[command appendString: table];
	[command appendString: @" ("];

	count = [row count];

	i = 0;
	enumerator = [row keyEnumerator];
	while ((key = [enumerator nextObject]) != nil) {
		if (i > 0)
			[command appendString: @", "];

		[command appendString: key];

		i++;
	}

	[command appendString: @") VALUES ("];

	values = [self allocMemoryWithSize: sizeof(*values)
				     count: count];
	@try {
		i = 0;
		enumerator = [row objectEnumerator];
		while ((value = [enumerator nextObject]) != nil) {
			if (i > 0)
				[command appendString: @", "];

			values[i] = [value UTF8String];

			[command appendFormat: @"$%zd", ++i];
		}

		[command appendString: @")"];

		result = PQexecParams(_connnection, [command UTF8String],
		    (int)count, NULL, values, NULL, NULL, 0);
	} @finally {
		[self freeMemory: values];
	}

	[pool release];

	if (PQresultStatus(result) != PGRES_COMMAND_OK) {
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithClass: [self class]
			    connection: self
			       command: command];
	}

	PQclear(result);
}

- (void)insertRows: (OFArray*)rows
	 intoTable: (OFString*)table
{
	OFAutoreleasePool *pool = [[OFAutoreleasePool alloc] init];
	OFEnumerator *enumerator = [rows objectEnumerator];
	OFDictionary *row;

	while ((row = [enumerator nextObject]) != nil)
		[self insertRow: row
		      intoTable: table];

	[pool release];
}

- (PGconn*)PG_connection
{
	return _connnection;
}
@end
