      Subroutine getRACK(lRACK,IKEY,cRACK)
      include '../skdrincl/skparm.ftni'
C If IKEY=0 then match lRACK with the list of racks and return IKEY.
C If IKEY!=0 then return the IKEYth rack type in cRACK.

C 990730 nrv New.

C Input and output
      integer ikey
      character*(*) cRACK

C Local
      integer i,ias2b,iflch
      integer ichcm,imn,nch
      integer nrack_names
      character*8 crack_names(5)
      data nrack_names/5/
      data crack_names/'Mark3',
     .                 'Mark3A',
     .                 'Mark4',
     .                 'VLBA',
     .                 'VLBAG',
     .                 'K4-1',
     .                 'K4-2',

      IKEY=0
      igtrack = 0
      nch = iflch(lkeywd,8)
      i=1
      do while (i.le.nracks)
        if (ichcm_ch(ckeywd,1,lrack_names(1,i),1,nch).eq.0) then ! first match
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
      igtrack = I
      RETURN
      END
