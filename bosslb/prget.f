      subroutine prget(istack,ientry,nwords,ierr)
C 
C     PRGET - gets words from push-down stack 
C 
C 
C     INPUT 
C 
      dimension istack(1) 
C       Stack with procedure names and record numbers 
C     NWORDS - number of words to get 
C 
C 
C  OUTPUT:
C 
      dimension ientry(1) 
C       Entry retrieved from stack
C     IERR - error return 
C 
C 
C  LOCAL: 
C 
C     INDEX - index in stack array
C 
C 
C  INITIALIZED: 
C 
C 
C  PROGRAMMER: NRV
C  LAST MODIFIED:  CREATED 790912 
C# LAST COMPC'ED  870115:04:22 #
C 
C 
C     1. First make sure there is something in the stack to get.
C 
      if (istack(2).gt.2) goto 200
      ierr = -1 
      goto 900
C 
C 
C     2. Now get each word, in reverse order.  NOTE: the stack is 
C     NOT modified, we are merely retrieving information. 
C 
200   index1 = istack(2)
      do 210 i=1,nwords 
        index = index1
        ientry(nwords-i+1) = istack(index)
        index1 = index-1
210     continue
      ierr = 0
C 
900   return
      end 
