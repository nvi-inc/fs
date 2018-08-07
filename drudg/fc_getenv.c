#include <stdlib.h>

#ifdef F2C
int fc_getenv__(name,path)
#else
int fc_getenv(name,path)
#endif

 char **name;
 char **path;
{
 char *p1;
 int len;
      printf("String %s ","on etnry") ;
      p1 = getenv(*name);
      if ( p1 == 0 ) return(0);
      len = strlen(p1);
      printf("Len %d  ",len);
      printf("String %s ",p1);
      if(len > 0) strncpy(*path,p1,len);
      return (len);
}
