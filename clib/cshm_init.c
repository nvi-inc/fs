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

  shm_addr->bit_density = -1;

  shm_addr->systracks.track[0]=0;
  shm_addr->systracks.track[1]=1;
  shm_addr->systracks.track[2]=34;
  shm_addr->systracks.track[3]=35;

  shm_addr->user_info.labels[0][0]=0;
  shm_addr->user_info.labels[1][0]=0;
  shm_addr->user_info.labels[2][0]=0;
  shm_addr->user_info.labels[3][0]=0;

  shm_addr->user_info.field1[0]=0;
  shm_addr->user_info.field2[0]=0;
  shm_addr->user_info.field3[0]=0;
  shm_addr->user_info.field4[0]=0;

  shm_addr->data_valid.user_dv=0;
  shm_addr->data_valid.user_dv=0;

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

  for(i=0; i<64; i++)
    shm_addr->form4.codes[i]=-1;

  shm_addr->thin=-1;
  shm_addr->vacsw=0;

  shm_addr->vac4=-1;

  shm_addr->rvac.inches=0;
  shm_addr->rvac.set=0;

  shm_addr->wvolt.volts[0]=0;
  shm_addr->wvolt.set[0]=0;
  shm_addr->wvolt.volts[1]=0;
  shm_addr->wvolt.set[1]=0;

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

  return;
}

