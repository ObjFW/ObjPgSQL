#import "PGResultRow.h"

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
		    (int16_t)[string decimalValue]];
	case 23:  /* INT4OID */
		return [OFNumber numberWithInt32:
		    (int32_t)[string decimalValue]];
	case 20:  /* INT8OID */
		return [OFNumber numberWithInt64:
		    (int64_t)[string decimalValue]];
	case 700: /* FLOAT4OID */
		return [OFNumber numberWithFloat: [string floatValue]];
	case 701: /* FLOAT8OID */
		return [OFNumber numberWithDouble: [string doubleValue]];
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
+ rowWithResult: (PGResult*)result
	    row: (int)row
{
	return [[[self alloc] initWithResult: result
					 row: row] autorelease];
}

- initWithResult: (PGResult*)result
	     row: (int)row
{
	self = [super init];

	_result = [result retain];
	_res = [result PG_result];
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

- (OFEnumerator*)keyEnumerator
{
	return [[[PGResultRowKeyEnumerator alloc]
	    initWithResult: _result
		       row: _row] autorelease];
}

- (OFEnumerator*)objectEnumerator
{
	return [[[PGResultRowObjectEnumerator alloc]
	    initWithResult: _result
		       row: _row] autorelease];
}

- (int)countByEnumeratingWithState: (of_fast_enumeration_state_t*)state
			   objects: (id*)objects
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
	state->mutationsPtr = (unsigned long*)self;

	return j;
}
@end

@implementation PGResultRowEnumerator
- initWithResult: (PGResult*)result
	     row: (int)row
{
	self = [super init];

	_result = [result retain];
	_res = [result PG_result];
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
	if (_pos >= _count)
		return nil;

	while (_pos < _count && PQgetisnull(_res, _row, _pos))
		_pos++;

	if (_pos >= _count)
		return nil;

	return convertType(_res, _pos,
	    [OFString stringWithUTF8String: PQgetvalue(_res, _row, _pos++)]);
}
@end
