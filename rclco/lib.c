#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <assert.h>

#ifdef UNIX
# include <unistd.h>
# include <errno.h>
# include <sys/types.h>
# include <fcntl.h>
# include <curses.h>
# undef bool          /* defined by curses.h, nasty! */
#endif UNIX

#include "main.h"
#include "input.h"

#define LIB
#include "lib.h"
#undef LIB


/* Library of miscellaneous functions */


/*
 * Local Constants
 */
#define MALLOC2SIZE 111        /* cycle size for malloc2() */


void* malloc2(int size)
/*
 * This is a special version of malloc() that requires no subsequent free().
 * Objects allocated using malloc2() have a lifetime determined by the number 
 * of subsequent calls to malloc2(). Specifically, an object is deleted after 
 * MALLOC2SIZE subsequent calls. This is meant to ensure that the object 
 * remains active for some sufficient time period, but not permanently. 
 * malloc2() is used mainly by functions which return strings, such as 
 * int_to_str(), to make the return
 * value (a pointer to char) directly usable in nested calls to other
 * functions. The returned pointer must not be kept permanently, so the result
 * should be copied to another location for permanent storage. Also be careful
 * with very deep call sequences such as in recursive functions. Internally, 
 * malloc2() simply keeps an array of MALLOC2SIZE pointers and uses them
 * cyclically, freeing old data when a pointer gets reused.
 * 'size' is the amount of space to obtain in bytes.
 * The function result is a pointer to the allocated space. It must be
 * type-cast before assignment to the appropriate pointer variable.
 * A null result indicates no more memory is available.
 */
{
   static void* ptrs[MALLOC2SIZE];
   static int index = -1;
   int i;
   void* result;

   if (index==-1)  {
      /* initialization */
      index=0;
      for (i=0; i<MALLOC2SIZE; i++)  {
         ptrs[i]=NULL;
      }
   }

   if (ptrs[index]!=NULL)
      free(ptrs[index]);

   /*printf("%s: malloc2: Allocating new string, size %d\n",self,size);*/
   result=ptrs[index]=malloc(size);
   if (result==NULL)  {
      malloc_out_of_space("malloc2()",1);   /* never returns */
   }

   index=(index+1) % MALLOC2SIZE;

   return(result);
}

const char* strapp (const char* a, const char* b, const char* c)
/*
 * This function appends up to 3 strings together, returning a pointer to the
 * result. It uses 'malloc' for the result, so the returned pointer will be
 * valid for an indefinite period. Note that, unlike strcat, none of the
 * arguments are changed. Anywhere from 1 to 3 arguments are allowed (pass
 * nulls for unused args). Nested calls are allowed (thanks to 'malloc2') if
 * more than 3 arguments are needed. 
 * This routine prints a warning to the standard error stream if the 
 * result ends up too long (longer than MAXSTRLEN), but no error indication 
 * is returned to the caller. The caller should ensure that the result will 
 * not be too long to prevent data corruption. Note that the result is defined 
 * as const to prevent unintended assignment to a volatile data area.
 */
{
   char* result;

   /* get MAXSTRLEN bytes of garbage collected space */
   result=(char*)malloc2(MAXSTRLEN);   
   strcpy(result,a);
   if (b!=NULL && *b!=(char)NULL) strcat(result,b);
   if (c!=NULL && *c!=(char)NULL) strcat(result,c);
   if (strlen(result)>MAXSTRLEN-1)  {
      printf("lib: Error in strapp() --- result too long!\n");
   }
   return(result);
}

const char* strapp5(const char* a, const char* b, const char* c,
                    const char* d, const char* e)
/*
 * Like strapp, but appends up to 5 strings together.
 */
{
   char* result;

   /* get MAXSTRLEN bytes of garbage collected space */
   result=(char*)malloc2(MAXSTRLEN);   
   strcpy(result,a);
   if (b!=NULL && *b!=(char)NULL) strcat(result,b);
   if (c!=NULL && *c!=(char)NULL) strcat(result,c);
   if (d!=NULL && *d!=(char)NULL) strcat(result,d);
   if (e!=NULL && *e!=(char)NULL) strcat(result,e);
   if (strlen(result)>MAXSTRLEN-1)  {
      printf("lib: Error in strapp5() --- result too long!\n");
   }
   return(result);
}

int str_to_int(const char* a)
/*
 * This function converts a string to integer format, returning the resulting
 * integer. The string must be interpretable as an integer by sscanf,
 * We use long ints to be more general, but most of the time only regular
 * ints are needed (comment applies to PC, 16-bit default int).
 * otherwise 0 is returned. Unlike atoi(), it handles "0x" to specify hex.
 * The caller cannot determine whether an error occurred, but a warning 
 * message is output to the standard error stream.
 * 'a' is the string to convert.
 */
{
   int err;
   int result;

   if (strneq(a,"0x",2))
      err=sscanf((char*) a+2,"%lx",&result);  /* (cast: sscanf defined wrong) */
   else if (strneq(a,"$",1))
      err=sscanf((char*) a+1,"%lx",&result);
   else
      err=sscanf((char*) a,"%ld",&result);
   if (err!=1)  {
      printf("Warning --- bad str_to_int conversion of %s\n",a);
      return(0);
   }

   return(result);
}

