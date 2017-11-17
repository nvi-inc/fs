#include <stdlib.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

/* nmea_wind() - decode NMEA standard wind message
 *
 * Input:
 *           str - buffer holding message
 *
 * Output:  (if return value is 0)
 *
 *           wdir - azimuth wind direction, degrees
 *           wsp  - wind speed, m/s
 *
 * Return value:
 *
 *     >0  = check-sum decode fail: unexpected errno value for strtol()
 *      0  = OK
 *     -1  = leading '$WIMWV' field missing
 *     -2  = '*' before check-sum missing
 *     -3  = check-sum decode failed: EINVAL
 *     -4  = check-sum decode failed: ERANGE
 *     -5  = check-sum doesn't agree
 *     -6  = can't find wind direction field
 *     -7  = can't decode wind direction field
 *     -8  = can't find 'R' field
 *     -9 = 'R' not present
 *    -10  = can't find wind speed field
 *    -11  = can't decode wind speed field
 *    -12  = can't find units field
 *    -13  = units not m/s
 *    -14  = can't find validity field
 *    -15  = data not valid
 */

int nmea_wind(char *strin, int *wdir, float *wsp)
{
  int len, i;
  char checksum, *ptr;
  unsigned int check;

  if(strncmp(strin,"$WIMWV",6)!=0)
    return -1;

  char str[512];
  strncpy(str,strin,sizeof(str));
  str[sizeof(str)-1]=0;

  len=strlen(str);
  checksum=0;
  for (i=0;i<len;i++) {
    if(str[i]=='*')
      break;
    if(str[i]!='$')
      checksum^=str[i];
  }

  ptr=strchr(str,'*');
  if(ptr==NULL)
    return -2;

  errno=0;
  check=strtol(ptr+1,NULL,16);
  switch(errno) {
  case 0:
    break;
  case EINVAL:
    return -3;
    break;
  case ERANGE:
    return -4;
    break;
  default:
    return errno;
    break;
  }
  if(check!=checksum)
    return -5;

  ptr=strtok(str,",");
  ptr=strtok(NULL,",");
  if(NULL==ptr)
    return -6;
  if(1!=sscanf(ptr,"%d",wdir))
    return -7;

  ptr=strtok(NULL,",");
  if(NULL==ptr)
    return -8;
  if('R'!=*ptr)
    return -9;

  ptr=strtok(NULL,",");
  if(NULL==ptr)
    return -10;
  if(1!=sscanf(ptr,"%f",wsp))
    return -11;

  ptr=strtok(NULL,",");
  if(NULL==ptr)
    return -12;
  if('M'!=*ptr) {
    return -13;
  }

  ptr=strtok(NULL,",");
  if(NULL==ptr)
    return -14;
  if('A'!=*ptr)
    return -15;

  return 0;

}
