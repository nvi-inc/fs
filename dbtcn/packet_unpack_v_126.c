/*
 * Copyright (c) 2024 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdint.h>
#include <sys/types.h>

#include "packet.h"
const size_t len_core3h_t_v_126              = 28;
const size_t len_dbbc3_ddc_multicast_t_v_126 = 6240;

ssize_t unmarshal_core3h_t_v_126(core3h_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_core3h_t_v_126)
        return -1;
    t->timestamp = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->vdif_epoch = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->pps_delay = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->total_power_cal_on = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->total_power_cal_off = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->tsys = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->sefd = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    return (p - data);
}

ssize_t unmarshal_dbbc3_ddc_multicast_t_v_126(dbbc3_ddc_multicast_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    int i;

    if (n < len_dbbc3_ddc_multicast_t_v_126)
        return -1;
    for (i = 0; i < 32; i++) {
        t->version[i] = *p++;
        n--;
    }
    for (i = 0; i < 8; i++) {
        ret = unmarshal_gcomo_t(&t->gcomo[i], p, n);
        p += ret;
        n -= ret;
    }
    for (i = 0; i < 8; i++) {
        ret = unmarshal_downconverter_t(&t->downconverter[i], p, n);
        p += ret;
        n -= ret;
    }
    for (i = 0; i < 8; i++) {
        ret = unmarshal_adb3l_t(&t->adb3l[i], p, n);
        p += ret;
        n -= ret;
    }
    for (i = 0; i < 8; i++) {
        ret = unmarshal_core3h_t_v_126(&t->core3h[i], p, n);
        p += ret;
        n -= ret;
    }
    for (i = 0; i < 128; i++) {
        ret = unmarshal_bbc_t(&t->bbc[i], p, n);
        p += ret;
        n -= ret;
    }
    return (p - data);
}
