/*
 * Copyright (c) 2020 NVI, Inc.
 *
 * This file is part of VLBI Field System
 * (see http://github.com/nvi-inc/fs).
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <http://www.gnu.org/licenses/>.
 */
/* LABEL.C -- Schedule bar code functions for PC-Sched.
 * David A. Schultz and Alan E. E. Rogers
 *
 * Bar code sections are based on modifications of the CodeMaster Bar Code
 * Printing software from Computer Connection.
 *
 */
#include "stdio.h"
#include "stdlib.h"
#include "ctype.h"
#include "string.h"
  
static unsigned char barcode[200];      /* barcode storage area */
static unsigned char *barptr;
static unsigned int barcnt;
static unsigned int bitcnt;
static unsigned int printcnt;           /* number bytes to print to printer */
static unsigned int numlaser;          /* number laser bar codes */

struct code {
  char init[20];                      /* graphics initialization code */
  char begin1[10];                    /* beginning code for graphics mode */
  char begin2[10];                    /* additional chars to begin code */
  char end[10];                       /* ending code for graphics mode */
  char uninit[20];                    /* code to reset to text spacing */
  char code_type;                     /* code type */
  int dpi;                            /* dots per inch resolution */
  int lpi;                            /* lines per inch resolution */
};

struct code codes[] = {
  {             /* TI 855 - 120               Printer 0 not used */
    { 27,'A',7 }, { 27,'L' }, "",
  "", { 27,'2' }, 1, 120, 9 },

  {           /* EPSON - 120 */
  /* { 27,'A',7 }, { 27,'L' }, "", */  /* was this */
    { 27,'1' }, { 27,'L' }, "", /* changed to this-works on Epson and IBM! */
  "", { 27,'2' }, 1, 120, 9 },

  {           /* Laserjet */
    "\033*t300R\033*r1A","\033*b", "W",
  "\033*rB","", 2, 120, 300 },

   {           /* EPSON - LQ */
    { 27,'0' }, { 27,'L' }, "",
  "", { 27,'2' }, 1, 120, 9 },

   {           /* postscript */
    {""}, { ""}, "",
  "", {""}, 1, 120, 300 },

};
  
typedef int Boolean;
typedef unsigned char byte;
#define DOTS 2
#define NULL 0L
#define FALSE 0
#define PRINTERS 4
  
int bar_code(char *, char *, char *, unsigned, unsigned, unsigned,
Boolean, int);
void bar_canceled_message(void);
int get_exp_name(void);

Boolean generate(byte *, byte *, byte *, struct code *, int, int,
Boolean, int);
void store_c(unsigned char, byte **);
void store_s(unsigned char *, byte **);
int textlength(char *);
char *findchr(char *, char);
Boolean three_9(char *, char);
void do_3x9(unsigned int, int);
int printbar(byte *, byte *, int, struct code *, int, int);
int alternate(unsigned int *, unsigned int, int);
void add(unsigned int, int), clearbar(void);
int barsize(char *,char *,unsigned,unsigned,unsigned,Boolean,int);
  
void bar_code_labels(void);

void make_label(FILE *,int,int,char *,char,char *,
int,int,int,int,int,int,int,int);

void make_pslabel(FILE *,char *,char,char *,
int,int,int,int,int,int,int,int);


