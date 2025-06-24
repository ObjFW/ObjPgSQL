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

#import <ObjFW/ObjFW.h>

#import "PGSQLConnection.h"

OF_ASSUME_NONNULL_BEGIN

/**
 * @class PGSQLException PGSQLException.h ObjPgSQL/ObjPgSQL.h
 *
 * @brief A PostgreSQL exception.
 */
@interface PGSQLException: OFException
{
	PGSQLConnection *_connection;
	OFString *_errorMessage;
}

/**
 * @brief The connection for which the exception occurred.
 */
@property (readonly, nonatomic) PGSQLConnection *connection;

/**
 * @brief An error message for the exception.
 */
@property (readonly, nonatomic) OFString *errorMessage;

+ (instancetype)exception OF_UNAVAILABLE;

/**
 * @brief Creates a new PostgreSQL exception.
 *
 * @param connection The connection for which the exception occurred
 * @return A new, autoreleased PostgreSQL exception
 */
+ (instancetype)exceptionWithConnection: (PGSQLConnection *)connection;

- (instancetype)init OF_UNAVAILABLE;

/**
 * @brief Initializes an already allocated PostgreSQL exception.
 *
 * @param connection The connection for which the exception occurred
 * @return An initialized PostgreSQL exception
 */
- (instancetype)initWithConnection: (PGSQLConnection *)connection
    OF_DESIGNATED_INITIALIZER;
@end

OF_ASSUME_NONNULL_END
