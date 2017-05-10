#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

OF_ASSUME_NONNULL_BEGIN

@class PGResultRow;

@interface PGResult: OFArray OF_GENERIC(PGResultRow *)
{
	PGresult *_result;
}
@end

OF_ASSUME_NONNULL_END
