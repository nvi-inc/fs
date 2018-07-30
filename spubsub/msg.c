#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <nng/compat/nanomsg/nn.h>
#include "msg.h"

// Output little-endian encoded uint64 to buffer,
// returns:
//         - number of bytes written on success,
//         - -1 on error and sets errno
ssize_t uint64_marshal_le(uint64_t n, uint8_t *buf, size_t max) {
    if (max < 8) {
        errno = EOVERFLOW;     
        return -1;
    }

    buf[0] = n >> 000;
    buf[1] = n >> 010;
    buf[2] = n >> 020;
    buf[3] = n >> 030;

    buf[4] = n >> 040;
    buf[5] = n >> 050;
    buf[6] = n >> 060;
    buf[7] = n >> 070;

    return 8;
}

// Output big-endian encoded uint64 to buffer,
// returns:
//         - number of bytes written on success,
//         - -1 on error and sets errno
ssize_t uint64_marshal_be(uint64_t n, uint8_t *buf, size_t max) {
    if (max < 8) {
        errno = EOVERFLOW;     
        return -1;
    }

    buf[0] = n >> 070;
    buf[1] = n >> 060;
    buf[2] = n >> 050;
    buf[3] = n >> 040;

    buf[4] = n >> 030;
    buf[5] = n >> 020;
    buf[6] = n >> 010;
    buf[7] = n >> 000;

    return 8;
}

// Read little-endian encoded uint64 to buffer,
// returns:
//         - number of bytes written on success,
//         - -1 on error and sets errno
ssize_t uint64_unmarshal_le(uint64_t *out,  uint8_t *buf, size_t max) {
    if (max < 8) {
        errno = EOVERFLOW;     
        return -1;
    }

    *out = 0;
    *out |= (uint64_t)buf[0]<<000;
    *out |= (uint64_t)buf[1]<<010;
    *out |= (uint64_t)buf[2]<<020;
    *out |= (uint64_t)buf[3]<<030;

    *out |= (uint64_t)buf[4]<<040;
    *out |= (uint64_t)buf[5]<<050;
    *out |= (uint64_t)buf[6]<<060;
    *out |= (uint64_t)buf[7]<<070;
    return 8;
}

// Read big-endian encoded uint64 to buffer,
// returns:
//         - number of bytes written on success,
//         - -1 on error and sets errno
ssize_t uint64_unmarshal_be(uint64_t *out,  uint8_t *buf, size_t max) {
    if (max < 8) {
        errno = EOVERFLOW;     
        return -1;
    }

    *out = 0;
    *out |= (uint64_t)buf[0]<<070;
    *out |= (uint64_t)buf[1]<<060;
    *out |= (uint64_t)buf[2]<<050;
    *out |= (uint64_t)buf[3]<<040;

    *out |= (uint64_t)buf[4]<<030;
    *out |= (uint64_t)buf[5]<<020;
    *out |= (uint64_t)buf[6]<<010;
    *out |= (uint64_t)buf[7]<<000;

    return 8;
}



size_t msg_marshaled_len(msg_t* m) {
    if (m == NULL) return 0;
    if (m->type != DATA)
        return sizeof(uint8_t) + sizeof(m->seq);
    return sizeof(uint8_t) + sizeof(m->seq) + sizeof(m->len) + m->len*sizeof(char);
}

ssize_t msg_marshal(msg_t* m, uint8_t* buf, size_t max) {
    if (m->data == NULL && m->len != 0) {
        errno = EINVAL;
        return -1;
    }
    if (msg_marshaled_len(m) > max) {
        errno = EOVERFLOW;     
        return -1;
    }

    int nbytes = 0;

    buf[0] = m->type;
    nbytes++;
    buf++;

    int n = uint64_marshal_le(m->seq, buf, max - nbytes);
    if (n < 0) return -1;

    nbytes += n;
    buf += n;

    if (m->type != DATA){
        return nbytes;
    }

    n = uint64_marshal_le(m->len, buf, max - nbytes);
    if (n < 0) return -1;
    nbytes += n;
    buf += n;

    if (m->type != DATA || m->len == 0)
        return nbytes;

    for(size_t i = 0; i < m->len; i++) buf[i] = m->data[i];

    nbytes += m->len;
    return nbytes;
}


// Decode msg in `buf` into `m`, at most consuming `max` bytes.
// Fields are little-endian.
// Returns number of bytes consumed or -1 on error.
// Expects m->data to be NULL, and caller is expected to `free(m->data)` after use
ssize_t msg_unmarshal(msg_t* m, uint8_t* buf, size_t max) {
    if (m == NULL) return -1;

    if (m->data != NULL) {
        errno = EUCLEAN;
        return -1;
    }

    int nbytes = 0;
    int n = 0;

    m->type = buf[0];
    nbytes++;
    buf++;

    uint64_t seq;
    n = uint64_unmarshal_le(&seq, buf, max-nbytes);
    if (n < 0){
        return -1;
    }
    m->seq = seq;
    nbytes += n;
    buf += n;

    if (m->type != DATA){
        return nbytes;
    }

    uint64_t len;
    n = uint64_unmarshal_le(&len, buf, max-nbytes);
    if (n < 0) {
        return -1;
    }
    m->len = len;
    nbytes += n;
    buf += n;

    // DATA msgs shouldn't have no data, but just to be sure...
    if (len == 0) return nbytes;

    uint8_t *data = malloc(len*sizeof(char));
    if (data == NULL) {
        return -1;
    }
    memcpy(data, buf, len);
    m->data = data;
    nbytes += len;

    return nbytes;
}
