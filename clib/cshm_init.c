/* initialization for "C" shared memory area */

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void cshm_init()
{
  int i,j;

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

  shm_addr->lo.lo[0]=-1.0;
  shm_addr->lo.lo[1]=-1.0;
  shm_addr->lo.lo[2]=-1.0;
  shm_addr->lo.lo[3]=-1.0;

  shm_addr->lo.sideband[0]=0;
  shm_addr->lo.sideband[1]=0;
  shm_addr->lo.sideband[2]=0;
  shm_addr->lo.sideband[3]=0;

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

  shm_addr->IRDYTP[0]=-1;
  shm_addr->IRDYTP[1]=-1;

  shm_addr->ICAPTP[0]=-1;
  shm_addr->ICAPTP[1]=-1;

  shm_addr->knewtape[0]=0;
  shm_addr->knewtape[1]=0;

  shm_addr->scan_name[0]=0;

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
  shm_addr->tpicd.cycle=0;
  for(i=0;i<16*2+4;i++)
     shm_addr->tpicd.itpis[i]=0;

  for(i=0;i<MAX_DET;i++)
    shm_addr->onoff.itpis[i]=0;
  shm_addr->onoff.setup=FALSE;

  for (i=0;i<MAX_RXGAIN;i++)
    shm_addr->rxgain[i].type=0;

  for(i=0;i<MAX_FLUX;i++)
    shm_addr->flux[i].name[0]=0;

  for(i=0;i<2*MAX_DET;i++) {
    shm_addr->tpigain[i]=128;
    shm_addr->tpidiffgain[i]=128;
  }
  return;
}

