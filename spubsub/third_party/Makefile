# Unofficial Makefile for nanomsg for Linux without cmake version >= 2.8
# Tested on Debian Lenny

SOURCES := \
    nanomsg/src/core/ep.c\
    nanomsg/src/core/global.c\
    nanomsg/src/core/pipe.c\
    nanomsg/src/core/poll.c\
    nanomsg/src/core/sock.c\
    nanomsg/src/core/sockbase.c\
    nanomsg/src/core/symbol.c\
\
    nanomsg/src/aio/ctx.c\
    nanomsg/src/aio/fsm.c\
    nanomsg/src/aio/pool.c\
    nanomsg/src/aio/timer.c\
    nanomsg/src/aio/timerset.c\
    nanomsg/src/aio/usock.c\
    nanomsg/src/aio/worker.c\
\
    nanomsg/src/utils/alloc.c\
    nanomsg/src/utils/atomic.c\
    nanomsg/src/utils/chunk.c\
    nanomsg/src/utils/chunkref.c\
    nanomsg/src/utils/clock.c\
    nanomsg/src/utils/closefd.c\
    nanomsg/src/utils/efd.c\
    nanomsg/src/utils/err.c\
    nanomsg/src/utils/hash.c\
    nanomsg/src/utils/list.c\
    nanomsg/src/utils/msg.c\
    nanomsg/src/utils/condvar.c\
    nanomsg/src/utils/mutex.c\
    nanomsg/src/utils/once.c\
    nanomsg/src/utils/queue.c\
    nanomsg/src/utils/random.c\
    nanomsg/src/utils/sem.c\
    nanomsg/src/utils/sleep.c\
    nanomsg/src/utils/strcasecmp.c\
    nanomsg/src/utils/strcasestr.c\
    nanomsg/src/utils/strncasecmp.c\
    nanomsg/src/utils/thread.c\
    nanomsg/src/utils/wire.c\
\
    nanomsg/src/devices/device.c\
\
    nanomsg/src/protocols/utils/dist.c\
    nanomsg/src/protocols/utils/excl.c\
    nanomsg/src/protocols/utils/fq.c\
    nanomsg/src/protocols/utils/lb.c\
    nanomsg/src/protocols/utils/priolist.c\
\
    nanomsg/src/protocols/bus/bus.c\
    nanomsg/src/protocols/bus/xbus.c\
\
    nanomsg/src/protocols/pipeline/push.c\
    nanomsg/src/protocols/pipeline/pull.c\
    nanomsg/src/protocols/pipeline/xpull.c\
    nanomsg/src/protocols/pipeline/xpush.c\
\
    nanomsg/src/protocols/pair/pair.c\
    nanomsg/src/protocols/pair/xpair.c\
\
    nanomsg/src/protocols/pubsub/pub.c\
    nanomsg/src/protocols/pubsub/sub.c\
    nanomsg/src/protocols/pubsub/trie.c\
    nanomsg/src/protocols/pubsub/xpub.c\
    nanomsg/src/protocols/pubsub/xsub.c\
\
    nanomsg/src/protocols/reqrep/req.c\
    nanomsg/src/protocols/reqrep/rep.c\
    nanomsg/src/protocols/reqrep/task.c\
    nanomsg/src/protocols/reqrep/xrep.c\
    nanomsg/src/protocols/reqrep/xreq.c\
\
    nanomsg/src/protocols/survey/respondent.c\
    nanomsg/src/protocols/survey/surveyor.c\
    nanomsg/src/protocols/survey/xrespondent.c\
    nanomsg/src/protocols/survey/xsurveyor.c\
\
    nanomsg/src/transports/utils/backoff.c\
    nanomsg/src/transports/utils/dns.c\
    nanomsg/src/transports/utils/iface.c\
    nanomsg/src/transports/utils/literal.c\
    nanomsg/src/transports/utils/port.c\
    nanomsg/src/transports/utils/streamhdr.c\
    nanomsg/src/transports/utils/base64.c\
\
    nanomsg/src/transports/inproc/binproc.c\
    nanomsg/src/transports/inproc/cinproc.c\
    nanomsg/src/transports/inproc/inproc.c\
    nanomsg/src/transports/inproc/ins.c\
    nanomsg/src/transports/inproc/msgqueue.c\
    nanomsg/src/transports/inproc/sinproc.c\
