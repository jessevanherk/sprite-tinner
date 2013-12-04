# makefile for creating a spritetinner executable that can be moved around

BIN=spritetinner

LUAC=/usr/bin/luac
GLUE=./bin/glue
RUNNER=./bin/srlua

DEST=/usr/local/bin

SOURCES=packer.lua spritetinner.lua

COMBINED_LUAC=_combined.luac

all: spritetinner

clean:
	rm -f ${COMBINED_LUAC}

install:
	install --mode=755 ${BIN} ${DEST}

combine: ${SOURCES}
	${LUAC} -o ${COMBINED_LUAC} ${SOURCES}

spritetinner: combine
	${GLUE} ${RUNNER} ${COMBINED_LUAC} ${BIN}
	chmod a+x ${BIN}

