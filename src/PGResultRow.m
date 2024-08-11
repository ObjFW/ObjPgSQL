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

#import "PGResultRow.h"
#import "PGResult+Private.h"

static id
convertType(PGresult *res, int column, OFString *string)
{
	switch (PQftype(res, column)) {
	case 16:  /* BOOLOID */
		if ([string isEqual: @"t"])
			return [OFNumber numberWithBool: YES];
		else
			return [OFNumber numberWithBool: NO];
	case 21:  /* INT2OID */
		return [OFNumber numberWithShort:
		    (short)[string longLongValueWithBase: 10]];
	case 23:  /* INT4OID */
		return [OFNumber numberWithLong:
		    (long)[string longLongValueWithBase: 10]];
	case 20:  /* INT8OID */
		return [OFNumber numberWithLongLong:
		    [string longLongValueWithBase: 10]];
	case 700: /* FLOAT4OID */
		return [OFNumber numberWithFloat: string.floatValue];
	case 701: /* FLOAT8OID */
		return [OFNumber numberWithDouble: string.doubleValue];
	}

	return string;
}

@interface PGResultRowEnumerator: OFEnumerator
{
	PGResult *_result;
	PGresult *_res;
	int _row, _pos, _count;
}

- (instancetype)initWithResult: (PGResult*)result row: (int)row;
@end

@interface PGResultRowKeyEnumerator: PGResultRowEnumerator
@end

@interface PGResultRowObjectEnumerator: PGResultRowEnumerator
@end

@implementation PGResultRow
+ (instancetype)pg_rowWithResult: (PGResult *)result row: (int)row
{
	return [[[self alloc] pg_initWithResult: result row: row] autorelease];
}

- (instancetype)pg_initWithResult: (PGResult *)result row: (int)row
{
	self = [super init];

	_result = [result retain];
	_res = result.pg_result;
	_row = row;

	return self;
}

- (void)dealloc
{
	[_result release];

	[super dealloc];
}

- (size_t)count
{
	int i, count, fields = PQnfields(_res);

	for (i = count = 0; i < fields; i++)
		if (!PQgetisnull(_res, _row, i))
			count++;

	return count;
}

- (id)objectForKey: (id)key
{
	int column;

	if ([key isKindOfClass: [OFNumber class]])
		column = [key intValue];
	else
		column = PQfnumber(_res, [key UTF8String]);

	if (PQgetisnull(_res, _row, column))
		return nil;

	return convertType(_res, column,
	    [OFString stringWithUTF8String: PQgetvalue(_res, _row, column)]);
}

- (OFEnumerator *)keyEnumerator
{
	return [[[PGResultRowKeyEnumerator alloc]
	    initWithResult: _result
		       row: _row] autorelease];
}

- (OFEnumerator *)objectEnumerator
{
	return [[[PGResultRowObjectEnumerator alloc]
	    initWithResult: _result
		       row: _row] autorelease];
}

- (int)countByEnumeratingWithState: (OFFastEnumerationState *)state
			   objects: (id *)objects
			     count: (int)count
{
	int i, j;

	if (state->extra[0] == 0) {
		state->extra[0] = 1;
		state->extra[1] = PQnfields(_res);
	}

	if (count < 0 || (unsigned long)count > SIZE_MAX - state->state)
		@throw [OFOutOfRangeException exception];

	if (state->state + count > state->extra[1])
		count = state->extra[1] - state->state;

	for (i = j = 0; i < count; i++) {
		if (PQgetisnull(_res, _row, state->state + i))
			continue;

		objects[j++] = [OFString stringWithUTF8String:
		    PQfname(_res, state->state + i)];
	}

	state->state += count;
	state->itemsPtr = objects;
	state->mutationsPtr = (unsigned long *)self;

	return j;
}
@end

@implementation PGResultRowEnumerator
- (instancetype)initWithResult: (PGResult *)result row: (int)row
{
	self = [super init];

	_result = [result retain];
	_res = result.pg_result;
	_row = row;
	_count = PQnfields(_res);

	return self;
}

- (void)dealloc
{
	[_result release];

	[super dealloc];
}

- (void)reset
{
	_pos = 0;
}
@end

@implementation PGResultRowKeyEnumerator
- (id)nextObject
{
	if (_pos >= _count)
		return nil;

	while (_pos < _count && PQgetisnull(_res, _row, _pos))
		_pos++;

	if (_pos >= _count)
		return nil;

	return [OFString stringWithUTF8String: PQfname(_res, _pos++)];
}
@end

@implementation PGResultRowObjectEnumerator
- (id)nextObject
{
	id object;

	if (_pos >= _count)
		return nil;

	while (_pos < _count && PQgetisnull(_res, _row, _pos))
		_pos++;

	if (_pos >= _count)
		return nil;

	object = convertType(_res, _pos,
	    [OFString stringWithUTF8String: PQgetvalue(_res, _row, _pos)]);
	_pos++;

	return object;
}
@end
