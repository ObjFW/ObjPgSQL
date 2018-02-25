include ../extra.mk

PROG_NOINST = tests
SRCS = tests.m

include ../buildsys.mk

CPPFLAGS += -I../src -I../src/exceptions
LIBS := -L../src -lobjpgsql ${OBJFW_LIBS} ${LIBS}
LD = ${OBJC}
