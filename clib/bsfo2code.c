/* bsfo2code.c determine sampler codes for mark IV rack type */

#include <sys/types.h>
#include <string.h>

/* test code
 *
 * main()
 * {
 * int i;
 *
 * for (i=0;i<32;i++)
 *   if(vlbag[i] != 0)
 *     printf(" %x", trkasg(vlbag[i],"vlbag"));
 *
 *  printf("\n");
 * }
*/

int bsfo2code(bs)
char *bs;
{
  int vc, sb, b, fo=-1, code;
  char *pos;
  char digits[]="0123456789";
  char sidebands[]="ul";
  char bits[]="sm";

  if (bs == NULL)
    return -2;

  if (strcmp(bs,"0")==0)
    return -1;

  if (strcmp(bs,"")==0)
    return -3;

/*decode bit-stream "+" fan-out */

  while(*bs != 0 && *bs==' ')
    bs++;

  pos=strchr(digits,*bs);
  if(pos==NULL || *pos == '0')
    return -4;
  else
    vc=pos-digits;

  bs++;
  pos=strchr(digits,*bs);
  if(pos!=NULL) {
    vc=vc*10+pos-digits;
    if(vc>16)
      return -4;
    bs++;
  }

  pos=strchr(sidebands,*bs);
  if(pos==NULL)
    return -4;
  sb=pos-sidebands;

  bs++;
  pos=strchr(bits,*bs);
  if(pos==NULL)
    return -4;
  b=pos-bits;

  bs++;
  if(*bs=='+') {
    bs++;
    pos=strchr(digits,*bs);
    if(pos==NULL)
      return -4;
    fo=pos-digits;
    if(fo>3)
      return -4;
    bs++;
  }

  if(*bs==' ') {
    bs++;
    while(*bs!=0&& *bs==' ')
      bs++;
    if(*bs !=0)
      return -4;
  } else if(*bs!=0)
    return -4;

/*got it, now set-up code */

  code=(vc-1)|(sb<<4)|b<<5;
  if(fo>=0)
    code|=(0x100)|(fo <<6);

  return code;
}

char *code2bsfo(pin)
int pin;
{
  static char array[7];
  static char zero[]= "0";

  if(pin==-1)
    return zero;

  sprintf(array,"%d",1+(pin&0xF));

  if((1<<4)&pin)
    strcat(array,"l");
  else
    strcat(array,"u");

  if((1<<5)&pin)
    strcat(array,"m");
  else
    strcat(array,"s");

  if(pin & 0x100)
    sprintf(array+strlen(array),"+%d",(pin>>6)&0x3);

  return array;
}
  
