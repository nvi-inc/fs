/*
 * Copyright (c) 2020, 2024 NVI, Inc.
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
/* general header file for all fs data structure definations */

#include "../rclco/rcl/rcl.h"
#include "bbc_ds.h"
#include "cmd_ds.h"
#include "dist_ds.h"
#include "vrepro_ds.h"
#include "venable_ds.h"
#include "vform_ds.h"
#include "dqa_ds.h"
#include "capture_ds.h"
#include "req_ds.h"
#include "res_ds.h"
#include "vst_ds.h"
#include "mcb_ds.h"
#include "tape_ds.h"
#include "systracks_ds.h"
#include "user_info_ds.h"
#include "rclcn_req_ds.h"
#include "rclcn_res_ds.h"
#include "s2st_ds.h"
#include "rec_mode_ds.h"
#include "data_valid_ds.h"
#include "s2label_ds.h"
#include "s2rec_check.h"
#include "form4_ds.h"
#include "rvac_ds.h"
#include "wvolt_ds.h"
#include "lo_ds.h"
#include "pcalform_ds.h"
#include "pcald_ds.h"
#include "pcalports_ds.h"
#include "k4rec_check.h"
#include "k4st_ds.h"
#include "k4vclo_ds.h"
#include "k4vc_ds.h"
#include "k4vcif_ds.h"
#include "k4vcbw_ds.h"
#include "k3fm_ds.h"
#include "k4label_ds.h"
#include "k4rec_mode_ds.h"
#include "k4recpatch_ds.h"
#include "k4pcalports_ds.h"
#include "tacd_shm.h"
#include "ifatt_shm.h"
#include "tpicd_ds.h"
#include "onoff_ds.h"
#include "rxgain_ds.h"
#include "flux_ds.h"
#include "calrx_ds.h"
#include "ds_ds.h"
#include "lba_das_shm.h"
#include "scan_name_ds.h"
#include "user_device_ds.h"
#include "m5state_ds.h"
#include "m5time_ds.h"
#include "disk_serial_ds.h"
#include "disk_pos_ds.h"
#include "data_check_ds.h"
#include "disk_record_ds.h"
#include "rtime_ds.h"
#include "bank_set_ds.h"
#include "vsn_ds.h"
#include "disk2file_ds.h"
#include "in2net_ds.h"
#include "s2bbc_ds.h"
#include "s2das_check.h"
#include "scan_check_ds.h"
#include "mk5b_mode_ds.h"
#include "vsi4_ds.h"
#include "dot_ds.h"
#include "1pps_source_ds.h"
#include "clock_set_ds.h"
#include "holog_ds.h"
#include "satellite_ds.h"
#include "dbbcnn_ds.h"
#include "dbbcifx_ds.h"
#include "dbbcform_ds.h"
#include "dbbc_cont_cal_ds.h"
#include "dbbcgain_ds.h"
#include "mk6_record_ds.h"
#include "mk6_disk_pos_ds.h"
#include "mk6_scan_check_ds.h"
#include "rdbe_dot_ds.h"
#include "rdbe_atten_ds.h"
#include "dbbc3_ifx_ds.h"
#include "dbbc3_bbcnn_ds.h"
#include "dbbc3_cont_cal_ds.h"
#include "dbbc3_iftpx_ds.h"
#include "fila10g_mode_ds.h"
#include "dbbc_vsix_ds.h"
#include "dbbc_pfbx_ds.h"
#include "dbbcvsi_clk_ds.h"
#include "dbbc3_core3h_modex_ds.h"
#include "rdbe_data_send_ds.h"
#include "rdbe_channels_ds.h"
#include "rdbe_pc_offset_ds.h"
#include "rdbe_quantize_ds.h"
#include "rdbe_bstate_ds.h"
#include "rdbe_dot2Xps_ds.h"
#include "rdbe_status_ds.h"
#include "rdbe_version_ds.h"
#include "rdbe_connect_ds.h"
#include "rdbe_personality_ds.h"
#include "rdbe_chan_sel_en_ds.h"
