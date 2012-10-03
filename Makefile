SRCS = PGConnection.m				\
       PGResult.m				\
       PGResultRow.m				\
       exceptions/PGCommandFailedException.m	\
       exceptions/PGConnectionFailedException.m	\
       exceptions/PGException.m

all:
	@objfw-compile			\
		--lib 0.0		\
		-o objpgsql		\
		--builddir build	\
		-Iexceptions		\
		-I.			\
		-lpq			\
		${SRCS}

test:
	@objfw-compile			\
		-o test			\
		--builddir build	\
		-Iexceptions		\
		-I.			\
		-L.			\
		-lobjpgsql		\
		test.m

clean:
	rm -f libobjpgsql.* exceptions/*~ *~
	rm -fr build
