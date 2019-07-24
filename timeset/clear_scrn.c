#include <curses.h>      /* ETI curses standard I/O header file */

clear_scrn ( maindisp, num_rows )

WINDOW	* maindisp;
int	num_rows;
{
int	i;
char	blank_field[41];

strncpy ( blank_field, "                                        ", 40 );

for ( i = 0 ; i < num_rows-1 ; ++i ) {
  mvwaddstr ( maindisp, i,  0, blank_field );
  mvwaddstr ( maindisp, i, 40, blank_field );
}

}
