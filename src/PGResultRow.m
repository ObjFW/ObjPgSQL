/*
 * Copyright (c) 2012, 2013, 2014, 2015, 2016, 2017, 2018, 2019
 *   Jonathan Schleifer <js@nil.im>
 *
 * https://fossil.nil.im/objpgsql
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice is present in all copies.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
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
		return [OFNumber numberWithInt16:
		    (int16_t)string.decimalValue];
	case 23:  /* INT4OID */
		return [OFNumber numberWithInt32:
		    (int32_t)string.decimalValue];
	case 20:  /* INT8OID */
		return [OFNumber numberWithInt64:
		    (int64_t)string.decimalValue];
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

- initWithResult: (PGResult*)result
	     row: (int)row;
@end

@interface PGResultRowKeyEnumerator: PGResultRowEnumerator
@end

@interface PGResultRowObjectEnumerator: PGResultRowEnumerator
@end

@implementation PGResultRow
+ (instancetype)rowWithResult: (PGResult *)result
			  row: (int)row
{
	return [[[self alloc] initWithResult: result
					 row: row] autorelease];
}

- (instancetype)initWithResult: (PGResult *)result
			   row: (int)row
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

- (int)countByEnumeratingWithState: (of_fast_enumeration_state_t*)state
			   objects: (id *)objects
			     count: (int)count
{
	int i, j;

	if (state->extra[0] == 0) {
		state->extra[0] = 1;
		state->extra[1] = PQnfields(_res);
	}

	if (count > SIZE_MAX - state->state)
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
- (instancetype)initWithResult: (PGResult *)result
			   row: (int)row
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
