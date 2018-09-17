all: lib/libnng.a lib/libjansson.a

export PREFIX = $(shell pwd)

lib/libnng.a: src/nng-1.0.1.tar.gz
	$(MAKE) -C src -f nng.make install

lib/libjansson.a: src/jansson-2.11.tar.gz
	cd src &&\
	tar xzf jansson-2.11.tar.gz  &&\
	cd jansson-2.11 &&\
	./configure -q --enable-static --disable-shared --prefix=$(PREFIX) &&\
	make install

clean: 
	@rm -rf include
	@rm -rf lib
	@rm -rf src/jansson-2.11
	$(MAKE) -C src -f  nng.make clean
