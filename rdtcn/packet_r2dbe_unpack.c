#include <stdint.h>
#include <sys/types.h>

#include "packet_r2dbe.h"
const size_t len_r2dbe_multicast_t = 33960;

ssize_t unmarshal_double(double *dp, uint8_t *data, size_t n) {
  uint8_t *p = data;
  uint8_t *t= (uint8_t *) dp;
  int i;

  if (n < sizeof(double))
    return -1;
  for (i = 0; i < sizeof(double); i++) {
    t[sizeof(double)-i-1] = *p++;
    n--;
  }
  return (p-data);
}
ssize_t unmarshal_r2dbe_multicast_t(r2dbe_multicast_t *t, uint8_t *data,
                                    size_t n) {
  ssize_t ret;
  uint8_t *p = data;
  int i;

  if (n < len_r2dbe_multicast_t)
    return -1;
  for (i = 0; i < 32; i++) {
    t->read_time[i] = *p++;
    n--;
  }
  t->pkt_size = (p[1] << 0) | (p[0] << 8);
  p += 2;
  n -= 2;
  t->epoch_ref = (p[1] << 0) | (p[0] << 8);
  p += 2;
  n -= 2;
  t->epoch_sec = (p[3] << 0) | (p[2] << 8) | (p[1] << 16) | (p[0] << 24);
  p += 4;
  n -= 4;
  for (i = 0; i < 20; i++) {
    t->tsys_header[i] = *p++;
    n--;
  }
  for (i = 0; i < 64; i++) {
    t->tsys0_on[i] = (p[3] << 0) | (p[2] << 8) | (p[1] << 16) | (p[0] << 24);
    p += 4;
    n -= 4;
  }
  for (i = 0; i < 64; i++) {
    t->tsys0_off[i] = (p[3] << 0) | (p[2] << 8) | (p[1] << 16) | (p[0] << 24);
    p += 4;
    n -= 4;
  }
  for (i = 0; i < 64; i++) {
    t->tsys1_on[i] = (p[3] << 0) | (p[2] << 8) | (p[1] << 16) | (p[0] << 24);
    p += 4;
    n -= 4;
  }
  for (i = 0; i < 64; i++) {
    t->tsys1_off[i] = (p[3] << 0) | (p[2] << 8) | (p[1] << 16) | (p[0] << 24);
    p += 4;
    n -= 4;
  }
  for (i = 0; i < 20; i++) {
    t->pcal_header[i] = *p++;
    n--;
  }
  t->pcal_ifx = (p[1] << 0) | (p[0] << 8);
  p += 2;
  n -= 2;
  for (i = 0; i < 3; i++) {
    t->pad1[i] = (p[1] << 0) | (p[0] << 8);
    p += 2;
    n -= 2;
  }
  ret = unmarshal_double(&t->pcal_freq, p, n);
  p += ret;
  n -= ret;
  for (i = 0; i < 4096; i++) {
    t->pcal_sin[i] = (p[3] << 0) | (p[2] << 8) | (p[1] << 16) | (p[0] << 24);
    p += 4;
    n -= 4;
  }
  for (i = 0; i < 4096; i++) {
    t->pcal_cos[i] = (p[3] << 0) | (p[2] << 8) | (p[1] << 16) | (p[0] << 24);
    p += 4;
    n -= 4;
  }
  for (i = 0; i < 20; i++) {
    t->raw_header[i] = *p++;
    n--;
  }
  for (i = 0; i < 2; i++) {
    t->pad2[i] = (p[1] << 0) | (p[0] << 8);
    p += 2;
    n -= 2;
  }
  ret = unmarshal_double(&t->mu0, p, n);
  p += ret;
  n -= ret;
  ret = unmarshal_double(&t->sigma0, p, n);
  p += ret;
  n -= ret;
  ret = unmarshal_double(&t->mu1, p, n);
  p += ret;
  n -= ret;
  ret = unmarshal_double(&t->sigma1, p, n);
  p += ret;
  n -= ret;
  ret = unmarshal_double(&t->pps_offset, p, n);
  p += ret;
  n -= ret;
  ret = unmarshal_double(&t->gps_offset, p, n);
  p += ret;
  n -= ret;
  for (i = 0; i < 64; i++) {
    ret = unmarshal_double(&t->ibc0[i], p, n);
    p += ret;
    n -= ret;
  }
  for (i = 0; i < 64; i++) {
    ret = unmarshal_double(&t->ibc1[i], p, n);
    p += ret;
    n -= ret;
  }

  return (p - data);
}
