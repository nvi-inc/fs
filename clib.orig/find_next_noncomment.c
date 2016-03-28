#include <stdio.h>
#include <string.h>

int find_next_noncomment(fp,buff,sbuff)
     FILE *fp;
     char buff[];
     int sbuff;
{  
  char check, *cptr;
  int i;

 start:
  check=fgetc(fp);
  while(check == '*' && check != EOF) {
    check=fgetc(fp);
    while(check != '\n' && check != EOF)
      check=fgetc(fp);
    if(check != EOF) {
      check=fgetc(fp);
    }
  }

  if (check == EOF)
    /* ended in comment */
    return -1;
  else if(ungetc(check, fp)==EOF)
    return -2;

  cptr=fgets(buff,sbuff,fp);
  if(cptr!=buff)
    return -3;

  if(strchr(buff,'\n')==NULL)
    return -4;

  for(i=0;i<strlen(buff);i++) {
    if(strchr(" \n\t",buff[i])==NULL) {
      return 0;
    }
  }
  
  goto start;
}
