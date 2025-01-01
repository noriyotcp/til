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

clean:
	rm -f greeting greeting.o

.PHONY: clean
