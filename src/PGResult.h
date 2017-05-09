#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@class PGResultRow;

@interface PGResult: OFArray OF_GENERIC(PGResultRow *)
{
	PGresult *_result;
}

+ (instancetype)PG_resultWithResult: (PGresult *)result;
- PG_initWithResult: (PGresult *)result OF_METHOD_FAMILY(init);
- (PGresult *)PG_result;
@end

OF_ASSUME_NONNULL_END
