#import "PGResultRow.h"

@interface PGResultRowEnumerator: OFEnumerator
{
	PGResult *result;
	PGresult *res;
	int row, pos, count;
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

- initWithResult: (PGResult*)result_
	     row: (int)row_
{
	self = [super init];

	result = [result_ retain];
	res = [result PG_result];
	row = row_;

	return self;
}

- (void)dealloc
{
	[result release];

	[super dealloc];
}

- (size_t)count
{
	int i, count, fields = PQnfields(res);

	for (i = count = 0; i < fields; i++)
		if (!PQgetisnull(res, row, i))
			count++;

	return count;
}

- (id)objectForKey: (id)key
{
	int col;

	if ([key isKindOfClass: [OFNumber class]])
		col = [key intValue];
	else
		col = PQfnumber(res, [key UTF8String]);

	if (PQgetisnull(res, row, col))
		return nil;

	return [OFString stringWithUTF8String: PQgetvalue(res, row, col)];
}

- (OFEnumerator*)keyEnumerator
{
	return [[[PGResultRowKeyEnumerator alloc]
	    initWithResult: result
		       row: row] autorelease];
}

- (OFEnumerator*)objectEnumerator
{
	return [[[PGResultRowObjectEnumerator alloc]
	    initWithResult: result
		       row: row] autorelease];
}
@end

@implementation PGResultRowEnumerator
- initWithResult: (PGResult*)result_
	     row: (int)row_
{
	self = [super init];

	result = [result_ retain];
	res = [result PG_result];
	row = row_;
	count = PQnfields(res);

	return self;
}

- (void)reset
{
	pos = 0;
}
@end

@implementation PGResultRowKeyEnumerator
- (id)nextObject
{
	if (pos >= count)
		return nil;

	while (pos < count && PQgetisnull(res, row, pos))
		pos++;

	if (pos >= count)
		return nil;

	return [OFString stringWithUTF8String: PQfname(res, pos++)];
}
@end

@implementation PGResultRowObjectEnumerator
- (id)nextObject
{
	if (pos >= count)
		return nil;

	while (pos < count && PQgetisnull(res, row, pos))
		pos++;

	if (pos >= count)
		return nil;

	return [OFString stringWithUTF8String: PQgetvalue(res, row, pos++)];
}
@end
