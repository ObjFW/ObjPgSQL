#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

@interface PGResultRow: OFDictionary
{
	PGResult *_result;
	PGresult *_res;
	int _row;
}

+ rowWithResult: (PGResult*)result
	    row: (int)row;
- initWithResult: (PGResult*)result
	     row: (int)row;
@end
