/*
 * Copyright (c) 2012, 2013, 2014, 2015, 2016, 2017, 2018
 *   Jonathan Schleifer <js@nil.im>
 *
 * https://fossil.nil.im/objpgsql
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice is present in all copies.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#import <ObjFW/ObjFW.h>

#import "PGConnection.h"
#import "PGConnectionFailedException.h"

@interface Test: OFObject <OFApplicationDelegate>
{
	PGConnection *_connection;
}
@end

OF_APPLICATION_DELEGATE(Test)

@implementation Test
- (void)applicationDidFinishLaunching
{
	OFString *username =
	    [[OFApplication environment] objectForKey: @"USER"];
	PGResult *result;

	_connection = [[PGConnection alloc] init];
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
	[_connection insertRow: [OFDictionary dictionaryWithKeysAndObjects:
				    @"content", @"Hallo!", @"name", @"foo", nil]
		     intoTable: @"test"];

	result = [_connection executeCommand: @"SELECT * FROM test"];
	of_log(@"%@", result);
	of_log(@"JSON: %@", [result JSONRepresentation]);

	for (id row in result)
		for (id col in row)
			of_log(@"%@", col);

	result = [_connection executeCommand: @"SELECT COUNT(*) FROM test"];
	of_log(@"%@", result);

	[OFApplication terminate];
}
@end
