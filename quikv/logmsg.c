#include <string.h>
#include <sys/types.h>

#include "../include/params.h"
#include "../include/fs_types.h"
#include "../include/fscom.h"

void logmsg(output,command,ip)
char *output;
struct cmd_ds *command;
long ip[5];
{
   struct res_buf buffer;
   struct res_rec response;
   void opn_res(), get_res(), clr_res(), cls_snd();
   int first, i;

   opn_res(&buffer,ip);
   for (i=0;i<5;i++) ip[i]=0;

   get_res(&response, &buffer);
   strcpy(output,command->name);
   strcat(output,"/");
   first=TRUE;

   while(-1 != response.state) {    /* log command/ if no responses */
     while(-1 != response.state && strlen(output)+5<128) {
       if(first){
         strcat(output,"ack");
         first=FALSE;
       } else
         strcat(output,",ack");
       get_res(&response, &buffer);
     }
     if(-1 != response.state){
       cls_snd(ip,output,strlen(output),0,0);
       ip[1]++;
       strcpy(output,command->name);
       strcat(output,"/");
       first=TRUE;
     }
   }
   cls_snd(ip,output,strlen(output),0,0);
   ip[1]++;

   clr_res(&buffer);
   return;

}
