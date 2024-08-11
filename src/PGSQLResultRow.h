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

#import "PGSQLResult.h"

OF_ASSUME_NONNULL_BEGIN

/**
 * @class PGSQLResult PGSQLResult.h ObjPgSQL/ObjPgSQL.h
 *
 * @brief A PostgreSQL result row.
 *
 * This is a regular OFDictionary, where each entry in the dictionary
 * represents a column of the result row.
 */
@interface PGSQLResultRow: OFDictionary OF_GENERIC(OFString *, id)
{
	PGSQLResult *_result;
	PGresult *_res;
	int _row;
}
@end

OF_ASSUME_NONNULL_END
