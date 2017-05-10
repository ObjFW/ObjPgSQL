#import "PGResult.h"
#import "PGResultRow.h"
#import "PGResultRow+Private.h"

@implementation PGResult
+ (instancetype)PG_resultWithResult: (PGresult *)result
{
	return [[[self alloc] PG_initWithResult: result] autorelease];
}

- (instancetype)PG_initWithResult: (PGresult *)result
{
	self = [super init];

	_result = result;

	return self;
}

- (void)dealloc
{
	if (_result != NULL)
		PQclear(_result);

	[super dealloc];
}

- (size_t)count
{
	return PQntuples(_result);
}

- (id)objectAtIndex: (size_t)index
{
	if (index > PQntuples(_result))
		@throw [OFOutOfRangeException exception];

	return [PGResultRow PG_rowWithResult: self
					 row: (int)index];
}

- (PGresult *)PG_result
{
	return _result;
}
@end
