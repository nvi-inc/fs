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
/* TAC shared memory (C data structure) layout */

struct tacd_shm {
  /* TIME */
  int day,                 /* The date for time */
    day_frac;            /* The fraction of day for time  */
  float msec_counter,      /* Raw reading on the counter in microsec. */
    usec_correction,       /* On the ONCORE receiver's +/- 52 sec sawtooth*/ 
    usec_bias,             /* Amount by which the GPS receiver's 1PPS output
                            * has been intentionally biased in usec. */
    cooked_correction,     /* The correct (cooked) counter reading after
                            * applying the usec_correction and usec_bias. */
    pc_v_utc, 
    utc_correction_nsec;
  int utc_correction_sec; 

  /* AVERAGE */
  int day_a,               /* The date for average. */
    day_frac_a;          /* The fraction of day for average. */
  float rms,               /* RMS scatter of the sec data points about the 
                            * average in usec. */
    usec_average,          /* sec point average of the sec cooked counter
                            * readings in usec. */
    max,                   /* The extreme readings of the sec points.*/
    min;                   /* (by definition) max > average > min. */ 

  int day_frac_old,        /* old day */
    day_frac_old_a;        /* old day average. */

  /* */
  int continuous,          /* 0 = not so often, 1 = continuous */
    nsec_accuracy,         /* An estimate of the accuracy of the GPS tick in 
                            * nsec. */
    sec_average,           /* Number of secs. of data going into the averg. */
    stop_request,          /* -1=file empty,0=ok,1=reopen file,2=fs exit*/
    port,                  /* The port number assiged by the Sys. Admin. on
                            * the PC side. */
    check,                 /* read TAC every n secs into SharedMemory */
    display;               /* what do you want displayed when you do a tacd.
			    * tacd=status(0), tacd=time(1), tacd=average(2)*/
  /* */
  char hostpc[80],         /* The Host name. */
    oldnew[8],             /* show old or new. -1 is old, 1 is new. */
    oldnew_a[11],          /* show old or new. -1 is old, 1 is new. */
    file[40],              /* Log file in the PC doing the work. */
    status[8],             /* The file status on the PC log file. */
    tac_ver[20];           /* TAC PC software version.. */
};



