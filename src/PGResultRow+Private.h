#import "PGResultRow.h"

OF_ASSUME_NONNULL_BEGIN

@interface PGResultRow ()
+ (instancetype)PG_rowWithResult: (PGResult *)result
			     row: (int)row;
- PG_initWithResult: (PGResult *)result
		row: (int)row OF_METHOD_FAMILY(init);
@end

OF_ASSUME_NONNULL_END