const char* int_to_str(int a, int f)
/*
 * Keywords: FS, lib, misc
 * Imports: sprintf()
 *
 * This function converts a integer to string format, returning a pointer
 * to the resulting string. It uses 'malloc2' for the result, so the returned
 * pointer will be valid for an indefinite period. Note that the result is
 * defined as const to prevent unintended assignment to a volatile data area.
 * We use long ints to be more general, but most of the time only regular
 * ints are needed (comment applies to PC, 16-bit default int).
 * 'a' is the (long) integer to convert.
 * 'f' specifies a field size. If the result is shorter than 'f' characters
 * it is padded on the left with spaces. Use 0 if you don't care. Use negative
 * numbers to pad with zeroes instead of spaces.
 */
{
   char* result;
   int space;

   if (f<15)
      space=14;              /* int will not expand more than this */
   else                      /* (probably a lot less). */
      space=f;
   result=(char*)malloc2(space+2);
   if (f>=0)
      sprintf(result,"%*ld",f,a);
   else
      sprintf(result,"%0*ld",-f,a);
   return(result);
}

double str_to_double(const char* a)
/*
 * Keywords: FS, lib, misc
 * Imports: sscanf(), fprintf()
 *
 * Like 'str_to_int' but for double floating point numbers.
 */
{
   int err;
   double result;
   int iresult;

   if (strneq(a,"0x",2))  {
      err=sscanf((char*) a+2,"%lx",&iresult); /* (cast: sscanf defined wrong) */
      result=iresult;
   }
   else if (strneq(a,"$",1))  {
      err=sscanf((char*) a+1,"%lx",&iresult);
      result=iresult;
   }
   else  {
      err=sscanf((char*) a,"%lf",&result);
   }

   if (err!=1)  { 
      printf("Warning --- bad str_to_double conversion of %s\n",a);
      return(0);
   }
   return(result);
}

const char* double_to_str(double a)
{
   return(double_to_str2(a,0,6));
}

const char* double_to_str2(double a, int f, int p)
/*
 * Keywords: FS, lib, misc
 * Imports: sprintf()
 *
 * Like 'int_to_str' but for double floating point numbers.
 * 'f' is the desired field width, 0 for no extra padding.
 * 'p' is the desired number of decimal places (e.g. 6). If 'p' is
 *     negative, g instead of f conversion format is used and abs(p)
 *     gives the number of significant figures.
 */
{
   char* result;
   int space;

   if (f+abs(p)<30)
      space=32;              /* double will not expand more than this */
   else                      /* (probably a lot less). */
      space=f+abs(p)+2;
   result=(char*)malloc2(space+2);
   if (p>=0)
      sprintf(result,"%*.*f",f,p,a);
   else
      sprintf(result,"%*.*g",f,-p,a);

   return(result);
}


ibool streq(const char* name1, const char* name2)
/* Tests two strings for equality */
{
   return(strcmp(name1,name2)==0);
}

ibool strne(const char* name1, const char* name2)
/* Tests two strings for inequality */
{
   return(strcmp(name1,name2)!=0);
}

ibool strneq(const char* name1, const char* name2, int n)
/* Tests prefixes of two strings for equality */
{
   return(strncmp(name1,name2,n)==0);
}

ibool strnne(const char* name1, const char* name2, int n)
/* Tests prefixes of two strings for inequality */
{
   return(strncmp(name1,name2,n)!=0);
}

const char* bool_to_onoff(ibool val)
{
   if (val)
      return("on");
   else
      return("off");
}

const char* bool_to_enab(ibool val)
{
   if (val)
      return("enabled");
   else
      return("disabled");
}

const char* bool_to_valid(ibool val)
{
   if (val)
      return("valid");
   else
      return("invalid");
}

const char* bool_to_yesno(ibool val)
{
   if (val)
      return("yes");
   else
      return("no");
}

ibool one_of(char a, const char* delim)
/*
 * Returns TRUE if the character 'a' is found in the list of characters
 * 'delim', FALSE otherwise. Used by nextparm().
 */
{
   int i;
   ibool result;
   
   result=FALSE;
   for (i=0; i<strlen(delim) && !result; i++)  {
      result=(a==delim[i]);
   }
   return(result);
}

int intpow(int base, int power)
/*
 * integer exponentiation ("to the power of").
 */
{
   int i;
   int result;

   result=1;
   for (i=0; i<power; i++)
      result*=base;

   return(result);
}

