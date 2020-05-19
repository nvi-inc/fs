# Unofficial Makefile for nanomsg for Linux without cmake version >= 3.17

NNG_VERSION := 1.3.0
NNG_DIR     := nng-$(NNG_VERSION)
NNG_ARCHIVE := $(NNG_DIR).tar.gz
NNG_LIBRARY := $(NNG_DIR)/libnng.a

PREFIX?=/usr/local

ifndef V
	CCCOLOR="\033[34m"
	LINKCOLOR="\033[34;1m"
	SRCCOLOR="\033[33m"
	BINCOLOR="\033[37;1m"
	MAKECOLOR="\033[32;1m"
	ENDCOLOR="\033[0m"

OLD_CC := $(CC)
OLD_LINK := $(LINK)
OLD_AR := $(AR)
OLD_INSTALL := $(INSTALL)

QUIET_CC      = @printf '    %b %b\n' $(CCCOLOR)CC$(ENDCOLOR) $(SRCCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_AR      = @printf '    %b %b\n' $(LINKCOLOR)AR$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_LINK    = @printf '    %b %b\n' $(LINKCOLOR)LINK$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;
QUIET_INSTALL = @printf '    %b %b\n' $(LINKCOLOR)INSTALL$(ENDCOLOR) $(BINCOLOR)$@$(ENDCOLOR) 1>&2;

CC =$(QUIET_CC)$(OLD_CC)
LD =$(QUIET_LINK)$(OLD_LD)
AR =$(QUIET_AR)$(OLD_AR)

INSTALL:=$(QUIET_INSTALL)$(OLD_INSTALL)
endif


all: $(NNG_LIBRARY)

SOURCES := nng.c\
compat/nanomsg/nn.c\
protocol/bus0/bus.c\
protocol/pair0/pair.c\
protocol/pair1/pair.c\
protocol/pair1/pair1_poly.c\
protocol/pipeline0/push.c\
protocol/pipeline0/pull.c\
protocol/pubsub0/pub.c\
protocol/pubsub0/sub.c\
protocol/pubsub0/xsub.c\
protocol/reqrep0/req.c\
protocol/reqrep0/xreq.c\
protocol/reqrep0/rep.c\
protocol/reqrep0/xrep.c\
protocol/survey0/survey.c\
protocol/survey0/xsurvey.c\
protocol/survey0/respond.c\
protocol/survey0/xrespond.c\
transport/inproc/inproc.c\
transport/ipc/ipc.c\
transport/tcp/tcp.c\
transport/tls/tls.c\
supplemental/sha1/sha1.c\
supplemental/tcp/tcp.c\
supplemental/tls/tls_common.c\
supplemental/util/options.c\
supplemental/util/platform.c\
supplemental/websocket/websocket.c\
core/aio.c\
core/clock.c\
core/device.c\
core/dialer.c\
core/file.c\
core/idhash.c\
core/init.c\
core/list.c\
core/listener.c\
core/lmq.c\
core/message.c\
core/msgqueue.c\
core/options.c\
core/pollable.c\
core/panic.c\
core/pipe.c\
core/protocol.c\
core/reap.c\
core/socket.c\
core/stats.c\
core/stream.c\
core/strs.c\
core/taskq.c\
core/thread.c\
core/timer.c\
core/transport.c\
core/url.c\
platform/posix/posix_alloc.c\
platform/posix/posix_atomic.c\
platform/posix/posix_clock.c\
platform/posix/posix_debug.c\
platform/posix/posix_file.c\
platform/posix/posix_ipcconn.c\
platform/posix/posix_ipcdial.c\
platform/posix/posix_ipclisten.c\
platform/posix/posix_pipe.c\
platform/posix/posix_resolv_gai.c\
platform/posix/posix_sockaddr.c\
platform/posix/posix_tcpconn.c\
platform/posix/posix_tcpdial.c\
platform/posix/posix_tcplisten.c\
platform/posix/posix_thread.c\
platform/posix/posix_udp.c\
platform/posix/posix_pollq_epoll.c\
platform/posix/posix_rand_urandom.c\
transport/ws/websocket.c\
supplemental/base64/base64.c\
supplemental/http/http_public.c\
supplemental/http/http_client.c\
supplemental/http/http_chunk.c\
supplemental/http/http_conn.c\
supplemental/http/http_msg.c\
supplemental/http/http_server.c\

SOURCES := $(addprefix $(NNG_DIR)/src/, $(SOURCES))

HEADERS =  nng/compat/nanomsg/ipc.h nng/compat/nanomsg/inproc.h nng/compat/nanomsg/pubsub.h nng/compat/nanomsg/survey.h nng/compat/nanomsg/pipeline.h nng/compat/nanomsg/ws.h nng/compat/nanomsg/nn.h nng/compat/nanomsg/reqrep.h nng/compat/nanomsg/tcp.h nng/compat/nanomsg/bus.h nng/compat/nanomsg/pair.h nng/nng.h nng/protocol/reqrep0/rep.h nng/protocol/reqrep0/req.h nng/protocol/pair1/pair.h nng/protocol/survey0/respond.h nng/protocol/survey0/survey.h nng/protocol/pipeline0/push.h nng/protocol/pipeline0/pull.h nng/protocol/pubsub0/pub.h nng/protocol/pubsub0/sub.h nng/protocol/pair0/pair.h nng/protocol/bus0/bus.h nng/transport/tls/tls.h nng/transport/inproc/inproc.h nng/transport/ws/websocket.h nng/transport/zerotier/zerotier.h nng/transport/ipc/ipc.h nng/transport/tcp/tcp.h nng/supplemental/tls/engine.h nng/supplemental/tls/tls.h nng/supplemental/util/options.h nng/supplemental/util/platform.h nng/supplemental/http/http.h 

HEADERS_SRC = $(addprefix $(NNG_DIR)/include/, $(HEADERS))


$(SOURCES): $(NNG_ARCHIVE)
	tar xzmf $(NNG_ARCHIVE)


CFLAGS += -g -Wall -Wextra -fno-omit-frame-pointer     -std=gnu99
CPPFLAGS = -DNNG_ENABLE_STATS -DNNG_HAVE_BACKTRACE=1 -DNNG_HAVE_BUS0 -DNNG_HAVE_CLOCK_GETTIME=1 -DNNG_HAVE_EPOLL=1 -DNNG_HAVE_EPOLL_CREATE1=1 -DNNG_HAVE_EVENTFD=1 -DNNG_HAVE_FLOCK=1 -DNNG_HAVE_LIBNSL=1 -DNNG_HAVE_LOCKF=1 -DNNG_HAVE_MSG_CONTROL=1 -DNNG_HAVE_PAIR0 -DNNG_HAVE_PAIR1 -DNNG_HAVE_PTHREAD_ATFORK_PTHREAD=1 -DNNG_HAVE_PUB0 -DNNG_HAVE_PULL0 -DNNG_HAVE_PUSH0 -DNNG_HAVE_REP0 -DNNG_HAVE_REQ0 -DNNG_HAVE_RESPONDENT0 -DNNG_HAVE_SEMAPHORE_PTHREAD=1 -DNNG_HAVE_SOPEERCRED=1 -DNNG_HAVE_STDATOMIC=1 -DNNG_HAVE_STRCASECMP=1 -DNNG_HAVE_STRNCASECMP=1 -DNNG_HAVE_STRNLEN=1 -DNNG_HAVE_SUB0 -DNNG_HAVE_SURVEYOR0 -DNNG_HAVE_UNIX_SOCKETS=1 -DNNG_HIDDEN_VISIBILITY -DNNG_LITTLE_ENDIAN -DNNG_MAX_TASKQ_THREADS=16 -DNNG_PLATFORM_LINUX -DNNG_PLATFORM_POSIX -DNNG_PRIVATE -DNNG_STATIC_LIB -DNNG_SUPP_HTTP -DNNG_TRANSPORT_INPROC -DNNG_TRANSPORT_IPC -DNNG_TRANSPORT_TCP -DNNG_TRANSPORT_TLS -DNNG_TRANSPORT_WS -DNNG_USE_EVENTFD -D_GNU_SOURCE -D_POSIX_PTHREAD_SEMANTICS -D_REENTRANT -D_THREAD_SAFE -I/usr2/fs/third_party/src/nng-1.3.0/include -isystem /usr2/fs/third_party/src/nng-1.3.0/src 

OBJECTS :=  $(SOURCES:.c=.o)
$(NNG_LIBRARY): $(OBJECTS)
	$(AR) cr $@ $^


.PHONY : clean
clean :
	@rm -rf $(NNG_DIR)



.PHONY: install
install: $(NNG_LIBRARY) $(HEADERS_SRC)
	install -m 0644 -D $(NNG_LIBRARY) $(PREFIX)/lib/libnng.a
	for h in $(HEADERS); do \
		install -m 0644 -D $(NNG_DIR)/include/$$h $(PREFIX)/include/$$h ; \
	done

