#import "PGResultRow.h"

@interface PGResultRowEnumerator: OFEnumerator
{
	PGResult *result;
	PGresult *res;
	size_t row, pos, count;
}

- initWithResult: (PGResult*)result
	     row: (size_t)row;
@end

@interface PGResultRowKeyEnumerator: PGResultRowEnumerator
@end

@interface PGResultRowObjectEnumerator: PGResultRowEnumerator
@end

@implementation PGResultRow
+ rowWithResult: (PGResult*)result
	    row: (size_t)row
{
	return [[[self alloc] initWithResult: result
					 row: row] autorelease];
}

- initWithResult: (PGResult*)result_
	     row: (size_t)row_
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
	return PQnfields(res);
}

- (id)objectForKey: (id)key
{
	int col;

	if ([key isKindOfClass: [OFNumber class]])
		col = [key intValue];
	else
		col = PQfnumber(res, [key UTF8String]);

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
	     row: (size_t)row_
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

	return [OFString stringWithUTF8String: PQfname(res, pos++)];
}
@end

@implementation PGResultRowObjectEnumerator
- (id)nextObject
{
	if (pos >= count)
		return nil;

	return [OFString stringWithUTF8String: PQgetvalue(res, row, pos++)];
}
@end
