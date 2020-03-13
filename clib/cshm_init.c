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
/* initialization for "C" shared memory area */

#include <string.h>
#include <stdio.h>
#include <math.h>

#include "../include/dpi.h"
#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void cshm_init()
{
  int i,j,k;

  for (i=0; i< 32; i++)
    shm_addr->vform.codes[i]=-1;

  shm_addr->vform.mode = -1;
  shm_addr->vform.tape_clock = -1;
  shm_addr->vform.enable.high = 0;  
  shm_addr->vform.enable.low  = 0;
  shm_addr->vform.enable.system = 0;
  shm_addr->vform.last = 1;
  shm_addr->vform.qa.drive=-1;

  shm_addr->bit_density[0] = -1;
  shm_addr->bit_density[1] = -1;

  shm_addr->systracks[0].track[0]=0;
  shm_addr->systracks[0].track[1]=1;
  shm_addr->systracks[0].track[2]=34;
  shm_addr->systracks[0].track[3]=35;
  shm_addr->systracks[1].track[0]=0;
  shm_addr->systracks[1].track[1]=1;
  shm_addr->systracks[1].track[2]=34;
  shm_addr->systracks[1].track[3]=35;

  shm_addr->vrepro[0].equalizer[0]=-1;
  shm_addr->vrepro[1].equalizer[0]=-1;

  shm_addr->user_info.labels[0][0]=0;
  shm_addr->user_info.labels[1][0]=0;
  shm_addr->user_info.labels[2][0]=0;
  shm_addr->user_info.labels[3][0]=0;

  shm_addr->user_info.field1[0]=0;
  shm_addr->user_info.field2[0]=0;
  shm_addr->user_info.field3[0]=0;
  shm_addr->user_info.field4[0]=0;

  shm_addr->data_valid[0].user_dv=0;
  shm_addr->data_valid[1].user_dv=0;

  shm_addr->s2st.dir=0;
  shm_addr->s2st.speed=-1;
  shm_addr->s2st.record=0;
  shm_addr->rec_mode.mode[0]=0;
  shm_addr->rec_mode.group=-1;

  shm_addr->check.s2rec.user_info.label[0]=0;
  shm_addr->check.s2rec.user_info.label[1]=0;
  shm_addr->check.s2rec.user_info.label[2]=0;
  shm_addr->check.s2rec.user_info.label[3]=0;

  shm_addr->check.s2rec.user_info.field[0]=0;
  shm_addr->check.s2rec.user_info.field[1]=0;
  shm_addr->check.s2rec.user_info.field[2]=0;
  shm_addr->check.s2rec.user_info.field[3]=0;

  shm_addr->check.s2rec.check=0;
  shm_addr->check.s2rec.speed=0;
  shm_addr->check.s2rec.state=0;
  shm_addr->check.s2rec.group=0;
  shm_addr->check.s2rec.mode=0;
  shm_addr->check.s2rec.roll=0;
  shm_addr->check.s2rec.dv=0;
  shm_addr->check.s2rec.tapeid=0;
  shm_addr->check.s2rec.tapetype=0;

  shm_addr->actual.s2rec[0].rstate_valid=FALSE;
  shm_addr->actual.s2rec[0].position_valid=FALSE;
  shm_addr->actual.s2rec_inuse=0;

  shm_addr->form4.enable[0]=0;
  shm_addr->form4.enable[1]=0;
  shm_addr->form4.barrel=0;

  for(i=0; i<64; i++)
    shm_addr->form4.codes[i]=-1;

  for(j=0;j<16;j++)
    for(i=0; i<64; i++) {
      shm_addr->form4.roll[j][i]=-2;
      shm_addr->form4.a2d[j][i]=-2;
    }
  
  shm_addr->thin[0]=-1;
  shm_addr->thin[1]=-1;

  shm_addr->vacsw[0]=0;
  shm_addr->vacsw[1]=0;

  shm_addr->vac4[0]=-1;
  shm_addr->vac4[1]=-1;

  shm_addr->rvac[0].inches=0;
  shm_addr->rvac[0].set=0;
  shm_addr->rvac[1].inches=0;
  shm_addr->rvac[1].set=0;

  shm_addr->wvolt[0].volts[0]=0;
  shm_addr->wvolt[0].set[0]=0;
  shm_addr->wvolt[0].volts[1]=0;
  shm_addr->wvolt[0].set[1]=0;

  shm_addr->wvolt[1].volts[0]=0;
  shm_addr->wvolt[1].set[0]=0;
  shm_addr->wvolt[1].volts[1]=0;
  shm_addr->wvolt[1].set[1]=0;

  for (i=0;i<MAX_LO;i++) {
    shm_addr->lo.lo[i]=-1.0;
    shm_addr->lo.sideband[i]=0;
  }

  for (i=0;i<2;i++)
    for (j=0;j<16;j++) {
      shm_addr->pcalform.count[i][j]=0;
      shm_addr->pcald.count[i][j]=0;
    }

  shm_addr->pcald.continuous=0;
  shm_addr->pcald.bits=0;
  shm_addr->pcald.integration=0;

  for (i=0;i<MAX_BBC;i++)
    shm_addr->bbc[i].source=-1;

  shm_addr->imixif3=-1;

  shm_addr->k4tape_sqn[0]=0;

  for(i=0;i<16;i++) {
    shm_addr->k4vclo.freq[i]=0;
    shm_addr->k4vc.lohi[i]=0;
    shm_addr->k4vc.att[i]=0;
    shm_addr->k4vc.loup[i]=0;
  }

  strncpy(shm_addr->k3fm.aux,"000000000000",12);

  for(i=0;i<(sizeof(shm_addr->k4recpatch.ports)/sizeof(int));i++)
     shm_addr->k4recpatch.ports[i]=0;

  shm_addr->k4pcalports.ports[0]=0;
  shm_addr->k4pcalports.ports[1]=0;

  shm_addr->k4rec_mode.im=-1;
  shm_addr->k4rec_mode.nm=-1;
  shm_addr->k4rec_mode_stat=-1;

  shm_addr->check.vkenable[0]=0;
  shm_addr->check.vkenable[1]=0;

  shm_addr->check.vklowtape[0]=0;
  shm_addr->check.vklowtape[1]=0;

  shm_addr->check.vkmove[0]=0;
  shm_addr->check.vkmove[1]=0;

  shm_addr->check.vkload[0]=0;
  shm_addr->check.vkload[1]=0;

  shm_addr->check.systracks[0]=0;
  shm_addr->check.systracks[1]=0;
  
  shm_addr->check.dbbc_form=0;

  shm_addr->IRDYTP[0]=-1;
  shm_addr->IRDYTP[1]=-1;

  shm_addr->ICAPTP[0]=-1;
  shm_addr->ICAPTP[1]=-1;

  shm_addr->knewtape[0]=0;
  shm_addr->knewtape[1]=0;

  shm_addr->scan_name.name_old[0]=0;
  shm_addr->scan_name.name[0]=0;
  shm_addr->scan_name.session[0]=0;
  shm_addr->scan_name.station[0]=0;
  shm_addr->scan_name.duration=-1;
  shm_addr->scan_name.continuous=-1;
  

  /* 
   * Initialize TAC Shared Memory variables to 0(zero).
   */
  shm_addr->tacd.continuous=0;
  shm_addr->tacd.oldnew[0]='\0';   /* start off as new */
  shm_addr->tacd.file[0]='\0';
  shm_addr->tacd.status[0]='\0';
  shm_addr->tacd.day_frac=0.0;
  shm_addr->tacd.msec_counter=0.0;
  shm_addr->tacd.usec_correction=0;
  shm_addr->tacd.nsec_accuracy=0;
  shm_addr->tacd.usec_bias=0.0;
  shm_addr->tacd.cooked_correction=0.0;
  shm_addr->tacd.sec_average=0;
  shm_addr->tacd.rms=0.0;
  shm_addr->tacd.usec_average=0.0;
  shm_addr->tacd.max=0.0;
  shm_addr->tacd.min=0.0;
  shm_addr->tacd.hostpc[0]='\0';
  shm_addr->tacd.port=0;
  shm_addr->tacd.check=30*100;  /* default is 30 secs. */
  shm_addr->tacd.display=2;     /* default is TAC average. */
  shm_addr->tacd.stop_request=0;

  for (i=0;i<15;i++)
    shm_addr->TPIVC[i]=65536;

  for (i=0;i<MAX_BBC;i++) {
    shm_addr->bbc_tpi[i][0]=65536;
    shm_addr->bbc_tpi[i][1]=65536;
  }
  for (i=0;i<3;i++) {
     shm_addr->vifd_tpi[i]=65536;
     shm_addr->mifd_tpi[i]=65536;
  }

  shm_addr->vifd_tpi[3]=65536;

  shm_addr->tpicd.continuous=0;
  shm_addr->tpicd.stop_request=1;
  shm_addr->tpicd.tsys_request=0;
  shm_addr->tpicd.cycle=0;
  for(i=0;i<MAX_GLOBAL_DET;i++)
     shm_addr->tpicd.itpis[i]=0;

  for(i=0;i<MAX_ONOFF_DET;i++)
    shm_addr->onoff.itpis[i]=0;
    
  shm_addr->onoff.setup=FALSE;
  shm_addr->onoff.rep=2;
  shm_addr->onoff.intp=1;
  shm_addr->onoff.cutoff=75.;
  shm_addr->onoff.step=3;
  shm_addr->onoff.wait=120;
  
  shm_addr->onoff.proc[0]=0;

  for (i=0;i<MAX_RXGAIN;i++)
    shm_addr->rxgain[i].type=0;

  for(i=0;i<MAX_FLUX;i++)
    shm_addr->flux[i].name[0]=0;

  for(i=0;i<MAX_DET;i++) {
    shm_addr->tpigain[i]=128;
    shm_addr->tpidiffgain[i]=128;
  }
  
  for (i=0; i<MAX_DAS; i++) {

	sprintf (shm_addr->das[i].ds_mnem,"d%1x",i+1);

	for (j=0; j<2; j++) {
		/* Initialise CORnn default values */
		shm_addr->das[i].ifp[j].corr_type = _4_LVL;
		shm_addr->das[i].ifp[j].corr_source[0] = _A_U;
		shm_addr->das[i].ifp[j].corr_source[1] = _A_U;
		shm_addr->das[i].ifp[j].at_clock_delay = 0;

		/* Initialise FTnn default values */
		shm_addr->das[i].ifp[j].bs.digout.setting = _USB;
		shm_addr->das[i].ifp[j].ft_lo = 8.0;
		shm_addr->das[i].ifp[j].ft.clock_decimation = 0;
		shm_addr->das[i].ifp[j].ft_filter_mode = _NONE;
		shm_addr->das[i].ifp[j].ft_offs = 0.0;
		shm_addr->das[i].ifp[j].ft_phase = 0.0;
		shm_addr->das[i].ifp[j].ft.nco_test = _OFF;

		/* Initialise MONnn default values */
		shm_addr->das[i].ifp[j].bs.monitor.setting = _LSB;
		shm_addr->das[i].ifp[j].ft.monitor.setting = _USB;
		shm_addr->das[i].ifp[j].ft.digout.setting = _USB;

		/* Initialise TRACKFORM default values */
		shm_addr->das[i].ifp[j].track[0] =
			 shm_addr->das[i].ifp[j].track[1] = -1;

		/* Hardwire caltmpN to ifpN dependance for 4 IFs */
		shm_addr->das[i].ifp[j].source = (2*i+j)%4;

		shm_addr->das[i].ifp[j].initialised = 0;
	}
  }

  for (i=0;i<2*MAX_DAS;i++) {
    shm_addr->ifp_tpi[i]=65536;
  }

  /* Monit4 starts on DAS 0 */
  shm_addr->m_das=0;

  shm_addr->mk5vsn[0]=0;
  shm_addr->mk5vsn_logchg=0;
  shm_addr->logchg=0;

  for (i=0;i<MAX_USER_DEV;i++) {
    shm_addr->user_device.lo[i]=-1.0;
    shm_addr->user_device.sideband[i]=0;
    shm_addr->user_device.zero[0]=1;
  }

  shm_addr->disk_record.record.record=-1;
  m5state_init(&shm_addr->disk_record.record.state);

  shm_addr->disk_record.label.label[0]=0;
  m5state_init(&shm_addr->disk_record.label.state);

  shm_addr->monit5.pong=0;
  for (i=0;i<2;i++) {
    shm_addr->monit5.ping[i].active=-1;
    for (j=0;j<2;j++) {
      shm_addr->monit5.ping[i].bank[j].vsn[0]=0;
      shm_addr->monit5.ping[i].bank[j].seconds=-1.0;
      shm_addr->monit5.ping[i].bank[j].gb=-1.0;
      shm_addr->monit5.ping[i].bank[j].percent=-1.0;
      for (k=0;k<6;k++)
	shm_addr->monit5.ping[i].bank[j].itime[k]=-1;
    }
  }
  shm_addr->disk2file.scan_label.scan_label[0]=0;
  m5state_init(&shm_addr->disk2file.scan_label.state);

  shm_addr->disk2file.destination.destination[0]=0;
  m5state_init(&shm_addr->disk2file.destination.state);

  shm_addr->disk2file.start.start[0]=0;
  m5state_init(&shm_addr->disk2file.start.state);

  shm_addr->disk2file.end.end[0]=0;
  m5state_init(&shm_addr->disk2file.end.state);

  shm_addr->disk2file.options.options[0]=0;
  m5state_init(&shm_addr->disk2file.options.state);

  shm_addr->in2net.control.control=-1;
  m5state_init(&shm_addr->in2net.control.state);

  shm_addr->in2net.destination.destination[0]=0;
  m5state_init(&shm_addr->in2net.destination.state);

  shm_addr->in2net.last_destination[0]=0;

  shm_addr->abend.normal_end=0;
  shm_addr->abend.other_error=0;
 
  shm_addr->ntp_synch_unknown=0;

  shm_addr->vsi4.config.value=-1;
  shm_addr->vsi4.config.set=0;
  shm_addr->vsi4.pcalx.value=-1;
  shm_addr->vsi4.pcalx.set=0;
  shm_addr->vsi4.pcaly.value=-1;
  shm_addr->vsi4.pcaly.set=0;

  m5state_init(&shm_addr->mk5b_mode.source.state);
  m5state_init(&shm_addr->mk5b_mode.mask.state);
  m5state_init(&shm_addr->mk5b_mode.decimate.state);
  m5state_init(&shm_addr->mk5b_mode.samplerate.state);
  m5state_init(&shm_addr->mk5b_mode.fpdp.state);

  shm_addr->holog.az=0.0;
  shm_addr->holog.el=0.0;
  shm_addr->holog.azp=0;
  shm_addr->holog.elp=0;
  shm_addr->holog.ical=0;
  shm_addr->holog.proc[0]=0;
  shm_addr->holog.stop_request=0;
  shm_addr->holog.setup=0;
  shm_addr->holog.wait=0;

  shm_addr->satellite.name[0]=0;
  shm_addr->satellite.tlefile[0]=0;
  shm_addr->satellite.mode=0;
  shm_addr->satellite.wrap=0;
  shm_addr->satellite.satellite=0;
  shm_addr->satellite.tle0[0]=0;
  shm_addr->satellite.tle1[0]=0;
  shm_addr->satellite.tle2[0]=0;
 
  shm_addr->satoff.seconds=0.0;
  shm_addr->satoff.cross=0.0;
  shm_addr->satoff.hold=0;

  shm_addr->tle.tle0[0]=0;
  shm_addr->tle.tle1[0]=0;
  shm_addr->tle.tle2[0]=0;
  shm_addr->tle.catnum[0]=0;
  shm_addr->tle.catnum[1]=0;
  shm_addr->tle.catnum[2]=0;

  for (i=0;i<MAX_DBBCNN;i++) {
    shm_addr->dbbcnn[i].freq=0;
    shm_addr->dbbcnn[i].source=-1;
    shm_addr->dbbcnn[i].bw=-1;
    shm_addr->dbbcnn[i].avper=0;
  }
  for (i=0;i<MAX_DBBCIFX;i++) {
    shm_addr->dbbcifx[i].input=-1;
    shm_addr->dbbcifx[i].att=-1;
    shm_addr->dbbcifx[i].agc=-1;
    shm_addr->dbbcifx[i].filter=-1;
    shm_addr->dbbcifx[i].target_null=1;
    shm_addr->dbbcifx[i].target=0;
  }
  shm_addr->dbbcform.mode=-1;
  shm_addr->dbbcform.test=-1;

  shm_addr->dbbc_cont_cal.mode=0;
  shm_addr->dbbc_cont_cal.polarity=-1;
  shm_addr->dbbc_cont_cal.samples=10;
  shm_addr->dbbc_cont_cal.freq=-1;
  shm_addr->dbbc_cont_cal.option=-1;

  shm_addr->m5b_crate=32;

  m5state_init(&shm_addr->fila10g_mode.mask2.state);
  m5state_init(&shm_addr->fila10g_mode.mask1.state);
  m5state_init(&shm_addr->fila10g_mode.decimate.state);

  for(i=0;i<16;i++) {
    shm_addr->dbbc_vsix[0].core[i]=0;
    shm_addr->dbbc_vsix[1].core[i]=0;
  }

  for(i=0;i<MAX_MK6;i++) {
    shm_addr->mk6_units[i]=0;
    shm_addr->mk6_active[i]=0;
  }

  for (i=0;i<MAX_MK6+1;i++) {
    shm_addr->mk6_record[i].action.action[0]=0;
    m5state_init(&shm_addr->mk6_record[i].action.state);
    
    shm_addr->mk6_record[i].duration.duration=0;
    m5state_init(&shm_addr->mk6_record[i].duration.state);
  }

  for(i=0;i<MAX_RDBE;i++) {
    shm_addr->rdbe_units[i]=0;
    shm_addr->rdbe_active[i]=0;
  }

  for(i=0;i<MAX_RDBE;i++) {
    m5state_init(&shm_addr->rdbe_atten[i].ifc.state);
    m5state_init(&shm_addr->rdbe_atten[i].atten.state);
    m5state_init(&shm_addr->rdbe_atten[i].target.state);
  }

  for (i=0;i<MAX_RDBE;i++) 
    shm_addr->rdbe_tsys_data[i].iping=-1;

  for(i=0;i<MAX_RDBE;i++) {
    for (j=0;j<2;j++) {
      shm_addr->rdtcn[i].control[j].continuous=0;
      shm_addr->rdtcn[i].control[j].cycle=0;
      shm_addr->rdtcn[i].control[j].stop_request=1;
      shm_addr->rdtcn[i].control[j].data_valid.user_dv=0;
    }
    shm_addr->rdtcn[i].iping=0;
  }
  shm_addr->dbbc_defined=0;
  shm_addr->dbbc2_defined=0;

  for(i=0;i<MAX_RDBE;i++)
    shm_addr->rdbe_sync[i]=0;

  for (i=0;i<MAX_DBBC3_IF;i++) {
    shm_addr->dbbc3_ifx[i].input=1;
    shm_addr->dbbc3_ifx[i].att=-1;
    shm_addr->dbbc3_ifx[i].agc=1;
    shm_addr->dbbc3_ifx[i].target_null=1;
    shm_addr->dbbc3_ifx[i].target=0;
  }

  for (i=0;i<MAX_DBBC3_BBC;i++) {
    shm_addr->dbbc3_bbcnn[i].freq=0;
    shm_addr->dbbc3_bbcnn[i].source=-1;
    shm_addr->dbbc3_bbcnn[i].bw=-1;
    shm_addr->dbbc3_bbcnn[i].avper=0;
  }

  shm_addr->dbbc3_cont_cal.mode=0;
  shm_addr->dbbc3_cont_cal.polarity=-1;
  shm_addr->dbbc3_cont_cal.freq=-1;
  shm_addr->dbbc3_cont_cal.option=-1;
  shm_addr->dbbc3_cont_cal.samples=10;


  return;
}

