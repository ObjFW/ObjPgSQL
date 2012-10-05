LIB = objpgsql
LIB_MAJOR = 0
LIB_MINOR = 0

SRCS = PGConnection.m				\
       PGResult.m				\
       PGResultRow.m				\
       exceptions/PGCommandFailedException.m	\
       exceptions/PGConnectionFailedException.m	\
       exceptions/PGException.m

HEADERS = ${SRCS:.m=.h}	\
	  ObjPgSQL.h

CPPFLAGS += -Wall -Iexceptions -I.
LIBS += -lpq

prefix ?= /usr/local

INSTALL ?= install
OBJFW_CONFIG ?= objfw-config
OBJFW_COMPILE ?= objfw-compile

LIB_PREFIX = `${OBJFW_CONFIG} --lib-prefix`
LIB_SUFFIX = `${OBJFW_CONFIG} --lib-suffix`
LIB_FILE = ${LIB_PREFIX}${LIB}${LIB_SUFFIX}

all:
	@objfw-compile			\
		--lib 0.0		\
		-o objpgsql		\
		--builddir build	\
		${CPPFLAGS}		\
		${LIBS}			\
		${SRCS}

test:
	@objfw-compile			\
		-o test			\
		--builddir build	\
		-L.			\
		-lobjpgsql		\
		${CPPFLAGS}		\
		test.m

clean:
	rm -f test libobjpgsql.* exceptions/*~ *~
	rm -fr build

install:
	mkdir -p ${destdir}${prefix}/include/ObjPgSQL/exceptions
	for i in ${HEADERS}; do \
		${INSTALL} -m 644 $$i \
			${destdir}${prefix}/include/ObjPgSQL/$$i; \
	done
	mkdir -p ${destdir}${prefix}/lib
	export LIB_MAJOR=${LIB_MAJOR}; \
	export LIB_MINOR=${LIB_MINOR}; \
	${INSTALL} -m 755 ${LIB_FILE} ${destdir}${prefix}/lib/${LIB_FILE}
