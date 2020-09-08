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

ssize_t unmarshal_gcomo_t(gcomo_t *t, uint8_t *data, size_t n);
ssize_t unmarshal_downconverter_t(downconverter_t *t, uint8_t *data, size_t n);
ssize_t unmarshal_bit_statistics32_t(bit_statistics32_t *t, uint8_t *data, size_t n);
ssize_t unmarshal_bit_statistics16_t(bit_statistics16_t *t, uint8_t *data, size_t n);
ssize_t unmarshal_adb3l_t(adb3l_t *t, uint8_t *data, size_t n);
ssize_t unmarshal_core3h_t(core3h_t *t, uint8_t *data, size_t n);
ssize_t unmarshal_bbc_t(bbc_t *t, uint8_t *data, size_t n);
ssize_t unmarshal_dbbc3_ddc_multicast_t(dbbc3_ddc_multicast_t *t, uint8_t *data, size_t n);
