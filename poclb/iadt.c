/* iadt

   Add an increment to the standard rte time array
   Copied from FORTRAN.
*/

static int itm[5]={100,60,60,24,365};
/* itm holds the maximum for each unit of time */

void iadt(it,idt,ires)
int it[6];     /* standard rte time array   */
int idt;       /* the increment to be added */
int ires;      /* resolution of idt, i.e. which unit of time applies */

{
  int i,iix,itx;  

  itm[4] = 365;
  if (it[5]%4 == 0)
    itm[4]=366;

  iix = idt;

  for (i=ires-1; i<=4; i++) {
    it[i]=it[i]+iix;           /* increment */
    if (it[i] >= itm[i]) {     /* this unit has overflowed */
      itx=it[i]%itm[i];        /* get the remainder for this unit */
      iix=it[i]/itm[i];        /* get the carry to the next higher unit */
      it[i]=itx;               /* set current units to the remainder */ 
    }
    else
      return;
  }
  it[5]=it[5]+1;  /* If we got here, all units have overflowed, up to the
                     number of days in a year. Assume we haven't overflowed
                     more than one year! */ 
}
