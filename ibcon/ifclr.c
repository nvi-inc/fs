/* 
 * this command is issued if the interface has a handshaking problem.
 * the board will be put back on line, and the interface clear signal
 * will be issued. The next hpib access should complete successfully
 *
 * HISTORY
 * 	DMV  941213	inital version of reset code
*/

#ifdef CONFIG_GPIB
#include <ib.h>
#include <ibP.h>
#endif

#define	IBCODE		300

extern int ID_hpib;

void ifclr_(error,ipcode)

int *error;
long *ipcode;

{
	*error = 0;
	*ipcode = 0;
/*
	ibonl(ID_hpib,1);
	if ((ibsta & (ERR|TIMO)) != 0)
	{
	  *error = -(IBCODE + iberr);
	  memcpy((char *)ipcode,"IO",2);
	  return;
	}
	ibsic(ID_hpib); 
	if ((ibsta & (ERR|TIMO)) != 0)
	{
	  *error = -(IBCODE + iberr);
	  memcpy((char *)ipcode,"IS",2);
	  return;
	}
*/
}

