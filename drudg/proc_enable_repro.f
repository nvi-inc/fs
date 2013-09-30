      subroutine proc_enable_repro(icode,khead2active)
      include 'hardware.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'

! 2013Sep19  JMGipson made sample rate station dependent

! write out ENABLE and REPRO.
C  Remember that tracks are VLBA track numbers in itrk.

! passed
      integer icode             !current code
      logical khead2active      !2nd headstack on?

! functions
      logical kCheckGrpOr
      integer ichmv_ch          !lnfch
      integer mcoma
      integer ib2as

!local
      integer itrka,itrkb
      integer nch               !character counter.
      integer i                 ! loop counter
      integer itrkrate
      logical kgrp              !a  group of tracks
      logical kok 

      integer z8000
      data Z8000/Z'8000'/

      itrka=0
      itrkb=0

      cbuf='enable'
      nch=7
      if (krec_append) nch = ichmv_ch(ibuf,nch,crec(irec))
      NCH = ichmv_ch(IBUF,nch,'=')
      if(kvrec(irec).or.kv4rec(irec)) then ! group-only enables for VLBA recorders
        if(kCheckGrpOr(itrk,2,16,1)) then   !see if any even tracks in this range.
          itrka=6
          itrkb=8
          nch = ichmv_ch(ibuf,nch,'g0,')
        endif
        if(kCheckGrpOr(itrk,3,17,1)) then
          if (itrka.eq.0.and.itrkb.eq.0) then
            itrka=7
          endif
          itrkb=9
          nch = ichmv_ch(ibuf,nch,'g1,')
        endif
        if(kCheckGrpOr(itrk,18,32,1)) then
          if (itrka.eq.0.and.itrkb.eq.0) then
           itrka=20
          endif
          itrkb=22
          nch = ichmv_ch(ibuf,nch,'g2,')
        endif

        if(kCheckGrpOr(itrk,19,33,1)) then
          if (itrka.eq.0.and.itrkb.eq.0) then
            itrka=21
          endif
          itrkb=23
          nch = ichmv_ch(ibuf,nch,'g3,')
        endif
      else if (km3rec(irec)) then ! group enables plus leftovers
        do i=1,max_track          ! Make a copy of the track table.
          itrk2(i,1)=itrk(i,1)
        enddo
! check if group g1 is present. If so, write it out.
        call ChkGrpAndWrite(itrk2,4,16,1,'g1',kgrp,cbuf,nch)
        if(kgrp) then
          if (itrka.eq.0.and.itrkb.eq.0) then
             itrka=3 ! Mk3 track number
              itrkb=5
          endif
        endif
! ditto fo g2
        call ChkGrpAndWrite(itrk2, 5,17,1,'g2',kgrp,cbuf,nch)
        if(kgrp) then
          if (itrka.eq.0.and.itrkb.eq.0) then
            itrka=4
          endif
          itrkb=6
        endif
! ... for g3
        call ChkGrpAndWrite(itrk2, 18,30,1,'g3',kgrp,cbuf,nch)
        if(kgrp) then
          if (itrka.eq.0.and.itrkb.eq.0) then
            itrka=17
          endif
          itrkb=19
        endif

        call ChkGrpAndWrite(itrk2, 19,31,1,'g4',kgrp,cbuf,nch)
        if(kgrp) then
          if (itrka.eq.0.and.itrkb.eq.0) then
            itrka=18
          endif
          itrkb=20
        endif
C         Then list any  tracks still left in the table.
         do i=4,31 ! pick up leftover Mk3 tracks not in a whole group
           if (itrk2(i,1).eq.1) then ! Mark3 numbering
             nch = nch + ib2as(i-3,ibuf,nch,Z8000+2)
             nch = MCOMA(IBUF,nch)
           endif
         enddo ! pick up leftover tracks
      else if (KM4rec(irec) .or. KM5disk) then
        kok=.false.
        do i=2,33 ! if any tracks are on, enable the stack
          if (itrk(i,1).eq.1) then
            kok=.true.
            if (itrka.ne.0.and.itrkb.eq.0) itrkb=i
            if (itrka.eq.0) itrka=i
          endif
        enddo
        nch = ichmv_ch(ibuf,nch,'s1,')
c.....2-head
        kok=.false.
        if(khead2active) then
          do i=2,33 ! if any tracks are on, enable the stack
            if (itrk(i,2).eq.1) then
              kok=.true.
            endif
          enddo
          if(kok)then
            nch = ichmv_ch(ibuf,nch,'s2,')
          endif
        endif
c... end 2-head
      endif
      write(lu_outfile,'(a)') cbuf(1:nch-2)  !write out, omitting terminal comma.

C REPRO=byp,itrka,itrkb,equalizer,bitrate   Mk3/4
C REPRO=byp,itrka,itrkb,equalizer,,,bitrate   VLBA,VLBA4
      cbuf="repro"
      nch=6
      if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
      nch = ichmv_ch(IBUF,nch,'=byp,')
      nch = nch+ib2as(itrka,ibuf,nch,Z8000+2)
      nch = MCOMA(IBUF,nch)
      nch = nch+ib2as(itrkb,ibuf,nch,Z8000+2)
      if (km4rec(irec).or.kv4rec(irec).or.kvrec(irec)) then ! bitrate
        if (ifan(istn,icode).gt.0) then
          itrkrate = samprate(istn,icode)/ifan(istn,icode)
        else
          itrkrate = samprate(istn,icode)
        endif
        if (itrkrate.ne.4) then
          nch = MCOMA(IBUF,nch)
          nch = MCOMA(IBUF,nch)
          if (kv4rec(irec).or.kvrec(irec)) then ! 7th parameter
            nch = MCOMA(IBUF,nch)
            nch = MCOMA(IBUF,nch)
          endif
          nch = nch+ib2as(itrkrate,ibuf,nch,Z8000+2)
        endif
      endif ! add bitrate
      write(lu_outfile,'(a)') cbuf(1:nch)
      return
      end


