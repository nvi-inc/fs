/* chekr bbc mcbcn return decode */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void bbc_brk(imod,ip,icherr,ierr)
int imod;
int ip[5];
int icherr[10];
int *ierr;
{
  struct bbc_cmd lclc;
  struct bbc_mon lclm;
  struct bbc_cmd lcomm;
  int ind;
  struct res_buf buffer;
  struct res_rec response;
  void opn_res();
  void get_res();
  void mc00bbc(), mc01bbc(), mc02bbc(), mc03bbc();
  void mc05bbc();

  ind=imod-1;

  opn_res(&buffer,ip);
  get_res(&response, &buffer); mc00bbc(&lclc, response.data);
  get_res(&response, &buffer); mc01bbc(&lclc, response.data);
  get_res(&response, &buffer); mc02bbc(&lclc, response.data);
  get_res(&response, &buffer); mc03bbc(&lclc, response.data);
  get_res(&response, &buffer); mc04bbc(&lclm, response.data);
/*  get_res(&response, &buffer); mc05bbc(&lclc, response.data);
  not implemented yet
*/
  get_res(&response, &buffer); mc06bbc(&lclm, response.data);
  get_res(&response, &buffer); mc07bbc(&lclm, response.data);
  if(response.state == -1) {
    shm_addr->bbc_tpi[ind][0]=65536;
    shm_addr->bbc_tpi[ind][1]=65536;
     clr_res(&buffer);
     *ierr=-200;
     return;
  }
  clr_res(&buffer);

  memcpy(&lcomm,&shm_addr->bbc[ind],sizeof(lcomm));
  if (lcomm.freq != lclc.freq) icherr[0]=1;
  if (lcomm.source != lclc.source) icherr[1]=1;
  if (lcomm.bw[0] != lclc.bw[0]) icherr[2]=1;
  if (lcomm.bw[1] != lclc.bw[1]) icherr[3]=1;
  if (lcomm.bwcomp[0] != lclc.bwcomp[0]) icherr[4]=1;
  if (lcomm.bwcomp[1] != lclc.bwcomp[1]) icherr[5]=1;
  if (lcomm.gain.mode != lclc.gain.mode) icherr[6]=1;
/*  if (lcomm.gain.value[0] != lclc.gain.value[0]) icherr[7]=1; */
/*  if (lcomm.gain.value[1] != lclc.gain.value[1]) icherr[8]=1; */
/* not implemented yet */
  if (lcomm.avper != lclc.avper) icherr[9]=1;
  if (lclm.lock==0) icherr[10]=1;
  shm_addr->bbc_tpi[ind][0]=lclm.pwr[0];
  shm_addr->bbc_tpi[ind][1]=lclm.pwr[1];
  return;
}
