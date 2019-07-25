      logical function kstak(istkop,istksk,nlist) 
C 
C     KSTAK checks the two stacks for procedures which are from 
C     the requested list. 
C     It returns TRUE if there are any of these procs present.
C 
C  INPUT: 
C 
C     ISTKOP,ISTKSK - stacks to be checked
C     NLIST - 1=check for list 1, 2=check for list 2
      dimension istksk(1),istkop(1) 
C 
C  OUTPUT:
C 
C     KSTAK - TRUE if any procs from NLIST are found in either stack
C 
C  LOCAL: 
C 
c     data lu/16/ 
C 
C     1. Initialize the return to TRUE.  If we find anything in 
C     the stacks which is in the list, then return immediately. 
C 
      kstak = .true.
C 
C 
C     2. First check the operator stack.
C     Stacks have pointers in words 6,10,etc. 
C 
      if (istkop(2).eq.2) goto 300
C                     If stack is empty, try the next one 
      do 210 i=6,istkop(2),4
        if (nlist.eq.1.and.istkop(i).gt.0) goto 900 
        if (nlist.eq.2.and.istkop(i).lt.0) goto 900 
210     continue
C 
C 
C     3. Now check the schedule stack.
C 
300   if (istksk(2).eq.2) goto 400
      do 310 i=6,istksk(2),4
        if (nlist.eq.1.and.istksk(i).gt.0) goto 900 
        if (nlist.eq.2.and.istksk(i).lt.0) goto 900 
310     continue
C 
C 
C     4. If we got here, then nothing was found in the stacks.
C 
400   kstak = .false. 
C 
C 
900   continue
      return
      end 
