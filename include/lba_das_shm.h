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
/* LBA DAS shared memory (C data structure) layout */
enum mode {_AUTO=0, _MANUAL};

struct mux {
	unsigned char setting;
	enum mode mode;
};

struct servo {
	unsigned short setting;
	enum mode mode;
	int readout;	/* Monitor point */
};

struct digout {
	enum dsb {_USB=0, _LSB} setting;
	enum mode mode;
	enum tristate {_TRISTATE=0, _ENABLE} tristate;
};

enum source {
	_BS_USB=0, _BS_LSB, _FT_USB, _FT_LSB,
	_BS_32, _AS_64
};

enum bits {_8_BIT=0, _4_BIT};

struct das {
	char ds_mnem[3];	/* Common dataset mnemonic for a DAS */
	struct ifp {		/* .. which contains up to two IFPs */
		/* IFPnn SNAP command parameters */
		double frequency;	/* LO Frequency [MHz] */
		enum bw {
			_0D0625, _0D125, _0D250, _0D500, _1D000, _2D000,
			_4D000,  _8D000, _16D00, _32D00, _64D00
		     } bandwidth;	/* Filter bandwidth */
		enum filter_mode {
			_NONE, _SCB, _DSB, _ACB, _SC1, _DS2, _DS4, _DS6, _AC1
		     } filter_mode;	/* Filter mode */
		enum flipper {
			_NATURAL=0, _FLIPPED
		     } flip_usb;	/* Flip upper sideband */
		enum flipper flip_lsb;	/* Flip lower sideband */
		enum format {
			_AT_2_BIT=0, _VLBA_2_BIT
		     } format;		/* VLBI output encoding */
		enum stats {
			_4_LVL=0, _3_LVL
		     } magn_stats;	/* Use 3/4 bit statistics */
		/* CORnn SNAP command parameters */
		enum stats corr_type;
		enum corr_source {
			_BSU=0, _BSL, _FTU, _FTL, _C32, _C64, _A_U, _A_L
		     } corr_source[2];
		signed char at_clock_delay;
		/* FTnn SNAP command parameters */
		double ft_lo;
		enum filter_mode ft_filter_mode;
		double ft_offs;
		double ft_phase;
		/* TRACKFORM SNAP command parameters */
		signed char track[2];
		/* Low level IFP implementation */
		signed char initialised;
		/* IF source 0,1,2, or 3 */
		int source;
		enum board { _BS=0, _FT} filter_output;
       	 	struct bs {		/* Band Splitter */
			enum inout {_OUT=0, _IN} image_reject_filter;
			struct servo level;
			struct servo offset;
			enum stats magn_stats;
			enum flipper flip_64MHz_out;
		        enum bits digital_format;
			enum flipper flip_input;
			unsigned char p_hilbert_no;
			unsigned char n_hilbert_no;
			enum band {_OUTER=0, _INNER} sub_band;
			unsigned char q_fir_no;
			unsigned char i_fir_no;
			signed char clock_decimation;
			struct mux add_sub;
			struct mux usb_mux;
			struct mux lsb_mux;
			unsigned char usb_threshold;
			unsigned char lsb_threshold;
			struct servo usb_servo;
			struct servo lsb_servo;
			enum flipper flip_usb;
			enum flipper flip_lsb;
			struct mux monitor;
			struct digout digout;
		       } bs;
		struct ft {		/* Fine Tuner */
			enum sync {_SYNC=0, _1PPS_AUX} sync;
			unsigned int nco_centre_value;
			unsigned int nco_offset_value;
			unsigned int nco_phase_value;
			unsigned int nco_timer_value;
			enum enable {_OFF=0, _ON} nco_test;
			enum enable nco_use_offset;
			enum enable nco_sync_reset;
			enum enable nco_use_timer;
			unsigned char q_fir_no;
			unsigned char i_fir_no;
			signed char clock_decimation;
			struct mux add_sub;
			struct mux usb_mux;
			struct mux lsb_mux;
			unsigned char usb_threshold;
			unsigned char lsb_threshold;
			struct servo usb_servo;
			struct servo lsb_servo;
			enum flipper flip_usb;
			enum flipper flip_lsb;
			struct mux monitor;
			struct digout digout;
		       } ft;
		struct out {		/* Backplane Outputs */
			struct s2_out {
				enum source source;
				enum format format;
			       } s2_lo;
			struct s2_out s2_hi;
			enum source atmb_corr_source;
			enum source mb_corr_2_source;
			unsigned char at_clock_delay;
		       } out;
		/* Additional IFP Monitor points */
		float temp_analog;	/* Temp (analog module) */
		float pll_ld;		/* 1 MHz PLL Lock Detector */
		float pll_vc;		/* 1 MHz PLL Voltage Control */
		unsigned char ref_err;	/* 5 MHz input failure ? */
		unsigned char sync_err;	/* 1 PPS input failure ? */
		float temp_digital;	/* Temp (digital module) */
		unsigned char processing;	/* Filter proc. state */
		unsigned char clk_err;	/* Filter clock error ? */
		unsigned char blank;	/* Blanking input active ? */
	       } ifp[2];
	/* Additional DAS Monitor points */
	float voltage_p5V_ifp1;	/* IFP1 +5V supply voltage */
	float voltage_p5V_ifp2;	/* IFP2 +5V supply voltage */
	float voltage_m5d2V;	/* Common -5.2V supply voltage */
	float voltage_p9V;	/* Common +9V supply voltage */
	float voltage_m9V;	/* Common -9V supply voltage */
	float voltage_p15V;	/* Common +15V supply voltage */
	float voltage_m15V;	/* Common -15V supply voltage */
};
