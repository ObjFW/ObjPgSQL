#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

OF_ASSUME_NONNULL_BEGIN

@interface PGResultRow: OFDictionary OF_GENERIC(OFString *, id)
{
	PGResult *_result;
	PGresult *_res;
	int _row;
}
@end

OF_ASSUME_NONNULL_END
