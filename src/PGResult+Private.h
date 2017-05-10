#import "PGResult.h"

OF_ASSUME_NONNULL_BEGIN

@interface PGResult ()
+ (instancetype)PG_resultWithResult: (PGresult *)result;
- PG_initWithResult: (PGresult *)result OF_METHOD_FAMILY(init);
- (PGresult *)PG_result;
@end

OF_ASSUME_NONNULL_END
