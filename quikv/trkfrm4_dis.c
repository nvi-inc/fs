/* mark IV trkfrm function display */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"
#include "../include/shm_addr.h"

#define MAX_OUT 256

void trkfrm4_dis(command,lclc,ip)
struct cmd_ds *command;
struct form4_cmd *lclc;
long ip[5];
{
      int i, count, start_len;
      char output[MAX_OUT];

      for (i=0;i<5;i++)
	ip[i]=0;

   /* format output buffer */

      strcpy(output,command->name);
      strcat(output,"/");
      start_len=strlen(output);

      count=0;
      while( count>= 0) {
        if (start_len != strlen(output))
	  strcat(output,",");
        count++;
        trkfrm4_enc(output,&count,lclc);
        if(count < 0  && output[strlen(output)-1] == ',')
          output[strlen(output)-1]='\0';
	if( (count > 0 && strlen(output) > 62 )||
            (count < 0 && strlen(output) > start_len) ) {
	  cls_snd(&ip[0],output,strlen(output),0,0);
	  ip[1]++;
	  output[start_len]='\0';
	}
      }

      return;

}
