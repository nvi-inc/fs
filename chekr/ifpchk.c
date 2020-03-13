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
/* ifp chekr routine */

#include <stdio.h> 
#include <string.h> 
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"         /* shared memory definition */
#include "../include/shm_addr.h"      /* shared memory pointer */

void ifpchk_(imod,icherr,ierr)
int *imod;
int icherr[];
int *ierr;
{
  int ind;
   ind=*imod-1;

  if (!shm_addr->das[ind/2].ifp[ind%2].initialised) {
    shm_addr->ifp_tpi[ind]=65535;
    return;
  }

  if (lba_ifp_read(ind,TRUE)) {
    shm_addr->ifp_tpi[ind]=65535;
    *ierr=-700;
    return;
  }

  /* check analog sampler module presence only where required */
  if (shm_addr->das[ind/2].ifp[ind%2].bs.digital_format == _8_BIT)
	icherr[0] = (shm_addr->das[ind/2].ifp[ind%2].temp_analog <= 1);
  /* check digital filter module is present */
  icherr[1] = (shm_addr->das[ind/2].ifp[ind%2].temp_digital <= 1);

  /* check digital module */
  if (shm_addr->das[ind/2].ifp[ind%2].temp_digital >  1)
  {
	/* check IFP is actually running */
	icherr[2] = (!shm_addr->das[ind/2].ifp[ind%2].processing);
	/* check Band Splitter USB and LSB servos are functioning correctly */
	if (shm_addr->das[ind/2].ifp[ind%2].bs.usb_servo.mode != _MANUAL) {
		icherr[6] =
		    (shm_addr->das[ind/2].ifp[ind%2].bs.usb_servo.readout<17) ||
		    (shm_addr->das[ind/2].ifp[ind%2].bs.usb_servo.readout>237);
	}
	if (shm_addr->das[ind/2].ifp[ind%2].bs.lsb_servo.mode != _MANUAL) {
		icherr[7] =
		    (shm_addr->das[ind/2].ifp[ind%2].bs.lsb_servo.readout<17) ||
		    (shm_addr->das[ind/2].ifp[ind%2].bs.lsb_servo.readout>237);
	}
	/* check Fine Tuner USB and LSB servos are functioning correctly */
	if (shm_addr->das[ind/2].ifp[ind%2].ft.usb_servo.mode != _MANUAL) {
		icherr[8] =
		    (shm_addr->das[ind/2].ifp[ind%2].ft.usb_servo.readout<17) ||
		    (shm_addr->das[ind/2].ifp[ind%2].ft.usb_servo.readout>237);
	}
	if (shm_addr->das[ind/2].ifp[ind%2].ft.lsb_servo.mode != _MANUAL) {
		icherr[9] =
		    (shm_addr->das[ind/2].ifp[ind%2].ft.lsb_servo.readout<17) ||
		    (shm_addr->das[ind/2].ifp[ind%2].ft.lsb_servo.readout>237);
	}
	/* check internal IFP error detectors */
	icherr[10] = shm_addr->das[ind/2].ifp[ind%2].clk_err;
  }

  /* check analog module */
  if (shm_addr->das[ind/2].ifp[ind%2].temp_analog > 1) {
	/* check input level and offset servos are functioning correctly */
	if (shm_addr->das[ind/2].ifp[ind%2].bs.level.mode != _MANUAL) {
		icherr[3] =
		    (shm_addr->das[ind/2].ifp[ind%2].bs.level.readout<17);
		icherr[4] =
		    (shm_addr->das[ind/2].ifp[ind%2].bs.level.readout>237);
	}
	if (shm_addr->das[ind/2].ifp[ind%2].bs.offset.mode != _MANUAL) {
		icherr[5] =
		    (shm_addr->das[ind/2].ifp[ind%2].bs.offset.readout<17) ||
		    (shm_addr->das[ind/2].ifp[ind%2].bs.offset.readout>237);
	}
	/* check internal 1PPS / 5MHz error detectors */
	icherr[11] = shm_addr->das[ind/2].ifp[ind%2].ref_err;
	icherr[12] = shm_addr->das[ind/2].ifp[ind%2].sync_err;
	/* and save input level as current TPI */
	shm_addr->ifp_tpi[ind] =
	  (255-(shm_addr->das[ind/2].ifp[ind%2].bs.level.readout&0x00FF))*256;
  } else {
	/* Analog Sampler not in use - ie. no level detection possible */
	shm_addr->ifp_tpi[ind] = 0;
  }

  /* check module temperatures */
  icherr[13] = (shm_addr->das[ind/2].ifp[ind%2].temp_analog>DAS_TEMP_MAX);
  icherr[14] = (shm_addr->das[ind/2].ifp[ind%2].temp_digital>DAS_TEMP_MAX);

  return;
}
