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

#import "PGSQLException.h"

OF_ASSUME_NONNULL_BEGIN

/**
 * @class PGSQLExecuteCommandFailedException
 *	  PGSQLExecuteCommandFailedException.h
 *	  ObjPgSQL/ObjPgSQL.h
 *
 * @brief An exception indicating that executing a command failed.
 */
@interface PGSQLExecuteCommandFailedException: PGSQLException
{
	OFConstantString *_command;
}

/**
 * @brief The command that could not be executed.
 */
@property (readonly, nonatomic) OFConstantString *command;

+ (instancetype)exceptionWithConnection: (PGSQLConnection *)connection
    OF_UNAVAILABLE;

/**
 * @brief Creates a new execte command failed exception.
 *
 * @param connection The connection for which the command could not be executed
 * @param command The command which could not be executed
 * @return A new, autoreleased execute command failed exception
 */
+ (instancetype)exceptionWithConnection: (PGSQLConnection *)connection
				command: (OFConstantString *)command;

- (instancetype)initWithConnection: (PGSQLConnection *)connection
    OF_UNAVAILABLE;

/**
 * @brief Initializes an already allocated execte command failed exception.
 *
 * @param connection The connection for which the command could not be executed
 * @param command The command which could not be executed
 * @return An initialized execute command failed exception
 */
- (instancetype)initWithConnection: (PGSQLConnection *)connection
			   command: (OFConstantString *)command
    OF_DESIGNATED_INITIALIZER;
@end

OF_ASSUME_NONNULL_END
