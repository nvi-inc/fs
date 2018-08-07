all: window_test server_test

CFLAGS += -g -fprofile-arcs -ftest-coverage -fPIC -O0  -fno-omit-frame-pointer -fsanitize=address
LDLIBS += -lutil -lnng -pthread
CPPFLAGS += -DCONVEY_NO_THREADS -fno-omit-frame-pointer -fsanitize=address

window_test: window_test.c convey.c ../window.c 
server_test: server_test.c convey.c ../window.c
