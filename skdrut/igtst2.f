      integer FUNCTION IGTST2(LKEYWD,IKEY)
C
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
C
C Input:
      integer*2 lkeywd(*) ! look in first 2 characters for station ID

C Output:
      integer ikey ! index number of this station in sked arrays

C 950411 nrv New. A 2-letter version of IGTST.
C 950412 nrv Check for ambiguous IDs.
C 
C     SEARCH THROUGH THE position CODES FOR A MATCH WITH
C     THE FIRST two CHARACTERs OF THE INPUT VARIABLE.
C     If there is only one character, check if it agrees or it
C     there are ambiguities.
C!     RETURN THE INDEX IN THE FUNCTION AND IN IKEY.
C     NO MATCH RETURNS 0, duplicate returns -1.

      integer*2 lc
      integer i,jchar,is,imatch
      logical kmatch

      IKEY=0
      IGTST2=0
      IF (NSTATN.LE.0) RETURN
      if (jchar(lkeywd,2).eq.oblank.or.jchar(lkeywd,2).eq.0) then ! 1-letter match
        imatch=0
        do is=1,nstatn ! check all codes for ambiguities
          lc=lpocod(is)
          call hol2upper(lc,2)
          if (jchar(lkeywd(1),1).eq.jchar(lc,1).or.
     .        jchar(lkeywd(1),1).eq.jchar(lpocod(is),1)) then
            if (imatch.eq.0) then ! first match
              imatch=is
            else ! second match
              ikey=-1
              igtst2=-1
              return
            endif
          endif
        enddo
        if (imatch.gt.0) then ! one match
          ikey=imatch
          igtst2=imatch
          return
        endif
      else ! 2-letter match
        i=1
        kmatch=.false.
        do while (i.le.nstatn.and..not.kmatch)
          lc=lpocod(i)
          call hol2upper(lc,2)
          kmatch = (lkeywd(1).eq.lc.or.lkeywd(1).eq.lpocod(i)) 
          i=i+1
        enddo
        if (kmatch) then
          IKEY=I-1
          IGTST2=I-1
        else
          return
        endif
      endif
      RETURN
      END
