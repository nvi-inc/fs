      logical function krcur(istack,index)
C 
C     KRCUR checks a stack for the presence of INDEX
C     It returns TRUE if INDEX is already in the stack. 
C 
C  INPUT: 
C 
C     ISTACK - stack to be checked
C     INDEX - the index to check for
      dimension istack(1) 
C 
C  OUTPUT:
C 
C     KRCUR - TRUE if INDEX is found in ISTACK
C 
C  LOCAL: 
C 
d     data lu/16/ 
C 
C     1. Initialize the return to TRUE.  If we find INDEX in
C     the stacks, then return immediately.
C     Stacks have pointers in words 6,10,etc. 
C 
      krcur = .true.
      if (istack(2).eq.2) goto 400
C                     If stack is empty, we're done 
      do 210 i=6,istack(2),4
        if (index.eq.istack(i)) goto 900
210     continue
C 
C     4. If we got here, then nothing was found in the stacks.
C 
400   krcur = .false. 
C 
900   continue
      return
      end 
