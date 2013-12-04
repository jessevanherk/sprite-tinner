# makefile for creating a spritetinner executable that can be moved around

BIN=spritetinner

LUAC=/usr/bin/luac
GLUE=./srlua/glue
RUNNER=./srlua/srlua

DEST=/usr/local/bin

SOURCES=packer.lua spritetinner.lua

COMBINED_LUAC=_combined.luac

all: spritetinner

clean:
	rm -f ${COMBINED_LUAC}

install:
	install --mode=755 ${BIN} ${DEST}

srlua: FORCE
	$(MAKE) -C srlua

combine: ${SOURCES}
	${LUAC} -o ${COMBINED_LUAC} ${SOURCES}

spritetinner: srlua combine
	${GLUE} ${RUNNER} ${COMBINED_LUAC} ${BIN}
	chmod a+x ${BIN}

FORCE:
