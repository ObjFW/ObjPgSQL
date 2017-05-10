#import <ObjFW/ObjFW.h>

#import "PGConnection.h"
#import "PGConnectionFailedException.h"

@interface Test: OFObject
{
	PGConnection *connection;
}
@end

OF_APPLICATION_DELEGATE(Test)

@implementation Test
- (void)applicationDidFinishLaunching
{
	OFString *username =
	    [[OFApplication environment] objectForKey: @"USER"];
	PGResult *result;

	connection = [[PGConnection alloc] init];
	[connection setParameters:
	    [OFDictionary dictionaryWithKeysAndObjects: @"user", username,
							@"dbname", username,
							nil]];
	[connection connect];

	[connection executeCommand: @"DROP TABLE IF EXISTS test"];
	[connection executeCommand: @"CREATE TABLE test ("
				    @"    id integer,"
				    @"    name varchar(255),"
				    @"    content text,"
				    @"    success boolean"
				    @")"];
	[connection executeCommand: @"INSERT INTO test (id, name, content) "
				    @"VALUES ($1, $2, $3)"
			parameters: [OFNumber numberWithInt: 1], @"foo",
				    @"Hallo Welt!", nil];
	[connection executeCommand: @"INSERT INTO test (id, content, success) "
				    @"VALUES ($1, $2, $3)"
			parameters: [OFNumber numberWithInt: 2],
				    [OFNumber numberWithInt: 2],
				    [OFNumber numberWithBool: true], nil];
	[connection insertRow: [OFDictionary dictionaryWithKeysAndObjects:
				   @"content", @"Hallo!", @"name", @"foo", nil]
		    intoTable: @"test"];

	result = [connection executeCommand: @"SELECT * FROM test"];
	of_log(@"%@", result);
	of_log(@"JSON: %@", [result JSONRepresentation]);

	for (id row in result)
		for (id col in row)
			of_log(@"%@", col);

	result = [connection executeCommand: @"SELECT COUNT(*) FROM test"];
	of_log(@"%@", result);

	[OFApplication terminate];
}
@end
