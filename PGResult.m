#import "PGResult.h"
#import "PGResultRow.h"

@implementation PGResult
+ PG_resultWithResult: (PGresult*)result
{
	return [[[self alloc] PG_initWithResult: result] autorelease];
}

- PG_initWithResult: (PGresult*)result_
{
	self = [super init];

	result = result_;

	return self;
}

- (void)dealloc
{
	if (result != NULL)
		PQclear(result);

	[super dealloc];
}

- (size_t)count
{
	return PQntuples(result);
}

- (id)objectAtIndex: (size_t)index
{
	if (index > PQntuples(result))
		@throw [OFOutOfRangeException
		    exceptionWithClass: [self class]];

	return [PGResultRow rowWithResult: self
				      row: (int)index];
}

- (PGresult*)PG_result
{
	return result;
}
@end
