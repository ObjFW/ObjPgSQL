/*
 * Copyright (c) 2012 - 2019, 2021, 2024 Jonathan Schleifer <js@nil.im>
 *
 * https://fl.nil.im/objpgsql
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND ISC DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS.  IN NO EVENT SHALL ISC BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE
 * OR OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 */

#import <ObjFW/ObjFW.h>

#import "ObjPgSQL.h"

@interface Test: OFObject <OFApplicationDelegate>
{
	PGSQLConnection *_connection;
}
@end

OF_APPLICATION_DELEGATE(Test)

@implementation Test
- (void)applicationDidFinishLaunching: (OFNotification *)notification
{
	OFString *username =
	    [[OFApplication environment] objectForKey: @"USER"];
	PGSQLResult *result;

	_connection = [[PGSQLConnection alloc] init];
	[_connection setParameters:
	    [OFDictionary dictionaryWithKeysAndObjects: @"user", username,
							@"dbname", username,
							nil]];
	[_connection connect];

	[_connection executeCommand: @"DROP TABLE IF EXISTS test"];
	[_connection executeCommand: @"CREATE TABLE test ("
				     @"    id integer,"
				     @"    name varchar(255),"
				     @"    content text,"
				     @"    success boolean"
				     @")"];
	[_connection executeCommand: @"INSERT INTO test (id, name, content) "
				     @"VALUES ($1, $2, $3)"
			 parameters: [OFNumber numberWithInt: 1], @"foo",
				     @"Hallo Welt!", nil];
	[_connection executeCommand: @"INSERT INTO test (id, content, success) "
				     @"VALUES ($1, $2, $3)"
			 parameters: [OFNumber numberWithInt: 2],
				     [OFNumber numberWithInt: 2],
				     [OFNumber numberWithBool: true], nil];

	result = [_connection executeCommand: @"SELECT * FROM test"];
	OFLog(@"%@", result);
	OFLog(@"JSON: %@", [result JSONRepresentation]);

	for (id row in result)
		for (id col in row)
			OFLog(@"%@", col);

	result = [_connection executeCommand: @"SELECT COUNT(*) FROM test"];
	OFLog(@"%@", result);

	[OFApplication terminate];
}
@end
