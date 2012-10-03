#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

@interface PGResultRow: OFDictionary
{
	PGResult *result;
	PGresult *res;
	size_t row;
}

+ rowWithResult: (PGResult*)result
	    row: (size_t)row;
- initWithResult: (PGResult*)result
	     row: (size_t)row;
@end
