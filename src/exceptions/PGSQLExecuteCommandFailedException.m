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

#import "PGSQLExecuteCommandFailedException.h"

@implementation PGSQLExecuteCommandFailedException
@synthesize command = _command;

+ (instancetype)exceptionWithConnection: (PGSQLConnection *)connection
{
	OF_UNRECOGNIZED_SELECTOR
}

+ (instancetype)exceptionWithConnection: (PGSQLConnection *)connection
				command: (OFConstantString *)command
{
	return objc_autoreleaseReturnValue(
	    [[self alloc] initWithConnection: connection
				     command: command]);
}

- (instancetype)initWithConnection: (PGSQLConnection *)connection
{
	OF_INVALID_INIT_METHOD
}

- (instancetype)initWithConnection: (PGSQLConnection *)connection
			   command: (OFConstantString *)command
{
	self = [super initWithConnection: connection];

	@try {
		_command = [command copy];
	} @catch (id e) {
		objc_release(self);
		@throw e;
	}

	return self;
}

- (void)dealloc
{
	objc_release(_command);

	[super dealloc];
}

- (OFString *)description
{
	return [OFString stringWithFormat: @"A PostgreSQL command failed: %@\n"
					   @"Command: %@",
					   _errorMessage, _command];
}
@end
