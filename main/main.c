#include <stdio.h>
#include <memory.h>
#include <string.h>
#include <sys/types.h>

#define MAX 256

main(argc,argv)
int argc;
char *argv[ ];
{
   void setup_ids();
   char buffer[MAX],name[5],*start,*slash, *ptr, *nargv[2];
   int indx,i,n,rtn1,rtn2;
   long class,ip[5];
 
   indx=0;
   for (i=0;i<argc && indx <MAX;i++) {
       n=strlen(argv[i]);
       n=MAX-indx<n?MAX-indx:n;
       (void) strncpy(buffer+indx,argv[i],(size_t) n);
       indx=indx+n;
       if (MAX-indx>=1) buffer[indx++]='\0'; 
   }

   setup_ids();

   ip[0]=0;
   cls_snd(&ip[0],buffer,indx,0,0);
    
   (void) memcpy(name,"     ",5);
   start=argv[0];
   if( NULL != (slash = strrchr(argv[0],'/')) ) start=slash+1;
   n=strlen(start);
   (void) memcpy(name,start,n<=5?n:5);

   skd_run(name,'n',ip);

   for( ptr=start;*ptr!='\0';ptr++) *ptr=toupper(*ptr);

   nargv[0]=argv[0];
   nargv[1]=NULL;
   execvp(nargv[0],nargv);
   perror(nargv[0]);
   (void)cls_rcv(ip[0],buffer,MAX,&rtn1,&rtn2,0,0);
   skd_wait(name,ip,(unsigned)0);
  
}