int intlog(int base, int arg)
/*
 * integer logarithm.
 */
{
   int result;

   result=0;
   while (arg>1)  {
      arg/=base;
      result++;
   }

   return(result);
}

void strip_trailing_spaces(char* str)
{
   int i;

   i=strlen(str);

   while (i>0 && str[i-1]==' ')
      i--;

   str[i]=(char)NULL;
}

int count_bits(unsigned int arg)
/*
 * Semi-clever bit counter. Number of iterations equals number of bits set,
 * so best for sparse (or nearly-full, negated) bit sets.
 */
{
   int result;

   result=0;
   while (arg!=0)  {
     result++;
     arg&=(arg-1);
   }

   return(result);
}

int first_bit_set(int arg)
/*
 * Returns the bit number of the first bit set in 'arg'.
 * Returns -1 if no bit is set.
 */
{
   int result;

   if (arg==0)
      return(-1);

   result=0;
   while ((arg & 1)==0)  {
      arg>>=1;
      result++;
   }

   return(result);
}

const char* chanset_to_str(int chans)
{
   int i;
   int first_chan;
   int max_chans;
   ibool need_comma;
   char* result;

   if (chans==0)
      return("none");

   max_chans=sizeof(chans)*8;

   /* get MAXSTRLEN bytes of garbage collected space */
   result=(char*)malloc2(MAXSTRLEN);
   result[0]=(char)NULL;

   first_chan=-1;
   need_comma=FALSE;

   for (i=0; i<=max_chans; i++)  {
      if (first_chan!=-1 && (i==max_chans || (chans & (1<<i))==0))  {
         if (need_comma)
            strcat(result,",");
         if (i-first_chan==1)
            strcat(result,int_to_str(first_chan,0));
         else if (i-first_chan==2)
            strcat(result,strapp(int_to_str(first_chan,0),",",
                                 int_to_str(i-1,0)));
         else
            strcat(result,strapp(int_to_str(first_chan,0),"-",
                                 int_to_str(i-1,0)));
         need_comma=TRUE;
         first_chan=-1;
      }
      if (first_chan==-1 && i<max_chans && (chans & (1<<i))!=0)  {
         first_chan=i;
      }
   }

   return(result);
}

void malloc_out_of_space(char* routine, int code)
/*
 */
{
   printf("Error: Out of malloc() free store in %s\n",routine);
   exit(code);
}

#ifdef UNIX
/* Provide replacement routines for some of the things in the DOS Borland C++
     console I/O library for Unix, using curses instead. */
int cprintf(const char* format, int arg1, int arg2, int arg3,
                                int arg4, int arg5, int arg6)
{
   int result;

   result=wprintw(stdscr,format,arg1,arg2,arg3,arg4,arg5,arg6);

   /* kludge to make important messages (starting with '*') come out
        immediately, but otherwise it wastes too much time to wrefresh()
        every time because of curses inefficient scrolling. */
   if (format[0]=='*')
      wrefresh(stdscr);

   return(result);
}

void clreol(void)
{
   wclrtoeol(stdscr);
   wrefresh(stdscr);
}

void gotoxy(int x, int y)
{
   wmove(stdscr,y-1,x-1);
   wrefresh(stdscr);
}

int wherex(void)
{
#ifdef LINUX
   return(stdscr->curx + 1);
#else
   /* SunOS 4.x and similar */
   return(stdscr->_curx + 1);
#endif
}

int wherey(void)
{
#ifdef LINUX
   return(stdscr->cury + 1);
#else
   /* SunOS 4.x and similar */
   return(stdscr->_cury + 1);
#endif
}

ibool kbhit(void)
/*
 * Checks to see if there are any characters available to be read from the
 * standard input. This is pretty Unix-system-specific so you may need to
 * take it out (it's not used for much).
 */
{
   int result;      /* Unix return value */
   char c;

#ifdef LINUX
   if (stdin->_IO_read_ptr != stdin->_IO_read_end)
#else
   /* SunOS 4.x and similar */
   if (stdin->_cnt > 0)
#endif
      return(TRUE);

   /* set stdin for non-blocking read and try to read a
        character */
   if (fcntl(0, F_SETFL, O_NDELAY) == -1)  {
      printf("kbhit(): Error from fcntl(,,O_NDELAY): %d", errno);
      return(FALSE);
   }

   result = read(0, &c, 1);     /* read one char */

   /* set stdin back to normal blocking read */
   if (fcntl(0, F_SETFL, 0) == -1)  {
      printf("kbhit(): Error from fcntl(,,0): %d", errno);
   }

   if (result == -1)  {
      /* error occurred, probably EWOULDBLOCK but our action is the same
           on any error, we return false */
      return(FALSE);
   }

   /* No error occurred, put the character we got in the unget buffer and
        return TRUE. We could use ungetc() but don't because it causes
        too many portability problems and may be unreliable. It's also
        probably much less efficient. */
   ungetc(c,stdin);

   return(TRUE);
}

#endif UNIX