/* Make one label */
void make_pslabel(FILE *fp, char * station_name, char station_code, char * expt_name,
int year, int start_day, int start_hour, int start_min,
int end_day,   int end_hour,   int end_min, int tape_number)
{
  char string[11];
  unsigned char *ptr,temp;
  int chksum = 1; /* 1 = Yes, include checksum character */
  int i,x,y,z,bit;
  double x1,y1,x2,y2;

  if(numlaser==0){
   fprintf(fp,"%%!PS-Adobe-\n%%%BoundingBox:  0 0 612 792\n%%EndProlog\n");
   fprintf(fp,"/Times-Roman findfont\n 10 scalefont\n setfont\n");
   fprintf(fp,"0 setgray\n1 setlinewidth\n");
   }
    numlaser++;

  /* Print the station code, day, hour/min into string like this:
     K123-1234, with a space on the end.
  */
  station_code = toupper(station_code);
  sprintf(string,"%c%3.3d-%2.2d%2.2d ", station_code, start_day,
  start_hour, start_min);
  x=50; y=705-(numlaser-1)*108;  /* units 1/72 inch */
  if(numlaser>6){ x+=280; y=705-(numlaser-7)*108; }
  fprintf(fp,"%d %d moveto\n",x,y);
  fprintf(fp,"(%-8.8s) show\n",station_name);
  fprintf(fp,"%d %d moveto\n",x+100,y);
  fprintf(fp,"(Start: %2.2d/%3.3d-%2.2d%2.2d) show\n",
  year, start_day, start_hour, start_min);
  y-=12;
  fprintf(fp,"%d %d moveto\n",x,y);
  fprintf(fp,"(%-8.8s) show\n",  expt_name);
  fprintf(fp,"%d %d moveto\n",x+100,y);
  fprintf(fp,"(End:    %3.3d-%2.2d%2.2d) show\n",end_day, end_hour, end_min);
  y-=12;
  fprintf(fp,"%d %d moveto\n",x,y);
  fprintf(fp,"(Tape %d) show\n",tape_number);

  three_9(string,chksum);
  for(i=z=0,ptr=barcode; i<barcnt; i++,z++){
  x1=x2=x+i*1.0; y1=y-10; y2=y1-36.0;
  if(z==8) z=0;
  if(!z) temp=*ptr++;
  bit=temp&1;
  if(bit){
   fprintf(fp,"newpath\n %5.1f %5.1f moveto \n %5.1f %5.1f lineto\nstroke\n",
   x1,y1,x2,y2);
      }
   temp >>= 1;
      }
  x+=60; y-=60;
  fprintf(fp,"%d %d moveto\n",x,y);
  fprintf(fp,"(%c%3.3d-%2.2d%2.2d ) show\n", station_code, start_day,
  start_hour, start_min);

  if(numlaser>11){
   fprintf(fp,"showpage\n%%%Trailer\n");
   numlaser=0;
  }
}


/*** CodeMaster bar code library functions follow: ***************************
*
*   (was) barcode.c
*
*   Bar code interface functions for C.
*
*   This function is called with:
*
* char *ret_string;
* int length;
*
* length = barsize(string,text,printnum,offset,height,chksum,passes);
* ret_string = malloc(length);
* length = bar_code(ret_string,string,text,printnum,offset,height,chksum,passes);
* fwrite(ret_string,1,length,stdprn);
* free(ret_string);
*
*       int length =                   length of the returned string in bytes
*                                      -1 if ret_string invalid
*                                      -2 was for invalid bar_type, which is
*                                         not used in PC-SCHED.
*                                      -3 if string invalid
*                                      -4 if text invalid
*                                      -5 if printnum invalid
*                                      -6 if offset invalid
*                                      -7 if height invalid
*                                      -8 if chksum not 1 or 0
*                                      -9 if bar code generation error
*       char *ret_string =             array of characters to store code to
*       char *string =                 the character string to bar code
*       char *text =                   the character string to print under bar
*       unsigned printnum =            0 for special order
*                                      1 for EPSON
*                                      2 for IBM Proprinter
*       unsigned offset =              number of characters from left margin
*                                          to indent.
*       unsigned height =              bar code height in 1/10 inch units
*                                          (max units = 10)
*       Boolean chksum =               whether to print checksum when optional
*       int passes =                   number of overstrike passes to print
******************************************************************************/




