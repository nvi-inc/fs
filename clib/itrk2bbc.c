
/* convert Mark 3 track number and mode to bbc number */
/* negative bbc number is for LSB, positive for USB */

int itrk2bbc(itrk,imode)
int itrk, imode;
{
   switch (imode) {
     case 1:           /* mode a */
       if (itrk>0 && itrk<15)
         return itrk;
       else if (itrk>14 && itrk<29)
         return -(itrk-14);
       else
         return 0;
     case 2:          /* mode b */
       if (itrk>0 && itrk<15)
         return itrk-1+itrk%2;
       else if (itrk>14 && itrk<29) {
         itrk-=14;
         return -(itrk-1+itrk%2);
       } else
         return 0;
     case 3:          /* mode c */
       if (itrk>0 && itrk<15)
         return itrk+itrk%2;
       else if (itrk>14 && itrk<29) {
         itrk-=14;
         return itrk-1+itrk%2;
       } else
         return 0;
     case 4:          /* mode d */
       return 1;
     default:
       return 0;
  }
}
