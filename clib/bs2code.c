/* bs2code.c determine sampler codes for each VLBA rack type */

#include <sys/types.h>

static char *vlba[ 32]= {
  "1lm",  "1ls",  "1um",  "1us",
  "2lm",  "2ls",  "2um",  "2us",
  "3lm",  "3ls",  "3um",  "3us",
  "4lm",  "4ls",  "4um",  "4us",
  "5lm",  "5ls",  "5um",  "5us",
  "6lm",  "6ls",  "6um",  "6us",
  "7lm",  "7ls",  "7um",  "7us",
  "8lm",  "8ls",  "8um",  "8us"
};
static char *vlbag[ 32]= {
  "4us",  "3us",  "2us",  "1us",
  "4ls",  "3ls",  "2ls",  "1ls",
     "", "11us", "10us",  "9us",
     "", "11ls", "10ls",  "9ls",
  "8us",  "7us",  "6us",  "5us",
  "8ls",  "7ls",  "6ls",  "5ls",
     "", "14us", "13us", "12us",
     "", "14ls", "13ls", "12ls",

};

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

int bs2code(bs,type)
char *bs;
char *type;
{
  int i;
  char *(*array)[ 32];

  if (type == NULL)
    return -2;

  if (bs == NULL)
    return -3;

  if (strcmp(type,"vlba") == 0)
    array= &vlba;
  else if(strcmp(type,"vlbag") ==0)
    array= &vlbag;
  else
    return -4;

  if (strcmp(bs,"0")==0)
    return -1;

  if (strcmp(bs,"")==0)
    return -5;

  for (i=0;i<32; i++)
    if ((*array)[i] != NULL && strcmp(bs,(*array)[i])==0)
      return i;

  return -6;
}

char *code2bs(pin,type)
int pin;
char *type;
{
  char *(*array)[ 32];
  static char zero[]= "0";

  if (type == NULL)
    return "";

  if (strcmp(type,"vlba") == 0)
    array= &vlba;
  else if(strcmp(type,"vlbag") ==0)
    array= &vlbag;
  else
    return "";

  if(pin < -1 || pin > 31)
    return "";

  if (pin == -1)
    return zero;

  return (*array)[pin];
}
  
