# Unofficial Makefile for nanomsg for Linux without cmake version >= 2.8

NNG_VERSION := 1.0.1
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

SOURCES := \
	$(NNG_DIR)/src/nng.c\
	\
	$(NNG_DIR)/src/core/aio.c\
	$(NNG_DIR)/src/core/clock.c\
	$(NNG_DIR)/src/core/device.c\
	$(NNG_DIR)/src/core/dialer.c\
	$(NNG_DIR)/src/core/file.c\
	$(NNG_DIR)/src/core/idhash.c\
	$(NNG_DIR)/src/core/init.c\
	$(NNG_DIR)/src/core/list.c\
	$(NNG_DIR)/src/core/listener.c\
	$(NNG_DIR)/src/core/message.c\
	$(NNG_DIR)/src/core/msgqueue.c\
	$(NNG_DIR)/src/core/options.c\
	$(NNG_DIR)/src/core/pollable.c\
	$(NNG_DIR)/src/core/panic.c\
	$(NNG_DIR)/src/core/pipe.c\
	$(NNG_DIR)/src/core/protocol.c\
	$(NNG_DIR)/src/core/random.c\
	$(NNG_DIR)/src/core/reap.c\
	$(NNG_DIR)/src/core/socket.c\
	$(NNG_DIR)/src/core/strs.c\
	$(NNG_DIR)/src/core/taskq.c\
	$(NNG_DIR)/src/core/thread.c\
	$(NNG_DIR)/src/core/timer.c\
	$(NNG_DIR)/src/core/transport.c\
	$(NNG_DIR)/src/core/url.c\
	\
	$(NNG_DIR)/src/platform/posix/posix_alloc.c\
	$(NNG_DIR)/src/platform/posix/posix_atomic.c\
	$(NNG_DIR)/src/platform/posix/posix_clock.c\
	$(NNG_DIR)/src/platform/posix/posix_debug.c\
	$(NNG_DIR)/src/platform/posix/posix_epdesc.c\
	$(NNG_DIR)/src/platform/posix/posix_file.c\
	$(NNG_DIR)/src/platform/posix/posix_ipc.c\
	$(NNG_DIR)/src/platform/posix/posix_pipe.c\
	$(NNG_DIR)/src/platform/posix/posix_pipedesc.c\
	$(NNG_DIR)/src/platform/posix/posix_rand.c\
	$(NNG_DIR)/src/platform/posix/posix_resolv_gai.c\
	$(NNG_DIR)/src/platform/posix/posix_sockaddr.c\
	$(NNG_DIR)/src/platform/posix/posix_tcp.c\
	$(NNG_DIR)/src/platform/posix/posix_thread.c\
	$(NNG_DIR)/src/platform/posix/posix_udp.c\
	$(NNG_DIR)/src/platform/posix/posix_pollq_poll.c\
	\
	$(NNG_DIR)/src/compat/nanomsg/nn.c\
	\
	$(NNG_DIR)/src/protocol/pipeline0/pull.c\
	$(NNG_DIR)/src/protocol/pipeline0/push.c\
	$(NNG_DIR)/src/protocol/pair0/pair.c\
	$(NNG_DIR)/src/protocol/pair1/pair.c\
	$(NNG_DIR)/src/protocol/reqrep0/xreq.c\
	$(NNG_DIR)/src/protocol/reqrep0/rep.c\
	$(NNG_DIR)/src/protocol/reqrep0/req.c\
	$(NNG_DIR)/src/protocol/reqrep0/xrep.c\
	$(NNG_DIR)/src/protocol/survey0/respond.c\
	$(NNG_DIR)/src/protocol/survey0/survey.c\
	$(NNG_DIR)/src/protocol/survey0/xrespond.c\
	$(NNG_DIR)/src/protocol/survey0/xsurvey.c\
	$(NNG_DIR)/src/protocol/bus0/bus.c\
	$(NNG_DIR)/src/protocol/pubsub0/sub.c\
	$(NNG_DIR)/src/protocol/pubsub0/pub.c\
	$(NNG_DIR)/src/supplemental/http/http_msg.c\
	$(NNG_DIR)/src/supplemental/http/http_conn.c\
	$(NNG_DIR)/src/supplemental/http/http_client.c\
	$(NNG_DIR)/src/supplemental/http/http_public.c\
	$(NNG_DIR)/src/supplemental/http/http_server.c\
	$(NNG_DIR)/src/supplemental/sha1/sha1.c\
	$(NNG_DIR)/src/supplemental/websocket/websocket.c\
	$(NNG_DIR)/src/supplemental/tls/none/tls.c\
	$(NNG_DIR)/src/supplemental/base64/base64.c\
	$(NNG_DIR)/src/supplemental/util/options.c\
	$(NNG_DIR)/src/supplemental/util/platform.c\
	\
	$(NNG_DIR)/src/transport/tcp/tcp.c\
	$(NNG_DIR)/src/transport/inproc/inproc.c\
	$(NNG_DIR)/src/transport/tls/tls.c\
	$(NNG_DIR)/src/transport/ipc/ipc.c\
	$(NNG_DIR)/src/transport/ws/websocket.c


