      integer FUNCTION IGTSO(LKEYWD,IKEY)
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/sourc.ftni'
C     CHECK THROUGH LIST OF SOURCES FOR A MATCH WITH LKEYWD
C     RETURN INDEX IN IKEY AND IN FUNCTION IF MATCH, ELSE 0
C     ALSO MAY HAVE A SOURCE INDEX NUMBER ALLOWED.
C 970114 nrv Change 4 to max_sorlen/2
C 970406 nrv Minimum matching

      integer*2 LKEYWD(*)
      integer ikey,i,ias2b,iflch
      integer ichcm,im1,imn,im2,nch

      IKEY=0
      IGTSO = 0
      IF (NSOURC.LE.0) RETURN
      nch = iflch(lkeywd,max_sorlen)
      im1=0
      im2=0
      i=1
      do while (i.le.nsourc.and.im1.eq.0)
        if (ichcm(lkeywd,1,lsorna(1,i),1,nch).eq.0) then ! first match
          im1=i
        endif ! first match
        i=i+1
      enddo

      if (im1.gt.0) then ! try for a second
        i=1
        do while (i.le.nsourc.and.im2.eq.0)
          if (i.ne.im1) then
            if (ichcm(lkeywd,1,lsorna(1,i),1,nch).eq.0) then ! second match
              im2=i
            endif ! second match
          endif
          i=i+1
        enddo
      endif ! try for a second

C   Even if there is a match, check out the number too.
      imn=0
      I = IAS2B(LKEYWD,1,IFLCH(LKEYWD,max_sorlen))
      IF (I.GT.0.AND.I.LE.NSOURC) imn=i

      if (imn.eq.0) then ! not a number
        i=im1 ! first match is ok
        if (im2.gt.0) i=-1
      else ! use the number
        i=imn
      endif
      IKEY=I
      IGTSO = I
      RETURN
      END
