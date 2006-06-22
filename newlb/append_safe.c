#include <string.h>

append_safe( dest, src, n)
     char *dest; /* destination buffer, NULL terminated on entry */
     char *src;  /* source string, NULL terminated on entry */
     size_t n;   /* total sizeof(dest) from dest[0] */
     /* returns: zero if there was no problem,
      *          positive number of characters that won't fit otherwise
      */
{
  size_t s,d,o,m;
  
  s=strlen(src)+1;           /* space required for src */
  d=strlen(dest)+1;          /* space used in dest */
  o=n-d;                     /* space open in dest */
  m=(s<o)?s:o;               /* number to copy */
  strncpy(dest+d-1,src,m);
  if(m<s) {
    dest[n-1]=0;             /* NULL terminate when too long to fit */
    return s-m;
  }
  return 0;
}
