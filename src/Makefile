include ../extra.mk

SUBDIRS = exceptions

SHARED_LIB = ${OBJPGSQL_SHARED_LIB}
STATIC_LIB = ${OBJPGSQL_STATIC_LIB}
LIB_MAJOR = 0
LIB_MINOR = 1

SRCS = PGConnection.m	\
       PGResult.m	\
       PGResultRow.m
INCLUDES := ${SRCS:.m=.h}	\
	    ObjPgSQL.h

OBJS_EXTRA = ${EXCEPTIONS_EXCEPTIONS_A}
LIB_OBJS_EXTRA = ${EXCEPTIONS_EXCEPTIONS_LIB_A}

include ../buildsys.mk

CPPFLAGS += -I. -Iexceptions
LD = ${OBJC}