\
    nanomsg/src/transports/ipc/aipc.c\
    nanomsg/src/transports/ipc/bipc.c\
    nanomsg/src/transports/ipc/cipc.c\
    nanomsg/src/transports/ipc/ipc.c\
    nanomsg/src/transports/ipc/sipc.c\
\
    nanomsg/src/transports/tcp/atcp.c\
    nanomsg/src/transports/tcp/btcp.c\
    nanomsg/src/transports/tcp/ctcp.c\
    nanomsg/src/transports/tcp/stcp.c\
    nanomsg/src/transports/tcp/tcp.c\
\
    nanomsg/src/transports/ws/aws.c\
    nanomsg/src/transports/ws/bws.c\
    nanomsg/src/transports/ws/cws.c\
    nanomsg/src/transports/ws/sws.c\
    nanomsg/src/transports/ws/ws.c\
    nanomsg/src/transports/ws/ws_handshake.c\
    nanomsg/src/transports/ws/sha1.c\
\
    nanomsg/src/aio/poller.c



# Debian Version >= Wheezy
#CFLAGS := \
#	-DNN_HAVE_BACKTRACE=1 \
#	-DNN_HAVE_CLOCK_GETTIME=1 \
#	-DNN_HAVE_CLOCK_MONOTONIC=1 \
#	-DNN_HAVE_GCC_ATOMIC_BUILTINS \
#	-DNN_HAVE_GETADDRINFO_A=1 \
#	-DNN_HAVE_LIBNSL=1 \
#	-DNN_HAVE_LINUX \
#	-DNN_HAVE_MSG_CONTROL=1 \
#	-DNN_HAVE_PIPE2=1 \
#	-DNN_HAVE_PIPE=1 \
#	-DNN_HAVE_POLL=1 \
#	-DNN_HAVE_SEMAPHORE \
#	-DNN_HAVE_SEMAPHORE_PTHREAD=1 \
#	-DNN_HAVE_SOCKETPAIR=1 \
#	-DNN_HAVE_UNIX_SOCKETS=1 \
#	-DNN_MAX_SOCKETS=512 \
#	-D_GNU_SOURCE \
#	-D_POSIX_PTHREAD_SEMANTICS \
#	-D_REENTRANT \
#	-D_THREAD_SAFE \
#	-DNN_HAVE_ACCEPT4=1 \
#	-DNN_USE_EVENTFD=1 \
#
#export ARFLAGS=rvU

# Debian Version >= Lenny (perhaps earlier)
CFLAGS := \
	-DNN_HAVE_BACKTRACE=1\
	-DNN_HAVE_CLOCK_GETTIME=1\
	-DNN_HAVE_CLOCK_MONOTONIC=1\
	-DNN_HAVE_EPOLL=1\
	-DNN_HAVE_GCC_ATOMIC_BUILTINS\
	-DNN_HAVE_GETADDRINFO_A=1\
	-DNN_HAVE_LIBNSL=1\
	-DNN_HAVE_LINUX\
	-DNN_HAVE_MSG_CONTROL=1\
	-DNN_HAVE_PIPE=1\
	-DNN_HAVE_POLL=1\
	-DNN_HAVE_SEMAPHORE\
	-DNN_HAVE_SEMAPHORE_PTHREAD=1\
	-DNN_HAVE_SOCKETPAIR=1\
	-DNN_HAVE_UNIX_SOCKETS=1\
	-DNN_MAX_SOCKETS=512\
	-D_GNU_SOURCE\
	-D_POSIX_PTHREAD_SEMANTICS\
	-D_REENTRANT\
	-D_THREAD_SAFE\
	-DNN_USE_EPOLL\
	-DNN_USE_PIPE\
	-DNN_HAVE_SEMAPHORE_RT=1 



OBJECTS :=  $(SOURCES:.c=.o)

libnanomsg.a: libnanomsg.a($(OBJECTS))

.PHONY : clean
clean :
	-rm -f libnanomsg.a 
	-rm -f $(OBJECTS)
