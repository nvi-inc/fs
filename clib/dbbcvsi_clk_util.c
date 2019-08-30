/* dbbcvsi_clk buffer parsing utilities */

#include <string.h>
#include "../include/params.h"
#include "../include/fs_types.h"

int dbbc_2_vsi_clk(lclm,buff)
struct dbbcvsi_clk_mon *lclm;
char *buff;
{
  char *ptr, ch;
  int i, ierr;

  ptr=strtok(buff,"/");
  if(ptr==NULL)
    return -1;

  ptr=strtok(NULL,",");

  if(m5sscanf(ptr,"%d",&lclm->vsi_clk.vsi_clk,&lclm->vsi_clk.state))
    return -1;
    
  return 0;
}