HEADERS = \
		  protocol/pubsub0/pub.h\
		  protocol/pubsub0/sub.h\
		  protocol/survey0/respond.h\
		  protocol/survey0/survey.h\
		  protocol/pair0/pair.h\
		  protocol/reqrep0/req.h\
		  protocol/reqrep0/rep.h\
		  protocol/pipeline0/push.h\
		  protocol/pipeline0/pull.h\
		  protocol/pair1/pair.h\
		  protocol/bus0/bus.h\
		  platform/posix/posix_pollq.h\
		  platform/posix/posix_impl.h\
		  platform/posix/posix_aio.h\
		  platform/posix/posix_config.h\
		  platform/windows/win_impl.h\
		  supplemental/websocket/websocket.h\
		  supplemental/sha1/sha1.h\
		  supplemental/base64/base64.h\
		  supplemental/tls/tls_api.h\
		  supplemental/tls/tls.h\
		  supplemental/http/http_api.h\
		  supplemental/http/http.h\
		  supplemental/util/options.h\
		  supplemental/util/platform.h\
		  transport/inproc/inproc.h\
		  transport/ipc/ipc.h\
		  transport/ws/websocket.h\
		  transport/tcp/tcp.h\
		  transport/zerotier/zerotier.h\
		  transport/tls/tls.h\
		  nng.h\
		  compat/nanomsg/pair.h\
		  compat/nanomsg/reqrep.h\
		  compat/nanomsg/inproc.h\
		  compat/nanomsg/bus.h\
		  compat/nanomsg/pipeline.h\
		  compat/nanomsg/pubsub.h\
		  compat/nanomsg/survey.h\
		  compat/nanomsg/tcp.h\
		  compat/nanomsg/ipc.h\
		  compat/nanomsg/ws.h\
		  compat/nanomsg/nn.h

HEADERS_SRC = $(addprefix $(NNG_DIR)/src/, $(HEADERS))


$(SOURCES): $(NNG_ARCHIVE)
	tar xzmf $(NNG_ARCHIVE)


CFLAGS +=  -Wall -Wextra -fno-omit-frame-pointer -std=gnu99 -isystem $(NNG_DIR)/src
CPPFLAGS += \
			-DNNG_HAVE_ALLOCA=1 \
			-DNNG_HAVE_BACKTRACE=1 \
			-DNNG_HAVE_BUS0 \
			-DNNG_HAVE_CLOCK_GETTIME=1 \
			-DNNG_HAVE_FLOCK=1 \
			-DNNG_HAVE_LIBNSL=1 \
			-DNNG_HAVE_LOCKF=1 \
			-DNNG_HAVE_MSG_CONTROL=1 \
			-DNNG_HAVE_PAIR0 \
			-DNNG_HAVE_PAIR1 \
			-DNNG_HAVE_PUB0 \
			-DNNG_HAVE_PULL0 \
			-DNNG_HAVE_PUSH0 \
			-DNNG_HAVE_REP0 \
			-DNNG_HAVE_REQ0 \
			-DNNG_HAVE_RESPONDENT0 \
			-DNNG_HAVE_SEMAPHORE_PTHREAD=1 \
			-DNNG_HAVE_SOPEERCRED=1 \
			-DNNG_HAVE_STRCASECMP=1 \
			-DNNG_HAVE_STRNCASECMP=1 \
			-DNNG_HAVE_STRNLEN=1 \
			-DNNG_HAVE_SUB0 \
			-DNNG_HAVE_SURVEYOR0 \
			-DNNG_HAVE_UNIX_SOCKETS=1 \
			-DNNG_HIDDEN_VISIBILITY \
			-DNNG_LITTLE_ENDIAN \
			-DNNG_PLATFORM_LINUX \
			-DNNG_PLATFORM_POSIX \
			-DNNG_PRIVATE \
			-DNNG_STATIC_LIB \
			-DNNG_SUPP_HTTP \
			-DNNG_TRANSPORT_INPROC \
			-DNNG_TRANSPORT_IPC \
			-DNNG_TRANSPORT_TCP \
			-DNNG_TRANSPORT_WS \
			-D_GNU_SOURCE \
			-D_POSIX_PTHREAD_SEMANTICS \
			-D_REENTRANT \
			-D_THREAD_SAFE \
			-DNNG_HAVE_EPOLL=1  \
			-DNNG_HAVE_EPOLL_CREATE1=1

OBJECTS :=  $(SOURCES:.c=.o)
$(NNG_LIBRARY): $(OBJECTS)
	$(AR) cr $@ $^


.PHONY : clean
clean :
	@rm -rf $(NNG_DIR)



.PHONY: install
install: $(NNG_LIBRARY) $(HEADERS_SRC)
	install -D $(NNG_LIBRARY) $(PREFIX)/lib/libnng.a
	for h in $(HEADERS); do \
		install -D $(NNG_DIR)/src/$$h $(PREFIX)/include/nng/$$h ; \
	done

