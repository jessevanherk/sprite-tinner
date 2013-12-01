TINNER=./spritetinner

OUTNAME=sprites

clean:
	rm -f ${OUTNAME}.png ${OUTNAME}.lua

test: ${TINNER} clean
	${TINNER} sprites ./test

