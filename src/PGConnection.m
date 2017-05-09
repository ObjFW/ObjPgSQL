#import "PGConnection.h"

#import "PGConnectionFailedException.h"
#import "PGCommandFailedException.h"

@implementation PGConnection
@synthesize parameters = _parameters;

- (void)dealloc
{
	[_parameters release];

	[self close];

	[super dealloc];
}

- (void)connect
{
	void *pool = objc_autoreleasePoolPush();
	OFEnumerator OF_GENERIC(OFString *) *keyEnumerator =
	    [_parameters keyEnumerator];
	OFEnumerator OF_GENERIC(OFString *) *objectEnumerator =
	    [_parameters objectEnumerator];
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
		@throw [OFOutOfMemoryException exception];

	if (PQstatus(_connnection) == CONNECTION_BAD)
		@throw [PGConnectionFailedException
		    exceptionWithConnection: self];

	objc_autoreleasePoolPop(pool);
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

- (PGResult *)executeCommand: (OFConstantString *)command
{
	PGresult *result = PQexec(_connnection, [command UTF8String]);

	if (PQresultStatus(result) == PGRES_FATAL_ERROR) {
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithConnection: self
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
		    exceptionWithConnection: self
				    command: command];
	}
}

- (PGResult *)executeCommand: (OFConstantString *)command
		  parameters: (id)parameter, ...
{
	void *pool = objc_autoreleasePoolPush();
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
				OFNumber *number = parameter;

				switch ([number type]) {
				case OF_NUMBER_TYPE_BOOL:
					if ([number boolValue])
						values[i++] = "t";
					else
						values[i++] = "f";
					break;
				default:
					values[i++] = [[number description]
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

	objc_autoreleasePoolPop(pool);

	switch (PQresultStatus(result)) {
	case PGRES_TUPLES_OK:
		return [PGResult PG_resultWithResult: result];
	case PGRES_COMMAND_OK:
		PQclear(result);
		return nil;
	default:
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithConnection: self
				    command: command];
	}
}

- (void)insertRow: (OFDictionary *)row
	intoTable: (OFString *)table
{
	void *pool = objc_autoreleasePoolPush();
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

	objc_autoreleasePoolPop(pool);

	if (PQresultStatus(result) != PGRES_COMMAND_OK) {
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithConnection: self
				    command: command];
	}

	PQclear(result);
}

- (void)insertRows: (OFArray OF_GENERIC(OFDictionary *) *)rows
	 intoTable: (OFString *)table
{
	for (OFDictionary *row in rows)
		[self insertRow: row
		      intoTable: table];
}

- (PGconn *)PG_connection
{
	return _connnection;
}
@end
