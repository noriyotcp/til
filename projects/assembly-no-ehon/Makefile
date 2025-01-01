greeting: greeting.o
	ld -o greeting \
		-lSystem \
		-syslibroot `xcrun -sdk macosx --show-sdk-path` \
		-e _start \
		-arch arm64 \
		greeting.o

greeting.o: greeting.s
	as -arch arm64 \
		-o greeting.o \
		greeting.s

calculate: calculate.o
	ld -o calculate \
		-lSystem \
		-syslibroot `xcrun -sdk macosx --show-sdk-path` \
		-e _start \
		-arch arm64 \
		calculate.o

calculate.o: calculate.s
	as -arch arm64 \
		-o calculate.o \
		calculate.s

clean:
	rm -f greeting greeting.o calculate calculate.o

.PHONY: clean
