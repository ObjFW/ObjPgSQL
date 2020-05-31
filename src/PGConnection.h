/*
 * Copyright (c) 2012, 2013, 2014, 2015, 2016, 2017
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

#include <libpq-fe.h>

#import <ObjFW/ObjFW.h>

#import "PGResult.h"

OF_ASSUME_NONNULL_BEGIN

@interface PGConnection: OFObject
{
	PGconn *_connection;
	OFDictionary OF_GENERIC(OFString *, OFString *) *_parameters;
}

@property (nonatomic, copy)
    OFDictionary OF_GENERIC(OFString *, OFString *) *parameters;

- (void)connect;
- (void)reset;
- (void)close;
- (nullable PGResult *)executeCommand: (OFConstantString *)command;
- (nullable PGResult *)executeCommand: (OFConstantString *)command
		  parameters: (id)firstParameter, ... OF_SENTINEL;
- (void)insertRow: (OFDictionary *)row
	intoTable: (OFString *)table;
- (void)insertRows: (OFArray OF_GENERIC(OFDictionary *) *)rows
	 intoTable: (OFString *)table;
@end

OF_ASSUME_NONNULL_END
