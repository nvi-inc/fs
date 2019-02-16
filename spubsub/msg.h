#include <sys/types.h>
#include <stdint.h>

// Output little-endian encoded uint64 to buffer, consuming at most `max` bytes. 
// returns:
//         - number of bytes written on success,
//         - -1 on error and sets errno
ssize_t uint64_marshal_le(unsigned long long n, uint8_t *buf, size_t max);

// Output big-endian encoded uint64 to buffer, consuming at most `max` bytes.
// returns:
//         - number of bytes written on success,
//         - -1 on error and sets errno
ssize_t uint64_marshal_be(unsigned long long n, uint8_t *buf, size_t max);

// Read little-endian encoded uint64 to buffer, reading at most `max` bytes. 
// returns:
//         - number of bytes written on success,
//         - -1 on error and sets errno
ssize_t uint64_unmarshal_le(unsigned long long* out,  uint8_t* buf, size_t max);

// Reads big-endian encoded uint64 to `buf`, reading at most `max` bytes 
// returns:
//         - number of bytes written on success,
//         - -1 on error and sets errno
ssize_t uint64_unmarshal_be(unsigned long long* out,  uint8_t* buf, size_t max);


// Type of msg
typedef enum {
    DATA,
    HEARTBEAT,
    END_OF_SESSION
} msgtype_t;

// Internal representation of network message. 
// `data` should be set to NULL after free.
typedef struct {
    msgtype_t type;
    unsigned long long seq;
    unsigned long long len;
    uint8_t *data; 
} msg_t;


// Encodes message `m` into `buf`, consuming at most `max` bytes.
// Encoded message format is:
// 
//                                
//                            _                                  _ 
//         1        8        |       8           len              |
//      -------------------- |  ---------------------             |
//     | type |    seq     | | |    len    |  data ...            |
//      -------------------- |  ---------------------             |
//                           |        if type == DATA             |
//                            -                                  -
// 
// Where `seq` and `len` are are little-endian encoded.
//
// returns:
//      - number of bytes written 
//      - -1 on error and sets errno
ssize_t msg_marshal(msg_t* m, uint8_t* buf, size_t max);

// Decodes message from `buf` into `m`, consuming at most `max` bytes.
// Expects m->data to be NULL, and caller is expected to `free(m->data)` after use
// 
// returns:
//      - number of bytes read 
//      - -1 on error and sets errno
ssize_t msg_unmarshal(msg_t* m, uint8_t* buf, size_t max);

// Returns number of bytes consumed by `m` when encoded in wire protocol
size_t msg_marshaled_len(msg_t* m);
