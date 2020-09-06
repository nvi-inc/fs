/*
 * Copyright (c) 2020 NVI, Inc.
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
const size_t len_gcomo_t               = 8;
const size_t len_downconverter_t       = 8;
const size_t len_bit_statistics32_t    = 16;
const size_t len_bit_statistics16_t    = 8;
const size_t len_adb3l_t               = 92;
const size_t len_core3h_t              = 24;
const size_t len_bbc_t                 = 40;
const size_t len_dbbc3_ddc_multicast_t = 6208;

ssize_t unmarshal_gcomo_t(gcomo_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_gcomo_t)
        return -1;
    t->agc = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->attenuation = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->total_power = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->total_power_target = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    return (p - data);
}

ssize_t unmarshal_downconverter_t(downconverter_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_downconverter_t)
        return -1;
    t->output_enabled = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->lock = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->attenuation = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->frequency = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    return (p - data);
}

ssize_t unmarshal_bit_statistics32_t(bit_statistics32_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_bit_statistics32_t)
        return -1;
    for (int i = 0; i < 4; i++) {
        t->pattern[i] = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
        p += 4;
        n -= 4;
    }
    return (p - data);
}

ssize_t unmarshal_bit_statistics16_t(bit_statistics16_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_bit_statistics16_t)
        return -1;
    for (int i = 0; i < 4; i++) {
        t->pattern[i] = (p[0] << 0) | (p[1] << 8);
        p += 2;
        n -= 2;
    }
    return (p - data);
}

ssize_t unmarshal_adb3l_t(adb3l_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_adb3l_t)
        return -1;
    for (int i = 0; i < 4; i++) {
        t->total_power[i] = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
        p += 4;
        n -= 4;
    }
    for (int i = 0; i < 4; i++) {
        ret = unmarshal_bit_statistics32_t(&t->bit_statistics[i], p, n);
        p += ret;
        n -= ret;
    }
    for (int i = 0; i < 3; i++) {
        t->delay_correlation[i] = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
        p += 4;
        n -= 4;
    }
    return (p - data);
}

ssize_t unmarshal_core3h_t(core3h_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_core3h_t)
        return -1;
    t->timestamp = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
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

ssize_t unmarshal_bbc_t(bbc_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_bbc_t)
        return -1;
    t->frequency = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->bandwidth = *p++;
    n--;
    t->agc = *p++;
    n--;
    t->gain_usb = *p++;
    n--;
    t->gain_lsb = *p++;
    n--;
    t->total_power_usb_cal_on = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->total_power_lsb_cal_on = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->total_power_usb_cal_off = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    t->total_power_lsb_cal_off = (p[0] << 0) | (p[1] << 8) | (p[2] << 16) | (p[3] << 24);
    p += 4;
    n -= 4;
    ret = unmarshal_bit_statistics16_t(&t->bit_statistics, p, n);
    p += ret;
    n -= ret;
    t->tsys_usb = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->tsys_lsb = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->sefd_usb = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    t->sefd_lsb = (p[0] << 0) | (p[1] << 8);
    p += 2;
    n -= 2;
    return (p - data);
}

ssize_t unmarshal_dbbc3_ddc_multicast_t(dbbc3_ddc_multicast_t *t, uint8_t *data, size_t n) {
    ssize_t ret;
    uint8_t *p = data;
    if (n < len_dbbc3_ddc_multicast_t)
        return -1;
    for (int i = 0; i < 32; i++) {
        t->version[i] = *p++;
        n--;
    }
    for (int i = 0; i < 8; i++) {
        ret = unmarshal_gcomo_t(&t->gcomo[i], p, n);
        p += ret;
        n -= ret;
    }
    for (int i = 0; i < 8; i++) {
        ret = unmarshal_downconverter_t(&t->downconverter[i], p, n);
        p += ret;
        n -= ret;
    }
    for (int i = 0; i < 8; i++) {
        ret = unmarshal_adb3l_t(&t->adb3l[i], p, n);
        p += ret;
        n -= ret;
    }
    for (int i = 0; i < 8; i++) {
        ret = unmarshal_core3h_t(&t->core3h[i], p, n);
        p += ret;
        n -= ret;
    }
    for (int i = 0; i < 128; i++) {
        ret = unmarshal_bbc_t(&t->bbc[i], p, n);
        p += ret;
        n -= ret;
    }
    return (p - data);
}
