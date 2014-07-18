#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

@interface PGResult: OFArray
{
	PGresult *_result;
}

+ PG_resultWithResult: (PGresult*)result;
- PG_initWithResult: (PGresult*)result;
- (PGresult*)PG_result;
@end