int
/****************************************************************************/
bar_code(ret_string,string,text,printnum,offset,height,chksum,passes)
/****************************************************************************/
char *ret_string;     /* array of characters to store code to */
char *string;         /* the character string to bar code */
char *text;           /* the character string to print under bar */
unsigned printnum;    /* the printer type */
unsigned offset;      /* number of characters from left margin */
unsigned height;      /* bar code height in 1/10 inch units */
Boolean chksum;       /* whether to print checksum when optional */
int passes;           /* number of overstrike passes to print */
{
  int error;
  
  error = 0;
  if (!ret_string)                    /* if null pointer passed */
    error = -1;
   /* Error -2 was for bar_type out of range.  I've removed bar_type,
      since we only use 3 of 9.  DAS 12-19-88
   */
  if (textlength(string) > 30 || !string)
    error = -3;
  if (textlength(text) > 30 || !text)
    error = -4;
  if (printnum > PRINTERS) /* Shouldn't this be PRINTERS-1 ?  DAS */
    error = -5;
  if (offset > 60)
    error = -6;
  if (height > 10 || height < 1)
    error = -7;
  if (chksum > 1 || chksum < 0)
    error = -8;
  if (passes > 5 || passes < 1)
    error = -9;
  
  if (!error)
  {
    if (generate(ret_string, string, text, &codes[printnum],
      offset, height, chksum, passes))
      error = -10;
  }
  if (!error)
    return ((int)printcnt);
  else
    return (error);
}
  
  
/* Last Modified by Mike on 11/5/88 11:52 am */
/******************************************/
/* Copyright (C) 1988 Computer Connection */
/*          All Rights Reserved           */
/******************************************/
  
char version[] = "Version 1.0";
  
/***
*
*   generate()
*
*   Generates the Bar Code codes to print.
*
*   This function is called with:
*       error = generate(ret_string, string, text, codes[printnum],
*                        offset, height, chksum, passes)
*
*       ret_string =                   string to store codes to.
*       string =                       string to bar code
*       text =                         string to print under bar code
*       codes =                        code structure ptr for printer codes.
*       offset =                       number of characters from left margin
*                                          to indent.
*       height =                       bar code height in 1/10 inch units
*                                          (max units = 10).
*       chksum =                       whether to print checksum if optional.
*       passes =                       number of strike over passes to print.
*
**/
  
char CHECKSUM;                         /* storage for the checksum char */
  
/****************************************************************/
Boolean generate(ret_string, string, text, codes,
offset, height, chksum, passes)
/****************************************************************/
byte *string,*text,*ret_string;
int offset, height;
struct code *codes;
Boolean chksum;
int passes; /* Added this line 12-19-88, DAS */
{
  Boolean error;
  char *findchr(),*ptr;
  
  CHECKSUM = 0;
  error = FALSE;
  
  error = textlength(string) > 30;
  if (!error) error = three_9(string,chksum);
  ptr = findchr(text,'_');            /* if checksum plug character */
  if (ptr && CHECKSUM)
    *ptr = CHECKSUM;
  if (!error)
    printbar(ret_string,text,offset,codes,height,passes);
  
  return (error);
}
  
/*************************************************************/
/* This module contains the subroutines needed to generate   */
/* the pattern.                                              */
/*************************************************************/
  
int
/***********************************************************************/
alternate(pattern,value,count)  /* alternate the bars using wide for 1 */
/***********************************************************************/
unsigned int *pattern;  /* memory area to store pattern */
unsigned int value;     /* the bits to add */
int count;              /* the count of the bits to add */
{
  int x;
  unsigned int bit;
  char dark;
  
  *pattern = 0;
  dark = 1;
  x = 0;
  while (count)
  {  count--;
    bit = value & (1 << count);
    bit >>= count;
    if (bit)                         /* if wide bar */
    {  *pattern <<= 3;
      x += 3;
      if (dark)                     /* if it is supposed to be dark */
        *pattern += 7;
    }
    else
    {  *pattern <<= 1;
      x++;
      if (dark)
        (*pattern)++;
    }
    dark = 1 - dark;                 /* toggle dark */
  }
  return(x);
}
  
void
/**********************************************/
clearbar()  /* clear out the bar code buffers */
/**********************************************/
{
  int x;
  unsigned char *ptr;
  
  barcnt = bitcnt = 0;                /* reset bar code bit pointer */
  printcnt = 0;
  barptr = barcode;                   /* reset bar code pointer */
  for (x=0,ptr=barcode;x<100;x++)
    *ptr++ = 0;
}
  
