CPPFLAGS += -I./build/include

CFLAGS += -std=c99 -g
CPPFLAGS += -D_XOPEN_SOURCE=700
LDFLAGS += -lutil -lanl -lrt -lpthread -lnsl

all: ../bin/spub ../bin/ssub 

spub.o ssub.o: build/include/nanomsg/nn.h

../bin/spub: spub.o msg.o build/lib/libnanomsg.a
../bin/ssub: ssub.o msg.o build/lib/libnanomsg.a

../bin/%:
	$(LINK.o) $^ $(LOADLIBES) $(LDLIBS) -o $@

build/include/nanomsg/nn.h build/lib/libnanomsg.a:
	rm -rf build
	mkdir build
	cd build  && \
		cmake -DNN_STATIC_LIB=ON \
		      -DNN_TESTS=OFF \
		      -DNN_TOOLS=OFF  \
		      -DNN_ENABLE_DOC=OFF \
		      -DCMAKE_INSTALL_PREFIX=$(shell pwd)/build \
		      -DCMAKE_INSTALL_LIBDIR=lib \
		      ../third_party/nanomsg  && \
	make install

.PHONY: clean
clean: 
	rm -rf build
	rm *.o
