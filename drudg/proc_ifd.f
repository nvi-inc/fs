      subroutine proc_ifd(cname_ifd,icode,kpcal,fvc,fvc_lo,fvc_hi)
! write out IFD procedure
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
! passed
      character*12 cname_ifd   !name of procedure.
      integer icode     ! Code
      logical kpcal     ! do pcal 
      real fvc(*)       ! video convertor frequencies
      real fvc_lo(*)    ! lower bandpass
      real fvc_hi(*)    ! Upper bandpass

! functions
      integer ichmv_ch  !lnfch
      integer ib2as
      integer ir2as
      integer mcoma
      integer ichmv

C    for VLBA:  IFDAB=0,0,nor,nor
C               IFDCD=0,0,nor,nor
C    for Mk3:   ifd=atn1,atn2,nor/alt,nor/alt
C               ifd=,,nor/alt,nor/alt <<<<<< as of 010207 default atn is null
C               if3=atn3,out,1,1 (out for narrow)
C               if3=atn3,in,2,2 (in for WB)
C               if3=,out,1,1 <<<<<<<< as of 010207 default atn is null
C               if3=,in,1or2=LorHforVC3,1or2=LorHforVC10
C               if3=,out,1or2,1or2
C               patch=lo1,...
C               patch=lo2,...
C               patch=lo3,...
C    for K4-2:  patch=lo1,a1,a2,...
C               patch=lo2,b1,b2,...
C               lo=same as Mk3
C    for K4-1:  patch=lo1,1-4,5-8,etc.
C    for LBA:   lo=same as Mk3 ( but allow up to 4 IFs)
C Later: add a check of patching to determine how the IF3 switches
C should really be set. 
C         if (VC3  is LOW) switch 1 = 1, else 2
C         if (VC11 is LOW) switch 2 = 1, else 2



! local
      integer ifd(4)            !ifd(j)<>0 indicates we have IF
      character*4 lvalid_if     !Valid IF characters
      integer ivc3_patch        !VC3,VC10 patch hi or lo?
      integer ivc10_patch
      integer itemp
      integer ib                !ibbc#
      integer ic                !channel index
      integer iv                !channel#
      integer ilo               !LO index
      integer j                 !loop index
      character*12 cnamep       !Name of procedure.
      integer nch               !character counter
      integer ix
      real    fr                !freuqeuency
      real    rpc               !PhaseCal frequency, spacing
      integer igig

! Initialize IFDs to not used.
      do j=1,4
       ifd(j)=0
      end do
     
      if(kbbc) then
        lvalid_if="ABCD"
      else 
        lvalid_if="1234"
      endif

      do ic=1,nchan(istn,icode) ! which IFs are in use
        iv=invcx(ic,istn,icode) ! channel number
        if(freqrf(iv,istn,icode) .gt. 0) then
          j=index(lvalid_if,cifinp(iv,istn,icode)(1:1))
          if(j .ge. 1) then
            if(ifd(j) .eq. 0) ifd(j)=iv
          endif
        endif
      enddo ! which IFs are in use

      call proc_write_define(lu_outfile,luscn,cname_ifd)

      if (kvc .or. kifp) then
C                    m3rack IFD, LO, PATCH, SIDEBAND
C                    k4rack LO, PATCH
C                    lrack LO
C       First find out which IFs are in use for this code
C IFD command
        if(kmracks) then ! mk3/4/5 IFD
          cbuf="ifd=,"
          nch=6
          do j=1,2
            if (ifd(j).ne.0) then ! IF is in use
              IF (cifinp(ifd(j),istn,ICODE)(2:2).eq. 'N') then
                cbuf(nch:nch+4)=",nor"
              ELSE ! must be 'A'
                cbuf(nch:nch+4)=",alt"
              ENDIF
              nch=nch+4
            else
              cbuf(nch:nch)=","
              nch=nch+1
              if(j .eq. 2) cbuf(nch:nch)=","   !add extra "," for backward compatibility.
            endif
          end do
          write(lu_outfile,'(a)') cbuf(1:nch)

C  First determine the patching for VC3 and VC10.
          ivc3_patch =2       !default values
          ivc10_patch=2
          DO ic = 1,nchan(istn,icode)
            iv=invcx(ic,istn,icode) ! channel number
            ib=ibbcx(iv,istn,icode) ! VC number
!                if (ib.eq.3.and.fvc(ib).gt.210.0) vc3_patch=2
!                if (ib.eq.10.and.fvc(ib).gt.210.0) vc10_patch=2
            itemp=1
            if(ib .eq. 3 .or.ib .eq. 10) then
              if(kgeo) then
                if(fvc_hi(ib) .lt. 230.0) then
!                 itemp=1
                else if(fvc_lo(ib) .gt. 210.0) then
                  itemp=2
                else if((fvc_lo(ib)+fvc_hi(ib))/2. .lt. 220.0) then
!                  itemp=1
                else
                  itemp=2
                endif
              else
                if(fvc(ib).gt.210.0) itemp=2
              endif
              if(ib .eq. 3) then
                ivc3_patch=itemp
              else
                ivc10_patch=itemp
              endif
            endif
          enddo
          if(ifd(3).ne.0) then ! IF3 exists, write the command
            cbuf="if3=,in,"    !default case.
            nch=9
