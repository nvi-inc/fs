all: window_test server_test

CFLAGS += -g -fprofile-arcs -ftest-coverage -fPIC -O0  -fno-omit-frame-pointer -fsanitize=address
LDLIBS += -lutil -lnng -ljansson -pthread -L../../third_party/lib
CPPFLAGS += -DCONVEY_NO_THREADS -fno-omit-frame-pointer -fsanitize=address -I../../third_party/include -D_GNU_SOURCE

window_test: window_test.c convey.c ../stream.c ../msg.c
server_test: server_test.c convey.c ../window.c ../stream.c ../msg.c
list_test: list_test.c convey.c
