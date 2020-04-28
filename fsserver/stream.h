#include <stdlib.h>

// buffered_stream_t represents the publisher side of a buffered stream of bytes.
typedef struct buffered_stream buffered_stream_t;

// buffered_stream_open performs the setup of a buffered_stream_socket 
int buffered_stream_open(buffered_stream_t **s);
int buffered_stream_listen(buffered_stream_t *s, const char* pub_url, const char* rep_url);

ssize_t buffered_stream_send(buffered_stream_t *s, const void *buf, size_t n);

// buffered_stream_close puts the buffered stream in the "shutdown" state, during which
// new messages can no longer be published but a shutdown message will be
// periodically broadcast and clients can still query the buffer. After a
// period specified by buffered_stream_set_shutdown_period (default 5s)
void buffered_stream_close(buffered_stream_t *s);

// buffered_stream_set_heartbeat sets the heartbeat period in milliseconds of
// the buffered socket. Heatbeat messages are used to inform subscribers
// of the current sequence number during quiescent periods. This is therefore
// the time you can expect a subscriber to remain out of sync.
void buffered_stream_set_heartbeat(buffered_stream_t *s, int heartbeat_millis);

// buffered_stream_set_shutdown sets the number of milliseconds the socket will
// remain accessible in "shutdown" state after buffered_steram_close is called.
void buffered_stream_set_shutdown_period(buffered_stream_t *s, int shutdown_millis);

// buffered_stream_kill kills a buffered stream left in the shutdown state.
void buffered_stream_kill(buffered_stream_t *s);

// buffered_stream_set_len sets the length of the buffered stream's buffer.
// It is an error to do this after the first send.
int buffered_stream_set_len(buffered_stream_t *s, size_t len);

void buffered_stream_join(buffered_stream_t *s);
