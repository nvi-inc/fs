#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <stdio.h>
#include <stdlib.h>

#define MAX_NAME 64
#define MAX_STRING  256
/*
   created by Oliver Oberdorf  8/91
  HISTORY:
  WHO  WHEN    WHAT
  gag  920901  Added error messages
*/ 

ftn_edit__(iname,ierr,ichange,editor,len,len_editor)
char *iname, *editor;
int *ierr,*ichange,len, len_editor;
{
     struct stat sb;
     int tmone, tmtwo;
     int error;
     char string[MAX_STRING+1],*s1;
     char path[MAX_STRING+1],*s2;
     char *ptr, *edstr;
     size_t n;

     *ichange=0;

     if(strcmp(editor,"edit")==0) {
       ptr=getenv("EDITOR");
       if (ptr == NULL) {
	 edstr = "vi";
       } else {
	 if(ptr == '\0') {
	   printf("existent but empty EDITOR environment variable");
	   *ierr=-1;
	   return;
	 } else
	   edstr=ptr;
       }
     } else
       edstr=editor;
     
     len_editor=strlen(editor);
     if (len+len_editor+1 > MAX_STRING) {
        printf("String to long to send to system\n");
	*ierr=-2;
        return;
     }

     s1=strcpy(string,edstr);
     s1=strcat(string," ");
     s1=strncat(string,iname,len);
     string[len+len_editor+1]='\0';

     s2=strncpy(path,iname,len);
     path[len]='\0';
     s2=strchr(path,' ');    /* put a NULL in place of the first blank */
     if(s2 != NULL) *s2='\0';

     if(stat(path, &sb)==-1) {
        printf("Error on %s, '",path);
        perror("on first stat");
        *ierr=-3;
        return;
     }
     tmone=(int) sb.st_mtime;

     *ierr=system(string);
     if (*ierr<0) {
       printf("running command '%s' failed\n");
       perror("fork or exec fail");
       return;
     };

     *ierr=0;

     if(stat(path, &sb)==-1) {
        printf("Error on %s, '",path);
        perror("on second stat");
        *ierr=-4;
        return;
     }
     tmtwo=(int) sb.st_mtime;

     if (tmone != tmtwo)
       *ichange=1;

     return;
}





















