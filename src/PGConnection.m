/*
 * Copyright (c) 2012 - 2019, 2021, 2024 Jonathan Schleifer <js@nil.im>
 *
 * https://fl.nil.im/objpgsql
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND ISC DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS.  IN NO EVENT SHALL ISC BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
 * OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#import "PGConnection.h"
#import "PGConnection+Private.h"
#import "PGResult.h"
#import "PGResult+Private.h"

#import "PGConnectionFailedException.h"
#import "PGCommandFailedException.h"

@implementation PGConnection
@synthesize pg_connection = _connection, parameters = _parameters;

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

	if ((_connection = PQconnectdb(connectionInfo.UTF8String)) == NULL)
		@throw [OFOutOfMemoryException exception];

	if (PQstatus(_connection) == CONNECTION_BAD)
		@throw [PGConnectionFailedException
		    exceptionWithConnection: self];

	objc_autoreleasePoolPop(pool);
}

- (void)reset
{
	PQreset(_connection);
}

- (void)close
{
	if (_connection != NULL)
		PQfinish(_connection);

	_connection = NULL;
}

- (PGResult *)executeCommand: (OFConstantString *)command
{
	PGresult *result = PQexec(_connection, command.UTF8String);

	if (PQresultStatus(result) == PGRES_FATAL_ERROR) {
		PQclear(result);
		@throw [PGCommandFailedException
		    exceptionWithConnection: self
				    command: command];
	}

	switch (PQresultStatus(result)) {
	case PGRES_TUPLES_OK:
		return [PGResult pg_resultWithResult: result];
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

	values = OFAllocMemory(argsCount, sizeof(*values));
	@try {
		size_t i = 0;

		do {
			if ([parameter isKindOfClass: [OFString class]])
				values[i++] = [parameter UTF8String];
			else if ([parameter isKindOfClass: [OFNumber class]]) {
				OFNumber *number = parameter;

				if (strcmp(number.objCType,
				    @encode(bool)) == 0) {
					if (number.boolValue)
						values[i++] = "t";
					else
						values[i++] = "f";
				} else
					values[i++] =
					    number.description.UTF8String;
			} else if ([parameter isKindOfClass: [OFNull class]])
				values[i++] = NULL;
			else
				values[i++] =
				    [parameter description].UTF8String;
		} while ((parameter = va_arg(args, id)) != nil);

		result = PQexecParams(_connection, command.UTF8String,
		    argsCount, NULL, values, NULL, NULL, 0);
	} @finally {
		OFFreeMemory(values);
	}

	objc_autoreleasePoolPop(pool);

	switch (PQresultStatus(result)) {
	case PGRES_TUPLES_OK:
		return [PGResult pg_resultWithResult: result];
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
@end
