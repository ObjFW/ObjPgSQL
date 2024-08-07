/*
 * Copyright (c) 2012, 2013, 2014, 2015, 2016, 2017, 2024
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

#import "PGResult.h"
#import "PGResult+Private.h"
#import "PGResultRow.h"
#import "PGResultRow+Private.h"

@implementation PGResult
@synthesize pg_result = _result;

+ (instancetype)pg_resultWithResult: (PGresult *)result
{
	return [[[self alloc] pg_initWithResult: result] autorelease];
}

- (instancetype)pg_initWithResult: (PGresult *)result
{
	self = [super init];

	_result = result;

	return self;
}

- (void)dealloc
{
	if (_result != NULL)
		PQclear(_result);

	[super dealloc];
}

- (size_t)count
{
	return PQntuples(_result);
}

- (id)objectAtIndex: (size_t)index
{
	if (index > LONG_MAX || (long)index > PQntuples(_result))
		@throw [OFOutOfRangeException exception];

	return [PGResultRow pg_rowWithResult: self row: (int)index];
}
@end