! check " if3=,out" possibility. Different for VEX and non-vex.
            if(kvex.and.cifinp(ifd(3),istn,ICODE)(2:2).eq. 'O' .or.
     >            .not.kvex .and. ifd(1).ne.0 .and.
     >          freqlo(ifd(3),istn,icode).eq.
     >          freqlo(ifd(1),istn,icode))then
                cbuf="if3=,out,"
                nch=10
            endif
            nch = nch+ib2as(ivc3_patch,ibuf,nch,1)
            NCH = MCOMA(IBUF,NCH)
            nch = nch+ib2as(ivc10_patch,ibuf,nch,1)
C              Add phase cal on/off info as 7th parameter.
            if (kpcal) then ! on
              nch=ichmv_ch(ibuf,nch,',,,on')
            else ! off
              nch=ichmv_ch(ibuf,nch,',,,off')
            endif ! value/off
            write(lu_outfile,'(a)') cbuf(1:nch)
          endif ! we know/don't know about IF3
        endif ! mk3/4 IFD
C
C LO command for Mk3/4 and K4 and LBA
C           First reset all
        if(kifp .or. kvc)  write(lu_outfile,'(a)') "lo="

        do ilo=1,4 ! up to 4 LOs
          cbuf="lo=lo"
          nch=6
          ix=ifd(ilo)
          if (ix.gt.0) then ! this LO in use
            NCH = NCH + IB2AS(Ilo,IBUF,NCH,1) ! LO number
            NCH = MCOMA(IBUF,NCH)
            fr=freqlo(ix,istn,icode)
            if (freqlo(ix,istn,icode).gt.100000.d0) then
                igig=freqlo(ix,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(ix,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2) ! LO frequency
              NCH = MCOMA(IBUF,NCH)
              nch=ichmv(ibuf,nch,losb(ix,istn,icode),1,1)
              nch=ichmv_ch(ibuf,nch,'sb,')
              if (kvex) then ! have pol and pcal
                nch=ichmv(ibuf,nch,lpol(ix,istn,icode),1,1) ! polarization
                nch=ichmv_ch(ibuf,nch,'cp,')
                rpc = freqpcal(ix,istn,icode) ! pcal spacing
                if (rpc.gt.0.0) then ! value
                  nch=nch+ir2as(rpc,ibuf,nch,5,3)
                else ! off
                  nch=ichmv_ch(ibuf,nch,'off')
                endif ! value/off
                rpc = freqpcal_base(ix,istn,icode) ! pcal offset
                if (rpc.gt.0.0) then
                  NCH = MCOMA(IBUF,NCH)
                  nch=nch+ir2as(rpc,ibuf,nch,5,3)
                endif
              else if(kgeo) then
! JMG 2002Dec30:   Add ,rcp,1 for geodetic schedules.
                 nch=ichmv_ch(ibuf,nch,"rcp,1")
! End JMG 2002Dec30
              endif ! have pol and pcal
              call lowercase_and_write(lu_outfile,cbuf)
            endif ! this LO in use
          enddo ! up to 4 LOs
        endif
C
C PATCH command for Mk3/4 and K4
C           First reset all
          if (kvc) then
            call proc_patch(icode,ifd,fvc_lo,fvc_hi)
          endif ! m3rack IFD, LO, PATCH commands

        if (kbbc) then ! vlba IFD, LO commands
C IFDAB, IFDCD commands
          if(ifd(1)+ifd(2) .ne. 0)
     >        write(lu_outfile,'(a)') 'ifdab=0,0,nor,nor'
          if(ifd(3)+ifd(4) .ne. 0)
     >       write(lu_outfile,'(a)')  'ifdcd=0,0,nor,nor'

C LO command for VLBA
          write(lu_outfile,'(a)') 'lo='
          do ilo=1,4
            cbuf="lo=lo"
            nch=6
            ix=ifd(ilo)
            if (ix.gt.0) then ! this LO in use
              NCH = ichmv_ch(ibuf,nch,char(ichar('a')+ilo-1)) ! LO name
              NCH = MCOMA(IBUF,NCH)
              fr=freqlo(ix,istn,icode)
              if (freqlo(ix,istn,icode).gt.100000.d0) then
                igig=freqlo(ix,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(ix,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2) ! LO frequency
              NCH = MCOMA(IBUF,NCH)
              nch=ichmv(ibuf,nch,losb(ix,istn,icode),1,1)

              nch=ichmv_ch(ibuf,nch,'sb,')
              if (kvex) then ! have pol and pcal
                nch=ichmv(ibuf,nch,lpol(ix,istn,icode),1,1) ! polarization
                nch=ichmv_ch(ibuf,nch,'cp,')
                rpc = freqpcal(ix,istn,icode) ! pcal spacing
                if (rpc.gt.0.0) then ! value
                  nch=nch+ir2as(rpc,ibuf,nch,5,3)
                else ! off
                  nch=ichmv_ch(ibuf,nch,'off')
                endif ! value/off
                rpc = freqpcal_base(ix,istn,icode) ! pcal offset
                if (rpc.gt.0.0) then
                  NCH = MCOMA(IBUF,NCH)
                  nch=nch+ir2as(rpc,ibuf,nch,5,3)
                endif
              else if(kgeo) then
                nch=ichmv_ch(ibuf,nch,"rcp,1")
              endif ! have pol and pcal
              call lowercase_and_write(lu_outfile,cbuf)
            endif ! this LO in use
          enddo
        endif ! vlba IFD, LO commands
        write(lu_outfile,"(a)") 'enddef'
        return
        end

