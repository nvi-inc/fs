/* rp2codek42.c determines recorder port inputs for k42 rack */

#include <stdio.h>

static char *channel[ 32]= {
  "a1l",  "a1u",
  "a2l",  "a2u",
  "a3l",  "a3u",
  "a4l",  "a4u",
  "a5l",  "a5u",
  "a6l",  "a6u",
  "a7l",  "a7u",
  "a8l",  "a8u",
  "b1l",  "b1u",
  "b2l",  "b2u",
  "b3l",  "b3u",
  "b4l",  "b4u",
  "b5l",  "b5u",
  "b6l",  "b6u",
  "b7l",  "b7u",
  "b8l",  "b8u"
};

int rp2codek42(bs)
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

char *code2rpk42(pin)
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
  
