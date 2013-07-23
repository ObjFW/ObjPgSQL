#import "PGResult.h"
#import "PGResultRow.h"

@implementation PGResult
+ PG_resultWithResult: (PGresult*)result
{
	return [[[self alloc] PG_initWithResult: result] autorelease];
}

- PG_initWithResult: (PGresult*)result
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

	return [PGResultRow rowWithResult: self
				      row: (int)index];
}

- (PGresult*)PG_result
{
	return _result;
}
@end
