/* pbm2lwxl.c - Copyright 1999 by Mark Whitis.  All Rights Reserved. */
/* A driver for the Costar Labelwriter XL and compatible printers */

/* The labelwriter XL uses 19200.  Older models use 9600 */
/* I think the avery units are relabeled costar units - they look identical */
/* inside and out */

/* uses xon/xoff - configure spooler appropriately */
/* or use something like: "stty 19200 ixon </dev/cua1" */

/* usage: */
/*     pbm2lwxl [ width [height] ] */
/* width and height are in pixels.  width should be 192 (1") or 448 */
/* (wide models).   

/* You will probably want to use one or more of the following utilities */
/*    mpage -1 -o -m720t0lrb -L6      - ascii to postscript */
/*    ghostscript -sDEVICE=pbm -sOutputFile=- -q -dNOPAUSE -r192x192 -g700x192 -dSAFER - -c quit */
/*    pnmflip -cw   - to rotate 90 degrees */
/*    pnmnoraw      - convert from raw to plain (ascii) pnm format. */
/* Note that the ghostscript command shown above generates 700x192 */
/* which should be pnmflip'ed to get 192x700 for printing */

/* http://www.freelabs.com/~whitis/software/pbm2lwxl/ */

/* This program will not drive seiko label printers. */
/* For a similar program for seiko label printers, see */
/*    http://members.tripod.com/~uutil/slap/ */
/* That is a rather bloated program which tries to reinvent the wheel */
/* instead of cooperating with the existing rasterizer (ghostscript) */



/* This program does not use libpnm */


#include <stdlib.h>
#include <stdio.h>
#include <assert.h>

/* 1" model has 192 resistive elements */
/* 2" model has 448 resistive elements */
/* about 200 lines per inch */
int label_width=192;
int label_height=600;


reset()
{
   int i;
   for(i=0;i<57;i++) {
      printf("%c",27);
   }
   printf("Q");
}


/* n is number of pixels wide */
/* data must be n/8 bytes or larger */
print_line(int n, unsigned char data[])
{
  int i;

  int nbytes;
  nbytes=(n+7)>>3;
  #if 0
     printf("%cD%c",27,nbytes);  /* ESC D n - set bytes per line*/
  #else
     printf("%c",27);      /* ESC D n - set bytes per line*/
     printf("D");          /* ESC D n - set bytes per line*/
     printf("%c",nbytes);  /* ESC D n - set bytes per line*/
  #endif
  printf("%c",0x16);  /* <syn> */
  for(i=0;i<nbytes;i++) { 
     printf("%c",data[i]);
  }
}



form_feed()
{
   printf("%cE",27);   /* ESC E - formfeed */
}

set_label_length(int n)
{
   /* ESC L msb lsb - load label length*/
   /* use -1 for continuous form stock/inhibit paper jam check */
   /* defaults to 7" */
   /* ok if larger than label */ 
   printf("%cL%c%c",27,(n>>8), (n & 0xFF));
}

int pixel_order[]= { 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01 };

test()
{
   int i;
   int j; 
   int pos;
   unsigned char data[512];   
   for(i=0; i<label_height; i++) {
     pos++;
     if(pos>=label_width) pos=0;

     /* clear data */
     for(j=0;j<sizeof(data); j++) {
         data[j]=0;
     }
     /* set one bit */
     data[pos>>3] |= pixel_order[pos&0x07];

     print_line(label_width, data);
   }
}

read_pbm_header(int *width_p, int *height_p)
{
   char buf[4096];
   int found_type;

   found_type=0;

   while(1) {
      fgets(buf,sizeof(buf),stdin);
      if(strncmp(buf,"P1",2)==0) {
         found_type=1;
      } else if (buf[0]=='#') {
	;  /* skip comment */
      } else if (sscanf(buf,"%d %d",width_p,height_p)==2) {
         assert(*width_p>0);
         assert(*height_p>0);
         assert(*width_p<4096);
         assert(*height_p<4096);
         break;
      } else {
        fprintf(stderr, "Error: Input is not in plain PBM (noraw) format\n");
        fprintf(stderr, "Try running through pnmnoraw\n");
        abort();
      }
   }     
}

/* length in pixels, not bytes */
void set_pixel(int length, unsigned char *data, int pos) 
{
     if(pos>=length) return;
     if(pos<0) return;
     data[pos>>3] |= pixel_order[pos&0x07];
}

void reset_pixel(int length, unsigned char *data, int pos) 
{
     if(pos>=length) return;
     if(pos<0) return;
     data[pos>>3] &= ~pixel_order[pos&0x07];
}

int read_pbm_line(int length, unsigned char *data, int pbm_width, int pbm_height)
{
   int c;
   int pos;
   int count;

   pos=0;
   count=pbm_width;

   while(count) {
      c=fgetc(stdin);
      if(c==EOF) return(EOF);

      if(c=='1') {
         set_pixel(length, data, pos);
         pos++;
         count--;
      }

      if(c=='0') {
         reset_pixel(length, data, pos);
         pos++;
         count--;
      }
   }
   return(0);

}

main(int argc, char **argv)
{
   unsigned char data[512];
   int i;
   int j;
   int pos;
   char buf[4096];
   int rc;
   int pbm_width;
   int pbm_height;

   read_pbm_header(&pbm_width, &pbm_height);

   /* note that the printer itself cannot handle this high a width */
   /* but we allow some excess in case the introduce a wider model */
   /* the 2040 limit is set by the protocol (255 bytes) */
   if(argc>=2) label_width=atoi(argv[1]);
   assert(label_width > 0);
   assert(label_width <= 2040);
   if(argc>=3) label_height=atoi(argv[2]);
   assert(label_height > 0);
   assert(label_height <= 4096);

   for(i=0;i<sizeof(data); i++) {
       data[i]=0;
   }
   

   #if 0
     /* reset seems to cause spaz */
      reset();
      set_label_length(1424);
   #endif


   for(i=0; i<pbm_height && i<label_height; i++) {
      /* clear data */
      for(j=0;j<sizeof(data); j++) {
          data[j]=0;
      }

      rc=read_pbm_line(label_width, data, pbm_width, pbm_height);
      if(rc!=0) break;

      print_line(label_width, data);
   }


   form_feed();
   return (0);
}
