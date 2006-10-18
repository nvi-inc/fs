#include <ncurses.h>
#include <signal.h>
#include <math.h>
#include <string.h>
#include <sys/types.h>
#include "mparm.h"

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void mout4(int n_das, int mode)
{
   unsigned char chan, xc;

   for (chan=0; chan<2; chan++) {
	/* Detect modules */
	if (!shm_addr->das[n_das].ifp[chan].initialised) {
			standout();
			mvprintw(ROW1+3,COL1+7+(chan*41),"      WAITING for SETUP      ");
			standend();
	} else if (shm_addr->das[n_das].ifp[chan].initialised < 0) {
			standout();
			mvprintw(ROW1+3,COL1+7+(chan*41),"      DEVICE HAS FAILED      ");
			standend();
	} else if (shm_addr->das[n_das].ifp[chan].temp_analog <= 1) {
		if (shm_addr->das[n_das].ifp[chan].temp_digital <= 1)
			mvprintw(ROW1+1,COL1+13+(chan*41),"NO SAMPLER/FILTER");
		else
			mvprintw(ROW1+1,COL1+13+(chan*41),"   NO SAMPLER    ");
	} else if (shm_addr->das[n_das].ifp[chan].temp_digital <= 1)
			mvprintw(ROW1+1,COL1+13+(chan*41),"    NO FILTER    ");
   }

   if (mode==0) {

	for (chan=0; chan<2; chan++) {
		
		if (!shm_addr->das[n_das].ifp[chan].initialised) break;

		/* Digital Filter module */
		if (shm_addr->das[n_das].ifp[chan].temp_digital > 1) {

			/* Filter status */
			if (shm_addr->das[n_das].ifp[chan].processing)
				mvprintw(ROW1+3,COL1+7+(chan*41),"          PROCESSING         ");
			else {
				standout();
				mvprintw(ROW1+3,COL1+7+(chan*41),"          NOT READY          ");
				standend();
				printf("\7");
			}

			/* Show Band Splitter USB and LSB threshold servos */
			if (shm_addr->das[n_das].ifp[chan].bs.usb_servo.mode == _MANUAL) {
				standout();
				mvprintw(ROW1+9,COL1+7+(chan*41),"       MONITORING ONLY       ");
				standend();
			}

			/* Band Splitter USB readout */
			xc = ((255 - shm_addr->das[n_das].ifp[chan].bs.usb_servo.readout)*29)/256;
			if (shm_addr->das[n_das].ifp[chan].bs.usb_servo.mode == _MANUAL) {
				mvprintw(ROW1+10,COL1+21+(chan*41),"M");
				standout();
				if (xc < 14)
					mvprintw(ROW1+10,COL1+7+xc+(chan*41),"-");
				else if (xc > 14)
					mvprintw(ROW1+10,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+10,COL1+7+xc+(chan*41),"=");
				standend();
			} else {
				mvprintw(ROW1+10,COL1+21+(chan*41),"C");
				standout();
				if (xc < 2)
					mvprintw(ROW1+10,COL1+7+xc+(chan*41),"-");
				else if (xc > 26)
					mvprintw(ROW1+10,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+10,COL1+7+xc+(chan*41),"=");
				if (xc < 2 || xc > 26) printf("\7");
				standend();
			}

			/* Band Splitter LSB readout */
			xc = ((255 - shm_addr->das[n_das].ifp[chan].bs.lsb_servo.readout)*29)/256;
			if (shm_addr->das[n_das].ifp[chan].bs.usb_servo.mode == _MANUAL) {
				mvprintw(ROW1+11,COL1+21+(chan*41),"M");
				standout();
				if (xc < 14)
					mvprintw(ROW1+11,COL1+7+xc+(chan*41),"-");
				else if (xc > 14)
					mvprintw(ROW1+11,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+11,COL1+7+xc+(chan*41),"=");
				standend();
			} else {
				mvprintw(ROW1+11,COL1+21+(chan*41),"C");
				standout();
				if (xc < 2)
					mvprintw(ROW1+11,COL1+7+xc+(chan*41),"-");
				else if (xc > 26)
					mvprintw(ROW1+11,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+11,COL1+7+xc+(chan*41),"=");
				if (xc < 2 || xc > 26) printf("\7");
				standend();
			}

			/* Show Fine Tuner USB and LSB threshold servos */
			if (shm_addr->das[n_das].ifp[chan].ft.usb_servo.mode == _MANUAL) {
				standout();
				mvprintw(ROW1+13,COL1+7+(chan*41),"       MONITORING ONLY       ");
				standend();
			}

			/* Fine Tuner USB readout */
			xc = ((255 - shm_addr->das[n_das].ifp[chan].ft.usb_servo.readout)*29)/256;
			if (shm_addr->das[n_das].ifp[chan].ft.usb_servo.mode == _MANUAL) {
				mvprintw(ROW1+14,COL1+21+(chan*41),"M");
				standout();
				if (xc < 14)
					mvprintw(ROW1+14,COL1+7+xc+(chan*41),"-");
				else if (xc > 14)
					mvprintw(ROW1+14,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+14,COL1+7+xc+(chan*41),"=");
				standend();
			} else {
				mvprintw(ROW1+14,COL1+21+(chan*41),"C");
				standout();
				if (xc < 2)
					mvprintw(ROW1+14,COL1+7+xc+(chan*41),"-");
				else if (xc > 26)
					mvprintw(ROW1+14,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+14,COL1+7+xc+(chan*41),"=");
				if (xc < 2 || xc > 26) printf("\7");
				standend();
			}

			/* Fine Tuner LSB readout */
			xc = ((255 - shm_addr->das[n_das].ifp[chan].ft.lsb_servo.readout)*29)/256;
			if (shm_addr->das[n_das].ifp[chan].ft.usb_servo.mode == _MANUAL) {
				mvprintw(ROW1+15,COL1+21+(chan*41),"M");
				standout();
				if (xc < 14)
					mvprintw(ROW1+15,COL1+7+xc+(chan*41),"-");
				else if (xc > 14)
					mvprintw(ROW1+15,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+15,COL1+7+xc+(chan*41),"=");
				standend();
			} else {
				mvprintw(ROW1+15,COL1+21+(chan*41),"C");
				standout();
				if (xc < 2)
					mvprintw(ROW1+15,COL1+7+xc+(chan*41),"-");
				else if (xc > 26)
					mvprintw(ROW1+15,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+15,COL1+7+xc+(chan*41),"=");
				if (xc < 2 || xc > 26) printf("\7");
				standend();
			}

			/* Clock error and Blank monitor */
			if (shm_addr->das[n_das].ifp[chan].clk_err)
				mvprintw(ROW1+19,COL1+7+(chan*41),"ERROR  ");
			else	mvprintw(ROW1+19,COL1+7+(chan*41),"OK     ");
			if (shm_addr->das[n_das].ifp[chan].blank) {
				standout();
				mvprintw(ROW1+19,COL1+27+(chan*41),"ACTIVE ");
				standend();
			} else	mvprintw(ROW1+19,COL1+27+(chan*41),"PASSIVE");
		}
	
		/* High Res Sampler module */
		if (shm_addr->das[n_das].ifp[chan].temp_analog > 1) {

			/* Show level and offset servos */
			if (shm_addr->das[n_das].ifp[chan].bs.level.mode == _MANUAL ||
		    	shm_addr->das[n_das].ifp[chan].bs.offset.mode == _MANUAL) {
				standout();
				mvprintw(ROW1+5,COL1+7+(chan*41),"       MONITORING ONLY       ");
				standend();
			}

			/* Level readout */
			xc = ((255 - shm_addr->das[n_das].ifp[chan].bs.level.readout)*29)/256;
			if (shm_addr->das[n_das].ifp[chan].bs.level.mode == _MANUAL) {
				mvprintw(ROW1+6,COL1+21+(chan*41),"M");
				standout();
				if (xc < 14)
					mvprintw(ROW1+6,COL1+7+xc+(chan*41),"-");
				else if (xc > 14)
					mvprintw(ROW1+6,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+6,COL1+7+xc+(chan*41),"=");
				standend();
			} else {
				mvprintw(ROW1+6,COL1+21+(chan*41),"C");
				standout();
				if (xc < 2)
					mvprintw(ROW1+6,COL1+7+xc+(chan*41),"-");
				else if (xc > 26)
					mvprintw(ROW1+6,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+6,COL1+7+xc+(chan*41),"=");
				if (xc < 2 || xc > 26) {
					printf("\7");
					mvprintw(ROW1+5,COL1+7+(chan*41),"     ADJUST INPUT LEVEL      ");
				}
				standend();
			}

			/* Offset readout */
			xc = (shm_addr->das[n_das].ifp[chan].bs.offset.readout*29)/256;
			if (shm_addr->das[n_das].ifp[chan].bs.offset.mode == _MANUAL) {
				mvprintw(ROW1+7,COL1+21+(chan*41),"M");
				standout();
				if (xc < 14)
					mvprintw(ROW1+7,COL1+7+xc+(chan*41),"-");
				else if (xc > 14)
					mvprintw(ROW1+7,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+7,COL1+7+xc+(chan*41),"=");
				standend();
			} else {
				mvprintw(ROW1+7,COL1+21+(chan*41),"C");
				standout();
				if (xc < 2)
					mvprintw(ROW1+7,COL1+7+xc+(chan*41),"-");
				else if (xc > 26)
					mvprintw(ROW1+7,COL1+7+xc+(chan*41),"+");
				else	mvprintw(ROW1+7,COL1+7+xc+(chan*41),"=");
				if (xc < 2 || xc > 26) {
					printf("\7");
					mvprintw(ROW1+5,COL1+7+(chan*41),"     ADJUST INPUT OFFSET     ");
				}
				standend();
			}

			/* 5 MHz and 1 PPS errors */
			if (shm_addr->das[n_das].ifp[chan].ref_err)
				mvprintw(ROW1+20,COL1+7+(chan*41),"ERROR  ");
			else	mvprintw(ROW1+20,COL1+7+(chan*41),"OK     ");
			if (shm_addr->das[n_das].ifp[chan].sync_err)
				mvprintw(ROW1+20,COL1+27+(chan*41),"ERROR  ");
			else	mvprintw(ROW1+20,COL1+27+(chan*41),"OK     ");
		}

		/* Finally check Voltages and Temps */
		if (fabs((chan?shm_addr->das[n_das].voltage_p5V_ifp2:shm_addr->das[n_das].voltage_p5V_ifp1) - 5.0)/5.0*100 >= DAS_V_TOLER ||
	    	fabs(shm_addr->das[n_das].voltage_m5d2V + 5.2)/5.2*100 >= DAS_V_TOLER ||
	    	fabs(shm_addr->das[n_das].voltage_p9V - 9.0)/9.0*100 >= DAS_V_TOLER ||
	    	fabs(shm_addr->das[n_das].voltage_m9V + 9.0)/9.0*100 >= DAS_V_TOLER ||
	    	fabs(shm_addr->das[n_das].voltage_p15V - 15.0)/15.0*100 >= DAS_V_TOLER ||
	    	fabs(shm_addr->das[n_das].voltage_m15V + 15.0)/15.0*100 >= DAS_V_TOLER)
			mvprintw(ROW1+21,COL1+7+(chan*41),"ERROR  ");
		else	mvprintw(ROW1+21,COL1+7+(chan*41),"OK     ");
		if (shm_addr->das[n_das].ifp[chan].temp_analog > DAS_TEMP_MAX ||
	    	shm_addr->das[n_das].ifp[chan].temp_digital > DAS_TEMP_MAX)
			mvprintw(ROW1+21,COL1+27+(chan*41),"ERROR  ");
		else	mvprintw(ROW1+21,COL1+27+(chan*41),"OK     ");
	}

   } else {

	for (chan=0; chan<2; chan++) {

		if (!shm_addr->das[n_das].ifp[chan].initialised) break;

		/* Digital Filter module */
		if (shm_addr->das[n_das].ifp[chan].temp_digital > 1) {

			/* Band Splitter: USB & LSB thresholds & counters */
			mvprintw(ROW1+7,COL1+6 +(chan*41),"%4d %c",shm_addr->das[n_das].ifp[chan].bs.usb_threshold,shm_addr->das[n_das].ifp[chan].bs.usb_servo.mode?'M':'C');
			mvprintw(ROW1+8,COL1+6 +(chan*41),"%4d",255-shm_addr->das[n_das].ifp[chan].bs.usb_servo.readout);
			mvprintw(ROW1+7,COL1+26+(chan*41),"%4d %c",shm_addr->das[n_das].ifp[chan].bs.lsb_threshold,shm_addr->das[n_das].ifp[chan].bs.lsb_servo.mode?'M':'C');
			mvprintw(ROW1+8,COL1+26+(chan*41),"%4d",255-shm_addr->das[n_das].ifp[chan].bs.lsb_servo.readout);
	
			/* Fine Tuner: USB & LSB thresholds & counters */
			mvprintw(ROW1+10,COL1+6 +(chan*41),"%4d %c",shm_addr->das[n_das].ifp[chan].ft.usb_threshold,shm_addr->das[n_das].ifp[chan].ft.usb_servo.mode?'M':'C');
			mvprintw(ROW1+11,COL1+6 +(chan*41),"%4d",255-shm_addr->das[n_das].ifp[chan].ft.usb_servo.readout);
			mvprintw(ROW1+10,COL1+26+(chan*41),"%4d %c",shm_addr->das[n_das].ifp[chan].ft.lsb_threshold,shm_addr->das[n_das].ifp[chan].ft.lsb_servo.mode?'M':'C');
			mvprintw(ROW1+11,COL1+26+(chan*41),"%4d",255-shm_addr->das[n_das].ifp[chan].ft.lsb_servo.readout);

			/* Clock error */
			if (shm_addr->das[n_das].ifp[chan].clk_err) 
				mvprintw(ROW1+15,COL1+28+(chan*41),"ERROR");
			else	mvprintw(ROW1+15,COL1+28+(chan*41),"OK   ");

			/* Temperature */
			mvprintw(ROW1+19,COL1+28+(chan*41),"%2.0f C [%d]",shm_addr->das[n_das].ifp[chan].temp_digital,DAS_TEMP_MAX);
		}

		/* High Res Sampler module */
		if (shm_addr->das[n_das].ifp[chan].temp_analog > 1) {

			/* IF Input Level & Offset */
			mvprintw(ROW1+5,COL1+6 +(chan*41),"%4d %c",255-shm_addr->das[n_das].ifp[chan].bs.level.readout,shm_addr->das[n_das].ifp[chan].bs.level.mode?'M':'C');
			mvprintw(ROW1+5,COL1+26+(chan*41),"%4d %c",shm_addr->das[n_das].ifp[chan].bs.offset.readout,shm_addr->das[n_das].ifp[chan].bs.offset.mode?'M':'C');
	
			/* 1MHz PLL: Lock Detector & Voltage Control */
			mvprintw(ROW1+13,COL1+10+(chan*41),"%3.1f V",shm_addr->das[n_das].ifp[chan].pll_ld);
			mvprintw(ROW1+13,COL1+30+(chan*41),"%3.1f V",shm_addr->das[n_das].ifp[chan].pll_vc);

			/* 5 MHz & 1 PPS errors */
			if (shm_addr->das[n_das].ifp[chan].ref_err) 
				mvprintw(ROW1+16,COL1+8 +(chan*41),"ERROR");
			else	mvprintw(ROW1+16,COL1+8 +(chan*41),"OK   ");
			if (shm_addr->das[n_das].ifp[chan].sync_err) 
				mvprintw(ROW1+16,COL1+28+(chan*41),"ERROR");
			else	mvprintw(ROW1+16,COL1+28+(chan*41),"OK   ");

			/* Temperature */
			mvprintw(ROW1+19,COL1+9+(chan*41),"%2.0f C [%d]",shm_addr->das[n_das].ifp[chan].temp_analog,DAS_TEMP_MAX);
		}
	}

	if (shm_addr->das[n_das].ifp[0].initialised || shm_addr->das[n_das].ifp[1].initialised) {
		/* Supply Voltages */
		mvprintw(ROW1+21,COL1+13,"[+-%3.1f%%]",DAS_V_TOLER);
		mvprintw(ROW1+21,COL1+31," %+3.1f  ",shm_addr->das[n_das].voltage_p5V_ifp1);
		mvprintw(ROW1+22,COL1+31," %+3.1f  ",shm_addr->das[n_das].voltage_p5V_ifp2);
		mvprintw(ROW1+22,COL1+8 ," %+3.1f   ",shm_addr->das[n_das].voltage_m5d2V);
		mvprintw(ROW1+21,COL1+47," %+3.1f   ",shm_addr->das[n_das].voltage_p9V);
		mvprintw(ROW1+22,COL1+47," %+3.1f   ",shm_addr->das[n_das].voltage_m9V);
		mvprintw(ROW1+21,COL1+67," %+4.1f  ",shm_addr->das[n_das].voltage_p15V);
		mvprintw(ROW1+22,COL1+67," %+4.1f  ",shm_addr->das[n_das].voltage_m15V);
	}

   }

}  /* end mout4 */
