/* chekr ifd mcbcn return decoder */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

void dist_brk(imod,ip,icherr,ierr)
int *imod;
long ip[5];
int icherr[5];
int *ierr;
{
  struct dist_cmd lclc;
  struct dist_cmd lcomm;
  int ind, ich, count;
  struct res_buf buffer;
  struct res_rec response;
  void opn_res();
  void get_res();
  void mc01dist(), mc02dist();

  ind=*imod-1;

  opn_res(&buffer,ip);
  get_res(&response, &buffer); mc01dist(&lclc, response.data);
  get_res(&response, &buffer); mc02dist(&lclc, response.data);
  if (response.state == -1) {
     clr_res(&buffer);
     *ierr=-201;
     return;
  }

  clr_res(&buffer);

  memcpy(&lcomm,&shm_addr->dist[ind],sizeof(lcomm));

  if (lcomm.atten[0] != lclc.atten[0]) icherr[0]=1;
  if (lcomm.atten[1] != lclc.atten[1]) icherr[1]=1;
  if (lcomm.input[0] != lclc.input[0]) icherr[2]=1;
  if (lcomm.input[1] != lclc.input[1]) icherr[3]=1;
  if (lcomm.avper != lclc.avper) icherr[4]=1;

  return;
}
