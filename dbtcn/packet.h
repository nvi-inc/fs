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

typedef struct {
    uint16_t agc;                // 0 = manual, 1 = agc on
    uint16_t attenuation;        // 0-63 (0.5 dB steps)
    uint16_t total_power;        // 0-65535
    uint16_t total_power_target; // 0-65535 target for AGC
} gcomo_t;

typedef struct {

    uint16_t output_enabled; // 1 == output off, 2 = output on
    // TODO: is this discription right? Is OEN // "Output Enabled"?
    uint16_t lock;        // 0 == no lock, 1 = lock
    uint16_t attenuation; // 0-31 in dB
    uint16_t frequency;   // MHz

} downconverter_t;

typedef struct {
    uint32_t pattern[4]; // Statistics for 00, 01, 10, 11
} bit_statistics32_t;

typedef struct {
    uint16_t pattern[4]; // Statistics for 00, 01, 10, 11
} bit_statistics16_t;

typedef struct {
    uint32_t total_power[4];              // One per sampler
    bit_statistics32_t bit_statistics[4]; // One per sampler
    uint32_t delay_correlation[3];        // S0-S1, S1-S2, S2-S3
} adb3l_t;

typedef struct {
    uint32_t timestamp;
    uint32_t pps_delay;
    uint32_t total_power_cal_on;
    uint32_t total_power_cal_off;
    uint32_t tsys;
    uint32_t sefd;
} core3h_t;

typedef struct {
    uint32_t frequency;
    uint8_t bandwidth;
    uint8_t agc;
    uint8_t gain_usb;
    uint8_t gain_lsb;
    uint32_t total_power_usb_cal_on;
    uint32_t total_power_lsb_cal_on;
    uint32_t total_power_usb_cal_off;
    uint32_t total_power_lsb_cal_off;
    bit_statistics16_t bit_statistics;
    uint16_t tsys_usb;
    uint16_t tsys_lsb;
    uint16_t sefd_usb;
    uint16_t sefd_lsb;
} bbc_t;

typedef struct {
    char version[32];
    gcomo_t gcomo[8];
    downconverter_t downconverter[8];
    adb3l_t adb3l[8];
    core3h_t core3h[8];
    bbc_t bbc[128];
} dbbc3_ddc_multicast_t;
