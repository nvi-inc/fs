#include <stdio.h>
#include <string.h>
#include <sys/types.h>

void uns2str(output,uvalue,width)
char *output;
unsigned uvalue;
int width;
{
      int i;
      char local[11];     /* big enough to hold largest possible */
                          /* formatted unsigned int (32 bits) plus '\0'  */

      output=output+strlen(output);

      sprintf(local,"%u",uvalue);
      if(strlen(local) > width) {
        for (i=0; i< width; i++) 
          output[i]='$';
        output[width]='\0';
      } else
        strcpy(output,local);
     
      return;
}

void flt2str(output,fvalue,width,deci)     /* floating point to string */
char *output;                              /* output string to append to */
float fvalue;                              /* value to convert */
int width;        /* maximum field width, >0 left justify, <0 right justify */
                  /* fewer than width characters may be used for left just. */
int deci;         /* digits after decimal point, >=0 blank fill for right   */
                  /* justify, <0 zero fill, 0 will print decimal point */
/* if output won't fit in specified width, that many characters are filled  */
/* with dollar signs */
/* this function is intended to be a replacement for FORTRAN ir2as routine */
{
      char form[30];   /* must be big enough to hold largest possible format */
      char string[256];/* must be big enough to hold largest possible float */

      char *ptr, zero[2], sign[2];
      int i,decpt, ndigit, wide, decd;

      output=output+strlen(output);     /* locate where to start filling */

      wide=width; strcpy(sign,"-");     /* handle justification */
      if(wide<0) {
        wide=-width;
        strcpy(sign,"");
      }

      decd=deci; strcpy(zero,"");       /* handle padding */
      if(decd<0) {
        decd=-deci;
        strcpy(zero,"0");
      }

      if(deci==0) decd=1;               /* make sure we get a decimal point */

      sprintf(form,"%%%s%s%d.%df",sign,zero,wide,decd);  /* make format */
      sprintf(string,form,fvalue);                       /* do it */

      if(width>0) {                   /* trim trailing spaces for left-just. */
         ptr=strchr(string,' ');
         if(ptr!=NULL) *ptr='\0';
      }
                                    /* remove post-decimal digit for deci==0 */

      if(deci==0 && strlen(string)>0) string[strlen(string)-1]='\0';

      if(strlen(string)>wide) {     /* too wide, $ fill */
        for (i=0; i< wide; i++) 
          output[i]='$';
        output[wide]='\0';
        return;
      } else
        strcat(output,string);      /* okay, append result */

       return;
}

void dble2str(output,fvalue,width,deci)     /* floating point to string */
char *output;                              /* output string to append to */
double fvalue;                              /* value to convert */
int width;        /* maximum field width, >0 left justify, <0 right justify */
                  /* fewer than width characters may be used for left just. */
int deci;         /* digits after decimal point, >=0 blank fill for right   */
                  /* justify, <0 zero fill, 0 will print decimal point */
/* if output won't fit in specified width, that many characters are filled  */
/* with dollar signs */
/* this function is intended to be a replacement for FORTRAN ir2as routine */
{
      char form[30];   /* must be big enough to hold largest possible format */
      char string[256];/* must be big enough to hold largest possible float */

      char *ptr, zero[2], sign[2];
      int i,decpt, ndigit, wide, decd;

      output=output+strlen(output);     /* locate where to start filling */

      wide=width; strcpy(sign,"-");     /* handle justification */
      if(wide<0) {
        wide=-width;
        strcpy(sign,"");
      }

      decd=deci; strcpy(zero,"");       /* handle padding */
      if(decd<0) {
        decd=-deci;
        strcpy(zero,"0");
      }

      if(deci==0) decd=1;               /* make sure we get a decimal point */

      sprintf(form,"%l%%s%s%d.%df",sign,zero,wide,decd);  /* make format */
      sprintf(string,form,fvalue);                       /* do it */

      if(width>0) {                   /* trim trailing spaces for left-just. */
         ptr=strchr(string,' ');
         if(ptr!=NULL) *ptr='\0';
      }
                                    /* remove post-decimal digit for deci==0 */

      if(deci==0 && strlen(string)>0) string[strlen(string)-1]='\0';

      if(strlen(string)>wide) {     /* too wide, $ fill */
        for (i=0; i< wide; i++) 
          output[i]='$';
        output[wide]='\0';
        return;
      } else
        strcat(output,string);      /* okay, append result */

       return;
}

void int2str(output,ivalue,width,zorb)  /* integer point to string */
char *output;                           /* output string to append to */
int ivalue;                             /* value to convert */
int width;        /* maximum field width, >0 left justify, <0 right justify */
                  /* fewer than width characters may be used for left just. */
int zorb;         /* zeros or blanks, = 0 blank fill for non digit       */
                  /* positions, !=0 zero fill */
/* if output won't fit in specified width, that many characters are filled  */
/* with dollar signs */
/* this function is intended to be a replacement for FORTRAN ib2as routine */
{
      char form[30];   /* must be big enough to hold largest possible format */
      char string[256];/* must be big enough to hold largest possible integer*/

      char *ptr, zero[2], sign[2];
      int i,decpt, ndigit, wide, decd;

      output=output+strlen(output);     /* locate where to start filling */

      wide=width; strcpy(sign,"-");     /* handle justification */
      if(wide<0) {
        wide=-width;
        strcpy(sign,"");
      }

      decd=zorb; strcpy(zero,"");       /* handle padding */
      if(decd!=0) {
        decd=-zorb;
        strcpy(zero,"0");
      }

      if(zorb==0) decd=1;               /* make sure we get a decimal point */

      sprintf(form,"%%%s%s%dd",sign,zero,wide);  /* make format */
      sprintf(string,form,ivalue);                       /* do it */

      if(width>0) {                   /* trim trailing spaces for left-just. */
         ptr=strchr(string,' ');
         if(ptr!=NULL) *ptr='\0';
      }

      if(strlen(string)>wide) {     /* too wide, $ fill */
        for (i=0; i< wide; i++) 
          output[i]='$';
        output[wide]='\0';
        return;
      } else
        strcat(output,string);      /* okay, append result */

       return;
}
