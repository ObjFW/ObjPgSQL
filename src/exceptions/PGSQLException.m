/*
 * Copyright (c) 2012 - 2019, 2021, 2024, 2025 Jonathan Schleifer <js@nil.im>
 *
 * https://git.nil.im/ObjFW/ObjPgSQL
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

#import "PGSQLException.h"
#import "PGSQLConnection+Private.h"

@implementation PGSQLException
@synthesize connection = _connection, errorMessage = _errorMessage;

+ (instancetype)exception
{
	OF_UNRECOGNIZED_SELECTOR
}

+ (instancetype)exceptionWithConnection: (PGSQLConnection *)connection
{
	return objc_autoreleaseReturnValue(
	    [[self alloc] initWithConnection: connection]);
}

- (instancetype)init
{
	OF_INVALID_INIT_METHOD
}

- (instancetype)initWithConnection: (PGSQLConnection *)connection
{
	self = [super init];

	@try {
		_connection = objc_retain(connection);
		_errorMessage = [[OFString alloc]
		    initWithCString: PQerrorMessage([_connection pg_connection])
			   encoding: [OFLocale encoding]];
	} @catch (id e) {
		objc_release(self);
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	objc_release(_connection);
	objc_release(_errorMessage);

	[super dealloc];
}

- (OFString *)description
{
	return [OFString stringWithFormat: @"A PostgreSQL operation failed: %@",
					   _errorMessage];
}
@end
