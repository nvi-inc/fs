/* logitf

   logitf formats a FS monitor command response and sends the
   buffer to ddout.
*/

#include <string.h>
#include <stdio.h>
#include "../include/fs_types.h"
#include "../include/shm_addr.h"      /* shared memory pointer */
#include "../include/params.h"
#include "../include/fscom.h"

void cls_snd();
void pname();
void rte_time();

logitf(msg)
char *msg;           /* a message to be logged, NULL if none */
{
  char buf[513];    /* Holds the complete log entry */
  char name[5];     /* The name of our main program */
  int it[6],ip1,ip2,l;
 
/* First get the time and put dddhhmmss into the log entry.
*/
  rte_time(it,&it[5]);
  buf[0]='\0';
  int2str(buf,it[5],-4,1);
  strcat(buf,".");
  int2str(buf,it[4],-3,1);
  strcat(buf,".");
  int2str(buf,it[3],-2,1);
  strcat(buf,":");
  int2str(buf,it[2],-2,1);
  strcat(buf,":");
  int2str(buf,it[1],-2,1);
  strcat(buf,".");
  int2str(buf,it[0],-2,1);

  strcat(buf,"/");
  strcat(buf,msg);

/* Send the complete log entry to ddout via class.
*/
  memcpy(&ip1,"fs",2);
  memcpy(&ip2,"  ",2);

/* for testing, send to output PLUS class */
/*  fprintf(stdout,"%s\n",buf); */
  cls_snd(&shm_addr->iclbox,buf,strlen(buf),ip1,ip2);
}
