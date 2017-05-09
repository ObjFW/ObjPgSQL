#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

OF_ASSUME_NONNULL_BEGIN

@interface PGResultRow: OFDictionary
{
	PGResult *_result;
	PGresult *_res;
	int _row;
}

+ rowWithResult: (PGResult *)result
	    row: (int)row;
- initWithResult: (PGResult *)result
	     row: (int)row;
@end

OF_ASSUME_NONNULL_END