void
/****************************************************************/
add(value,count)  /* add the bit values to the bar code buffers */
/****************************************************************/
unsigned int value;   /* the bits to add */
int count;            /* the count of the bits to add */
{
  unsigned int bit;
  
  if (count > 16)
  {
    return;
  }
  while (count)
  {
    count--;
    bit = value & (1 << count);
    bit >>= count;
    *barptr += (bit << bitcnt++);
    barcnt++;
    if (bitcnt == 8)
    {
      bitcnt = 0;
      barptr++;
    }
  }
}
  
/******************************************************************/
char *findchr(string,letter)  /* locate the letter in the string */
/******************************************************************/
char *string,letter;
{
  while (*string != letter && *string)
    string++;
  return(*string ? string : 0);
}
  
void
/***************************************************************/
do_3x9(value,count)  /* alternate the bars for 3 of 9 bar code */
/***************************************************************/
unsigned int value;   /* the bits to add */
int count;            /* the count of the bits to add */
{
  unsigned int pattern;
  int x;
  
  x = alternate(&pattern,value,count);   /* put the codes in */
  pattern <<= 1;                      /* add the inter-character space */
  x++;
  add(pattern,x);                     /* add the bar code pattern */
}
  
Boolean
/***************************************************/
three_9(string,chksum)  /* print a 3 of 9 bar code */
/***************************************************/
char *string;     /* the string to print */
char chksum;      /* logical 1 or 0 to print checksum */
{
  static unsigned int code[] = {
    0064, 0441, 0141, 0540, 0061, 0460, 0160, 0045, 0444,
    0144, 0411, 0111, 0510, 0031, 0430, 0130, 0015, 0414,
    0114, 0034, 0403, 0103, 0502, 0023, 0422, 0122, 0007,
    0406, 0106, 0026, 0601, 0301, 0700, 0221, 0620, 0320,
  0205, 0604, 0304, 0250, 0242, 0212, 0052          };
  
  static char letter[] = {
    '0', '1', '2', '3', '4', '5', '6', '7', '8',
    '9', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
    'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q',
    'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  '-', '.', ' ', '$', '/', '+', '%', 0         };
  
  unsigned int checksum;
  unsigned char *index;
  char *ptr;
  int x;
#define start 0224
  
  for (ptr=string,x=textlength(string) ; x; x--,ptr++)
  {
    if (!findchr(letter,toupper(*ptr)))
      return(1);
  }
  clearbar();                         /* clear the bar code area */
  do_3x9(start,9);                    /* add the start character */
  
  for (ptr=string,x=textlength(string) ; x ; x--,ptr++)
  {
    index = findchr(letter,toupper(*ptr));
    if (index)
      do_3x9(code[(int) (index-letter)],9);
  }
  if (chksum)                         /* if checksum enabled, print it */
  {
    for (checksum=0,ptr=string,x=textlength(string); x; x--,ptr++)
    {
      index = findchr(letter,toupper(*ptr));
      checksum += (int) (index-letter);
    }
    checksum %= 43;
    CHECKSUM = letter[checksum];     /* save checksum */
    do_3x9(code[checksum],9);
  }
  
  do_3x9(start,9);                    /* add the start character again */
  return(0);
}
  
/*************************************************************/
/* This module contains the code to take the bit patterns    */
/* that were generated by the bar code library functions and */
/* generate the printer codes into the string.               */
/*************************************************************/
  
/***************************************************************************/
/* declaration for variable that determines if bytes are stored or counted */
/***************************************************************************/
char COUNTBYTE = 0;
  
void
/**********************************************************/
store_c(letter,string) /* store a character to the string */
/**********************************************************/
unsigned char letter;
byte **string;
{
  if (!COUNTBYTE)
  {
    **string = letter;
    (*string)++;
  }
  printcnt++;
}
  
void
/***************************************************************/
store_s(text,string) /* store a character string to the string */
/***************************************************************/
unsigned char *text;
byte **string;
{
  while (*text)
    store_c(*(text++),string);
}
  
int
/*************************************************************************/
printbar(string,text,offset,codes,height,passes)  /* print bar to string */
/*                                                                       */
/* Returns:  Size in 1/100 inch units.                                   */
/*************************************************************************/
byte *string;       /* string to store the information to */
byte *text;         /* text to print under bar code */
int offset;         /* number of text spaces to indent in */
struct code *codes; /* printer codes to use */
int height;         /* vertical width in .1 inch increments */
int passes;         /* number of strike over passes to do */
{
	int x,y,z,a,bit,bitp;
  unsigned char *ptr,temp,buf[4];
  int dots,lines;
  int bytecount;

  if (!barcnt)                        /* if nothing to print, return */
    return(0);


  dots = DOTS;
  if(codes->code_type==2) {dots=1;passes=1;}
  lines = (codes->lpi * height) / 10;
  bytecount = dots * barcnt;
  if(codes->code_type==2) store_s("     ",&string);
  store_s(codes->init,&string);
  store_s("\r",&string);
  for (x=0; x<lines*passes; x++)
  {
    for (y=0; y<offset; y++)
      store_c(' ',&string);
    store_s(codes->begin1,&string);   /* begin graphics mode */
    switch (codes->code_type)
    {
      case 1:                       /* byte 2 = multiple of 256
                                          byte 1 = remaining bytes */
        store_c(bytecount % 256,&string);
        store_c(bytecount / 256,&string);
        break;
      case 2:
        sprintf(buf,"%3d",(bytecount>>1));
        store_s(buf,&string);
        break;
    }
    store_s(codes->begin2,&string);   /* finishing touch to begin code */
    if (!COUNTBYTE)
    {
      for (y=z=0,ptr=barcode ; y<barcnt ; y++,z++)
      {
        if (z == 8)
          z = 0;
        if (!z)
          temp = *ptr++;

        bit = temp & 1;
        if (y==0) bitp=0; /* previous bit */
        if (codes->code_type==1){
         for (a=0;a<dots;a++) {
           if (bit && (bitp || a==1)) /* make black areas thinner by 1 pixel */
             store_c(255,&string);
           else
             store_c(0,&string); }
         }
        if (codes->code_type==2 && (y%2)==1){
          if(bitp==1) a=240; else a=0;
          if(bit==1)  a=a|15;
          store_c(a,&string);
         }
        temp >>= 1;
        bitp=bit;                 /* store previous bit */
      }
    }
    else
      printcnt += bytecount;
    store_s(codes->end,&string);      /* end graphics mode */
   if(codes->code_type==1){
		 if (x % passes == passes-1)
       store_s("\r\n",&string);
     else
       if(printer_number==1)store_s("\r\x1BJ\x01",&string);
    }
	}
	/* add extra 1/216 spaces when passes<3 */
	if(printer_number==1){
   for(x=0;x<(3-passes)*lines;x++) store_s("\r\x1BJ\x01",&string);
   }
  if(printer_number<3) store_s("\n",&string); /* line feed before printing text */

  store_s(codes->uninit,&string);      /* set line spacing back */
  for (x=0; x<passes; x++)
  {
    y = textlength(text);            /* get text length */
    z = 10 * bytecount;              /* calculate size in pica chars */
    z += codes->dpi-1;                /* round up */
    z /= codes->dpi;
    z -= y;                          /* find total extra spaces */
    z /= 2;                          /* divide by 2 */
    for (y=offset + z; y > 0; y--)
      store_c(' ',&string);

    store_s(text,&string);
    if (x % passes == passes-1)
      store_s("\r\n",&string);
    else
      store_s("\r",&string);
  }

  store_c(0,&string);                 /* terminating zero */

  return((100*bytecount)/codes->dpi);     /* return size in hundreds */
}
  
int
/*********************************************************/
textlength(string) /* return the length of a text string */
/*********************************************************/
char *string;
{
  int count;
  
  for (count=0; *string; string++,count++);       /* get length */
  return(count);
}
  
int
/****************************************************************/
barsize(string,text,printnum,offset,height,chksum,passes)
/****************************************************************/
char *string;
char *text;
unsigned printnum;
unsigned offset;
unsigned height;
Boolean chksum;
int passes;
{
  Boolean error;
  int x;
  char *ptr;
  static char valid[] = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%";
  int bytecount;
  int extend;
  
  error = 1;
  barcnt = 0;
  extend = 0;
  error = 0;
         /* each char is 6 zeros, 3 ones, 1 inter space */
  bytecount = 6 + (3*3) + 1;
  for (ptr=string,x=textlength(string); x; x--,ptr++)
  {
    if (!findchr(valid,toupper(*ptr)))
      error = 1;
  }
  if (!error)
  {
    barcnt = textlength(string) * bytecount;
    barcnt += 2 * bytecount;    /* add the start/stop character */
    if (chksum)
      barcnt += bytecount;     /* add the checksum */
  }
  
  if (extend == 2)
  {
    barcnt += 9;                     /* add blank spaces between bars */
    barcnt += 4;                     /* add start bars */
    barcnt += 7*2;                   /* add 2 numbers */
    barcnt += 2;                     /* add 1 intercharacter space */
  }
  
  if (extend == 5)
  {
    barcnt += 9;                     /* add blank spaces between bars */
    barcnt += 4;                     /* add start bars */
    barcnt += 7*5;                   /* add 5 numbers */
    barcnt += 2*4;                   /* add 4 intercharacter space */
  }
  
  printcnt = 0;
  COUNTBYTE = 1;                      /* count the bytes */
  printbar(0,text,offset,&codes[printnum],height,passes);
  COUNTBYTE = 0;                      /* generate the bytes */
  
  return((int)printcnt);
}

int get_exp_name(void) {
  int j,i,k,nchars,kk;

  save_the_screen();

 for(k=0;k<3;k++){ /* cycle through 3 times to get exp_,pi_,corr_name */
 /* Get an experiment name for the labels/schedule. */
  kk=k*5;
  if(k==0) nchars=8; else nchars=20;
  draw_box(24, 9+kk, 54+nchars-8, 13+kk, SINGLE, attr[clrset].menuw_border,
  attr[clrset].menuw_main,
  "",
  attr[clrset].menuw_title,
  (helpfp != NULL ? "F1 for help, Esc to cancel" : "Esc to cancel"), RIGHT);

  gotoxy_ds(26, 11+kk); textattr(attr[clrset].menuw_main);
  if(k==0)cputs("Experiment name:");
  if(k==1)cputs("P.I. name:");
  if(k==2)cputs("Correlator:");

  draw_box(43, 10+kk, 52+nchars-8, 12+kk, SINGLE, attr[clrset].menuw_input,
  attr[clrset].menuw_input, DUM_STR, DUM_CHAR, DUM_STR, RIGHT);

  if(k==0 && (j = strlen(exp_name)) != 0) sprintf(buffer,"%-8.8s",exp_name);
  if(k==1 && (j = strlen(pi_name)) != 0) sprintf(buffer,"%-20.20s",pi_name);
  if(k==2 && (j = strlen(corr_name)) !=0)sprintf(buffer,"%-20.20s",corr_name);

  new_cgets(&j, 44, 11+kk, nchars, "exptname");

  if(k==2 || j==-1)rewrite_the_screen();
  if (j >= 0){i=0;
     while(buffer[i]!=0 && i<nchars && (buffer[i]!=' ' || k>0)){
      if(buffer[i]=='.' && k==0 ) buffer[i]='_'; /* change period to underscore */
     i++;}
    if(k==0){strncpy(exp_name,buffer,i);exp_name[i]=0;}
    if(k==1){strncpy(pi_name,buffer,i);pi_name[i]=0;}
    if(k==2){strncpy(corr_name,buffer,i);corr_name[i]=0;}
       }
  if(j < 0) return 0;
}
  return (j < 0) ? 0 : 1; /* j will be -1 if Esc was pressed in new_cgets() */
}

void bar_canceled_message(void) {
  
  prompt("\"Bar Code Labels\" canceled.  Press a key.",
  NO_BEEP, WAIT_RESP, SAVE_VID, MSG, attr[clrset].msg_main,
  attr[clrset].msg_border, attr[clrset].msg_title,
  "canbar");
}

