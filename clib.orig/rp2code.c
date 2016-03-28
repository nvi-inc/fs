/* rp2code.c determines recorder port inputs */

#include <stdio.h>

static char *channel[ 28]= {
  "1l",  "1u",
  "2l",  "2u",
  "3l",  "3u",
  "4l",  "4u",
  "5l",  "5u",
  "6l",  "6u",
  "7l",  "7u",
  "8l",  "8u",
  "9l",  "9u",
 "10l", "10u",
 "11l", "11u",
 "12l", "12u",
 "13l", "13u",
 "14l", "14u"
};

int rp2code(bs)
char *bs;
{
  int i;

  if (bs == NULL)
    return 0;

  if (strcmp(bs,"0")==0)
    return 0;

  if (strcmp(bs,"")==0)
    return 0;

  for (i=0;i<(sizeof(channel)/sizeof(char *)); i++)
    if (strcmp(bs,channel[i])==0)
      if(i%2==0)
	return -(i/2+1);
      else
	return i/2+1;

  return 0;
}

char *code2rp(pin)
int pin;
{
  static char zero[]= "0";

  if(pin < -14 || pin > 14 || pin == 0)
    return zero;
  else if(pin <0)
    return channel[(-pin-1)*2];
  else
    return channel[(pin-1)*2+1];

}
  
