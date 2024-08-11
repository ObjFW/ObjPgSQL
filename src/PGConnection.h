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

#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

OF_ASSUME_NONNULL_BEGIN

/** @file */

/**
 * @brief A result row.
 */
typedef OFDictionary OF_GENERIC(OFString *, id) *PGRow;

/**
 * @class PGConnection PGConnection.h ObjPgSQL/ObjPgSQL.h
 *
 * @brief A connection to a database.
 */
@interface PGConnection: OFObject
{
	PGconn *_connection;
	OFDictionary OF_GENERIC(OFString *, OFString *) *_parameters;
}

/**
 * @brief The parameters for the database connection. See `PQconnectdb` in the
 *	  PostgreSQL documentation.
 */
@property (nonatomic, copy)
    OFDictionary OF_GENERIC(OFString *, OFString *) *parameters;

/**
 * @brief Connects to the database.
 *
 * @throw PGConnectionFailedException The connection failed
 */
- (void)connect;

/**
 * @brief Resets the connection to the database.
 */
- (void)reset;

/**
 * @brief Closes the connection to the database.
 */
- (void)close;

/**
 * @brief Executes the specified command.
 *
 * @param command The command to execute
 * @return The result of the command, if any
 * @throw PGCommandFailedException Executing the command failed.
 */
- (nullable PGResult *)executeCommand: (OFConstantString *)command;

/**
 * @brief Executes the specified command.
 *
 * @param command The command to execute
 * @param firstParameter First parameter for the command
 * @return The result of the command, if any
 * @throw PGCommandFailedException Executing the command failed.
 */
- (nullable PGResult *)executeCommand: (OFConstantString *)command
			   parameters: (id)firstParameter, ... OF_SENTINEL;
@end

OF_ASSUME_NONNULL_END
