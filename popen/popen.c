#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define BUFF_SIZE 512
#define OUT_SIZE  512

static err_out(char *out)
{
  if (nsem_test("fs   ") == 1) {
    logit(out,0,NULL);
  } else
    fprintf(stderr,"%s\n",out);	
  exit(-1);
}

int main (int argc, char *argv[])
{

FILE *fp;
int status;
char buffer[BUFF_SIZE];
char out[BUFF_SIZE];

 char *name, *command;
 int c, index, no_display;

 setup_ids();
 putpname(argv[0]);

 name = argv[0];
 command = NULL;
 no_display=0;

 opterr = 0;
 while ((c = getopt (argc, argv, "lc:n:")) != -1) {
   switch (c) {
   case 'n':
     name = optarg;
     break;
   case 'l':
     no_display = 1;
     break;
   case 'c':
     command = optarg;
     break;
   case '?':
     if (optopt == 'c' || optopt == 'n')
       snprintf(out,OUT_SIZE,
		"%s:Option -%c requires an argument.",name,optopt);
     else if (isprint (optopt))
       snprintf(out,OUT_SIZE,
		"%s:Unknown option `-%c'.", name,optopt);
     else
       snprintf(out,OUT_SIZE,
		"%s:Unknown option character `\\x%x'.",name,optopt);
     err_out(out);
     break;
   default:
     if(isprint(c))
       snprintf(out,OUT_SIZE,
		"%s:Impossible return from getopt '%c'",name,c);
     else
       snprintf(out,OUT_SIZE,
		"%s:Impossible return from getopt '\\x%x'",name,c);	   
     err_out(out);
     break;
   }
 }
 for (index = optind; index < argc; index++) {
   if(index == optind)
     command=argv[index];
   else {
     snprintf(out,OUT_SIZE,"%s:%s",name,
	      "Too many non-option arguments given");
     err_out(out);
   }
 }

 if(command == NULL) {
   snprintf(out,OUT_SIZE,"%s:%s",name,"No command given");
   err_out(out);
 }
 fp = popen(command, "r");
 if (fp == NULL)  {
   snprintf(out,OUT_SIZE,"%s:%s",name,"popen() failed");
   err_out(out);
 }

 /* needs timout detection */

 while (fgets(buffer, BUFF_SIZE, fp) != NULL) {
   if(strlen(buffer) > 0 && buffer[strlen(buffer)-1] == '\n')
     buffer[strlen(buffer)-1]=0;
   snprintf(out,OUT_SIZE,"%s/%s",name,buffer);
   if (nsem_test("fs   ") == 1) {
     if(no_display) 
       logit_nd(out,0,NULL);
     else
       logit(out,0,NULL);
   } else {
     printf("%s\n",out);
   }
 }
   
 status = pclose(fp);
 if (status == -1) {
   snprintf(out,OUT_SIZE,"%s:%s",name,"pclose() failed");
   err_out(out);
 } else if(status!=0) {
   /* Use macros described under wait() to inspect `status' in order
      to determine success/failure of command executed by popen() */
   snprintf(out,OUT_SIZE,"%s:exit status %d",name,status);
   err_out(out);
 }
}
