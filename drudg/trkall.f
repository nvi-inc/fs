      subroutine trkall(itras,lmode,itrk,lm,nm,lfan)

C  TRKALL returns the complete list of tracks to be
C  recorded, given the mode and list of tracks assigned
C  in the schedule file. It looks at the mode name to
C  determine whether there is fan-in or fan-out and adds
C  or subtracts tracks appropriately.
C  Also outputs a 3-character mode for the procedure names,
C        in the form "Vxy" where x and y are the fan factors,
C        If fan factor is unity, the mode is simply "V".
C        For Mark III modes, the name is the one-letter mode.
C  Restrictions: 
C  1. Fan in/out may be 1:2, 2:1, 4:1 or 1:4 only.
C  2. Colon (":") must appear in the mode name,
C     and the two digits in either side are the factors used.
C  3. VLBA modes must begin with "V".
C  4. Track assignments in "itras" are converted to VLBA 
C     track numbers when they are returned in "itrk".
C                 
C History
C 951214 nrv New.
C
C Called by: PROCS

      INCLUDE 'skparm.ftni'
C
C  INPUT:
      integer itras(2,2,max_chan)
C             Mark III # track assignments from schedule
      integer*2 lmode ! mode from schedule
C
C  OUTPUT:
      integer itrk(36) ! tracks to be recorded/enabled
C           VLBA track # assignments
      integer*2 lm(2) ! 3-character mode for procedure names
      integer nm ! number of characters in lm, 1 or 3
      integer*2 lfan(2) ! 3-character fan designation, x:y
C
C  LOCAL:
      integer idum,it,i,n,ix,iy,ibit,ichan,isb
      integer ichcm_ch,ib2as,ichmv,ichmv_ch,iscn_ch,ias2b
C
C
      do i=1,36
        itrk(i)=0
      enddo
      call ifill(lfan,1,4,oblank)

      do isb=1,2 ! u/l
        do ibit=1,2 ! s/m
          do ichan=1,max_chan ! channels
            it = itras(isb,ibit,ichan)
            if (it.ne.-99) itrk(it+3)=1
          enddo ! channels
        enddo ! s/m
      enddo ! u/l
      call ifill(lm,1,4,oblank)
      idum = ichmv(lm,1,lmode,1,1)
      nm = 1
C
C     If this is a non-VLBA mode, just return now.
      if (ichcm_ch(lm,1,'V').ne.0) return

C 2. Now check for fan-out and add the appropriate tracks. 

      ix = iscn_ch(lmode,1,8,'1:') 
      if (ix.ne.0) then ! fan-out
        n=ias2b(lmode,ix+2,1)
        if (n.eq.1.or.n.eq.2.or.n.eq.4) then ! valid fan
          idum = ichmv_ch(lm,1,'V1  ')
          idum = ib2as(n,lm,3,1)
          call ifill(lfan,1,4,oblank)
          idum = ichmv(lfan,1,lmode,ix,3)
          if (n.gt.1) then ! add fanout tracks
            do i=1,36
              if (itrk(i).eq.1) then ! assigned
                if (n.eq.2) itrk(it+2)=1
                if (n.eq.4) then
                  itrk(it+2)=1
                  itrk(it+4)=1
                  itrk(it+6)=1
                endif
              endif ! assigned
            enddo
          endif ! add fanout tracks
        endif ! valid fan
      endif

C 3. Fan-in mode. Not implemented.

      iy = iscn_ch(lmode,1,8,':1') 
      if (iy.ne.0) then ! fan-in
        n=ias2b(lmode,iy-1,1)
        if (n.eq.1.or.n.eq.2.or.n.eq.4) then ! valid fan
          idum = ichmv_ch(lm,1,'V 1 ')
          idum = ib2as(n,lm,2,1)
          call ifill(lfan,1,4,oblank)
          idum = ichmv(lfan,1,lmode,iy-1,3)
        endif
C       No fan-in track handling at this time
      endif
C
      RETURN
      END
