        SUBROUTINE PROCS(iin)

C PROCS writes procedure file for the Field System.
C Version 9.0 is supported with this routine.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
C
C History
C 930714  nrv  created,copied from procs
C 940308  nrv  Added a check for "NW" to make the correct BBC
C              IF input 
C 940620  nrv  In batch mode, always 'Y' for purging existing.
C 951213 nrv Modifications for new FS and new Mk4/VLBA setups.
C 960124 nrv Modifications for VLBA fan-out modes
c 960129 nrv change "d0" to "v0" and remove the fan-outs from
C            the trackform command
C 960208 nrv Use invcx to get channel number to enter VC arrays
C 960219 nrv Change TAPEFORM procedure name to include freq code,
C            change procedure name to TAPEFRM to stay below 12 letters.
C 960223 nrv Call chmod to change permissions.
C 960305 nrv Add "code" to TRKFRM procedure names.
C 960709 nrv Use "samprate" instead of "vcband*2".
C            Use "lbarrel" from freqs.ftni instead of from parameters
C 960811 nrv Add S2 options
C 960904 nrv Modify LOADER procedures. Change S2_RECORD_MODE to REC_MODE.
C 960911 nrv Change EJECT to REC=EJECT, add group to rec_mode in UNLOADER.
C            Modify LOADER procedure for S2.
C 960912 nrv Add roll to REC_MODE only if defined.
C 960912 nrv If the rack and recorder types are known, use them
C 960913 nrv Handle no-rack case by testing for either VLBA rack or
C            Mk3 rack for all commands. Change test for recorder from
C            .not.ks2rec to kvrec.or.km3rec
C 961018 nrv Add M4 rack and M4 rec. 
C 961018 nrv When writing BBC commands, loop on the number of channels 
C            but skip over any LSB channels because assume that these 
C            will be duplicates of the USB.
C 961020 nrv Mark4 ENABLE command. 
C 961018 nrv Change REPRO command to pick up tracks from enabled tracks list.
C 961022 nrv Change MARK to Mark in rack/rec type names.
C 961022 nrv Add Mark IV as a procedures option
C 961024 nrv No FORM=RESET for Mk4. 
C 961030 nrv Add subpass index to Mk3 mode for Mk4 formatter.
C 961031 nrv Use LMFMT for non-Mk3 modes in FORM= command.
C 961101 nrv Don't make procedures for modes undefined at this station.
C 961101 nrv Use channel indirect indexing for patching command, and patch
C            only BBCs not channels.
C 961105 nrv Put commas in LO command for LO values not defined.
C 961105 nrv Don't write out fan if it's 1:1 and there is no roll.
C 961105 nrv Make mode E FORM command for Mk4 indicate group number.
C 961129 nrv For VLBA procedures, change IFs from Mk3 to VLBA names:
C            1N --> A
C            1A --> B
C            2N --> C
C            2A --> D
C 961129 nrv Add iin=5 for 8-BBC procedures
C 961129 nrv Write out procedures across on a line, instead of one line per.
C 961202 nrv No special handling for 8-BBCs for modes A or C.
C            Use "mx" groups for tracks instead of listing them all.
C            Edit trackform section to use indices instead of max_chan.
C 961102 nrv Remove the IF translation.
C 970108 nrv For Mk4 rack, if VCbw=1 or 0.25, set to "0" for external.
C 970113 nrv Add !+10s in S2 LOADER procedure.
C 970113 nrv No FORM= command at all for S2, nor !*.
C 970113 nrv Automatically reverse LSB<-->USB in TRACKFORM command
C            for LSB LO setup. Using following table:
C            VEX statement:    chan_def   IF_def    TRACKFORM
C            .drg, .skd info:  always U    losb
C            skdr variable:    lnetsb      losb
C                                 U         U          U
C                                 U         L          L (reversed)
C                                 L         U          L
C                                 L         L          U (reversed)
C            klsblo = rf < LO 
C            If (klsblo) then reverse the sideband in TRACKFORM command
C 970113 nrv Allow first-8 BBCs or last-8 BBCs for mode A.
C 970117 nrv Don't write IF3 commands unless there is an IF3 in the schedule.
C 970117 nrv Add patch command for IF3
C 970119 nrv Extend LSB support to use "m" mode when necessary, so that
C            trackform commands are written.
C 970119 nrv If we have a VEX file as input, then the IF3 command can
C            be safely omitted if it does not appear. Otherwise, write
C            out IF3 for all Mk3 and Mk4 racks.
C 970123 nrv Fix wrong 0.5 for VC filter check, change to 0.25.
C 970124 nrv Set KLSBLO initially if RF<LO for ANY channel, then 
C            check KLSBLO for EACH channel in TRACKFORM command
C 970206 nrv Add headstack index=1 to itras, ihdpos,ihddir, itrk,itrax
C 970210 nrv Add bit_density back to setup procedures.
C 970224 nrv bit_density is only for VLBA racks, not Mk4
C 970225 nrv Add call to PROCINTR
C 970313 nrv Allow barrel roll only for VLBA racks.
C 970416 nrv Do only 1 command for each BBC, check if it's done yet, and
C            remove the check for USB only!
C 970520 nrv Clean up procs section
C 970609 nrv Add true VC bandwidth in parentheses for cases of missing
C            filters.
C 970610 nrv Set VC/BBC value to invalid -1.0 if LO is missing.
C 970718 nrv If LO frequency > 100 GHz, insert the initial digit into the
C            LO command, then format the remainder
C 970729 nrv Make FREQLO into double precision, convert to single before
C            formatting.

C Input
      integer iin ! 1=mk3, 2=VLBA, 3=hybrid Mk3 rack+VLBA rec, 4=S2, 5=8 BBCs

C Called by: FDRUDG
C Calls: TRKALL,IADDTR

C LOCAL VARIABLES:
      integer*2 IBUF2(40) ! secondary buffer for writing files
      integer*2 lpmode(2) ! mode for procedure names
      integer*2 linp(max_chan) ! IF input local variable
      LOGICAL KUS ! true if our station is listed for a procedure
      integer itrax(2,2,max_headstack,max_chan) ! fanned-out version of itras
      integer IC,ierr,i,idummy,nch,ipass,icode,it,iv,
     .ilen,ich,ic1,ic2,ibuflen,itrk(max_track,max_headstack),
     .ig,ig0,ig1,ig2,ig3,
     .im0,im1,im2,im3,igotbbc(max_bbc),
     .npmode,itrk2(max_track),
     .isbx,isb,ibit,ichan,ib,itrka,itrkb,nprocs
      logical kok,km3mode,km3be,km3a
      logical kvrack,kvrec,km3rack,km3rec,ks2rec,km4rack,km4rec,k8bbc,
     .kinclude,klast8,kfirst8,klsblo,knolo
      real spdips
        CHARACTER UPPER
        CHARACTER*4 STAT
        CHARACTER*4 RESPONSE
        integer*2 LNAMEP(6)
        logical ex
        logical kdone
      double precision DRF,DLO,DFVC
      real fvc(14),fr,rfvc  !VC frequencies
      integer Z8000,Z4000,Z100
      integer igig,i1,i2,i3,i4,nco
      integer ir2as,ib2as,mcoma,trimlen,jchar,ichmv ! functions
      integer iflch,ichcm_ch,ichmv_ch,iaddtr
      character*28 cpass,cvpass
      character*1 cp ! selection from cpass or cvpass
C
C INITIALIZED VARIABLES:
        data ibuflen/80/
      data Z4000/Z'4000'/,Z100/Z'100'/,Z8000/Z'8000'/
      data cpass  /'123456789ABCDEFGHIJKLMNOPQRS'/
      data cvpass /'abcdefghijklmnopqrstuvwxyzAB'/
C
C  1. Create the file. Initialize

      if (kmissing) then
        write(luscn,9101)
9101    format(' PROCS00 - Missing or inconsistent head/track/pass',
     .  ' information.'/' Your procedures may be incorrect, or ',
     .  ' may cause a program abort.')
      endif
C   For VEX files the rack and recorder info is taken from the schedule. 
C   For non-VEX, the user specifies the type of procedures desired and 
C   by implication thus specifies the type of equipment at the station. 
C   For S2, since this must be a VEX file, we will rely on the schedule 
C   for the rack type.
      km3rack=.false.
      km4rack=.false.
      kvrack=.false.
      km3rec=.false.
      km4rec=.false.
      kvrec=.false.
      ks2rec=.false.
      k8bbc=.false.
C     if (ichcm_ch(lstrack(1,istn),1,'unknown ').ne.0.and.
C    .    ichcm_ch(lstrec (1,istn),1,'unknown ').ne.0) then 
      if (kvex) then  ! this came from the VEX file
        ks2rec=   ichcm_ch(lstrec(1,istn),1,'S2').eq.0
        kvrec=    ichcm_ch(lstrec(1,istn),1,'VLBA').eq.0
        km3rec=   ichcm_ch(lstrec(1,istn),1,'Mark3').eq.0
        km4rec  = ichcm_ch(lstrec(1,istn),1,'Mark4').eq.0 
        kvrack =  ichcm_ch(lstrack(1,istn),1,'VLBA').eq.0 
     .       .or. ichcm_ch(lstrack(1,istn),1,'VLBAG').eq.0 
        km3rack = ichcm_ch(lstrack(1,istn),1,'Mark3').eq.0 
        km4rack = ichcm_ch(lstrack(1,istn),1,'Mark4').eq.0 
      else ! take user input
        if (iin.eq.1) then ! Mark III backend
          km3rack=.true.
          km3rec=.true.
        else if (iin.eq.2) then ! VLBA backend
          kvrack=.true.
          kvrec=.true.
        else if (iin.eq.3) then ! Mk3 rack, VLBA recorder
          km3rack=.true.
          kvrec=.true.
        else if (iin.eq.4) then ! Mk4 backend
          km4rack=.true.
          km4rec=.true.
          do i=1,ncodes
            idummy=ichmv_ch(lmfmt(1,istn,i),1,'M') ! only Mk3/4 format
          enddo
        else if (iin.eq.5) then ! VLBA rack, only 8 BBCs
          kvrack=.true.
          kvrec=.true.
          k8bbc=.true.
        endif
      endif

      WRITE(LUSCN,9111)  (LSTNNA(I,ISTN),I=1,4)
9111  format('Procedures for ',4a2)
      stat='new'
      ic = trimlen(prcname)
C
      inquire(file=prcname,exist=ex,iostat=ierr)
      if (ex) then
        if (kbatch) then
          response = 'Y'
        else
          kdone = .false.
          do while (.not.kdone)
            write(luscn,9130) prcname(1:ic)
9130        format(' OK to purge existing file ',A,' (Y/N) ? ',$)
            read(luusr,'(A)') response
            response(1:1) = upper(response(1:1))
            if (response(1:1).eq.'N') then
              return
            else if (response(1:1).eq.'Y') then
              kdone = .true.
            end if
          end do
        endif
        open(lu_outfile,file=prcname)
        close(lu_outfile,status='delete')
      end if
C
      WRITE(LUSCN,9113) PRCNAME(1:IC), (LSTNNA(I,ISTN),I=1,4)
9113  FORMAT(' PROCEDURE LIBRARY FILE ',A,' FOR ',4A2)
      write(luscn,9114) 
9114  format(' **NOTE** These procedures are for stations using '/
     .' the following equipment:')
      if (km3rack) write(luscn,'("   >> Mark III rack")')
      if (km4rack) write(luscn,'("   >> Mark IV rack")')
      if (kvrack)  write(luscn,'("   >> VLBA rack")')
      if (km3rec)  write(luscn,'("   >> Mark III recorder")')
      if (km4rec)  write(luscn,'("   >> Mark IV recorder")')
      if (kvrec)   write(luscn,'("   >> VLBA recorder")')
      if (ks2rec)  write(luscn,'("   >> S2 recorder")')

      open(unit=LU_OUTFILE,file=PRCNAME,status=stat,iostat=IERR)
      IF (IERR.eq.0) THEN
        call initf(LU_OUTFILE,IERR)
        rewind(LU_OUTFILE)
      ELSE
        WRITE(LUSCN,9131) IERR,PRCNAME(1:IC)
9131    FORMAT(' PROCS02 - Error ',I6,' creating file ',A)
        return
      END IF
      call procintr
C
C 2. Set up the loop over all frequency codes, and the
C    inner loop over the number of passes.
C    Generate the procedure name, then write into proc file.
C    Get the track assignments first, and the mode name to use
C    for procedure names.

      DO ICODE=1,NCODES !loop on codes
        if (nchan(istn,icode).gt.0) then ! this mode defined
        nprocs=0
        nco=2
        IF (JCHAR(LCODE(ICODE),2).EQ.oblank) nco=1

        DO IPASS=1,NPASSF(istn,ICODE) !loop on number of sub passes
          CALL IFILL(LNAMEP,1,12,oblank)
          if (ks2rec) then
            nch = ichmv_ch(lnamep,1,'SETUP')
            nch = ICHMV(LNAMEP,nch,LCODE(ICODE),1,nco)   ! ff
          else
            call trkall(itras(1,1,1,1,ipass,istn,icode),
     .      lmode(1,istn,icode),
     .      itrk,lpmode,npmode,ifan(istn,icode),itrax)
            km3mode=jchar(lpmode,1).eq.ocapa
     .          .or.jchar(lpmode,1).eq.ocapb
     .          .or.jchar(lpmode,1).eq.ocapc
     .          .or.jchar(lpmode,1).eq.ocapd
     .          .or.jchar(lpmode,1).eq.ocape
            km3be=jchar(lpmode,1).eq.ocapb
     .          .or.jchar(lpmode,1).eq.ocape
            km3a=jchar(lpmode,1).eq.ocapa
C Find out if any channel is LSB, to decide what procedures are needed.
            klsblo=.false.
            DO ichan=1,nchan(istn,icode) !loop on channels
              ic=invcx(ichan,istn,icode) ! channel number
              if (freqrf(ic,istn,icode).lt.freqlo(ic,istn,icode)) 
     .          klsblo=.true.
            enddo
            nch = ICHMV(LNAMEP,1,LCODE(ICODE),1,nco)   ! ff
            CALL M3INF(ICODE,SPDIPS,IB)
C choices in LBNAME are D,8,4,2,1,H,Q,E
            NCH=ICHMV(LNAMEP,NCH,LBNAME,IB,1)          ! b
            NCH=ICHMV(LNAMEP,NCH,Lpmode,1,npmode)      ! m
C Convert pass index to integer or alpha
            if (jchar(lmode,1).eq.ocapv) then         ! p
              cp=cvpass(ipass:ipass)
            else
              cp=cpass(ipass:ipass)
            endif
            NCH=ICHMV_ch(LNAMEP,NCH,cp)
          endif 
          CALL CRPRC(LU_OUTFILE,LNAMEP)
          if (nprocs.eq.6) then
            write(luscn,'()')
            nprocs=0
          endif
          WRITE(LUSCN,9112) LNAMEP
          nprocs=nprocs+1
9112      FORMAT(' ',6A2,$)
C
C 3. Write out the following lines in the setup procedure:
          if (kvrec.or.km3rec.or.km4rec) then 
C  TAPEFRMffm
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'TAPEFRM')
            nch = ICHMV(ibuf,nch,LCODE(ICODE),1,nco)
            nch = ichmv(ibuf,nch,lpmode,1,npmode)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  PASS=$,SAME
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'pass=$')
            if (km3rec.or.km4rec) nch = ichmv_ch(ibuf,nch,',same') ! 2 heads on Mk3 
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  TRKFRMffmp
C  Also write trkfrm for Mk3 modes if it's an 8 BBC station or LSB LO
            if ((km4rack.or.kvrack).and.(.not.km3mode.or.klsblo.or.
     .         ((km3a.or.km3be).and.k8bbc))) then
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'TRKFRM')
              nch = ICHMV(ibuf,nch,LCODE(ICODE),1,nco)
              nch = ichmv(ibuf,nch,lpmode,1,npmode)
              nch = ichmv_ch(ibuf,nch,cp)
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            endif
C  TRACKS=tracks   
C  Also write tracks for Mk3 modes if it's an 8 BBC station or LSB LO
            if ((kvrack.or.km4rack).and.
     .        (.not.km3mode.or.klsblo.or.
     .         ((km3a.or.km3be).and.k8bbc))) then
              call ifill(ibuf,1,ibuflen,oblank)
              NCH = ichmv_ch(IBUF,1,'TRACKS=')
              ig0=0
              ig1=0
              ig2=0
              ig3=0
              if (itrk(2,1).eq.1.and.itrk(4,1).eq.1.and.
     .            itrk(6,1).eq.1.and.
     .            itrk(8,1).eq.1.and.itrk(10,1).eq.1.and.
     .            itrk(12,1).eq.1.and.
     .            itrk(14,1).eq.1.and.itrk(16,1).eq.1) ig0=1
              if (itrk(3,1).eq.1.and.itrk(5,1).eq.1.and.
     .            itrk(7,1).eq.1.and.
     .            itrk(9,1).eq.1.and.itrk(11,1).eq.1.and.
     .            itrk(13,1).eq.1.and.
     .            itrk(15,1).eq.1.and.itrk(17,1).eq.1) ig1=1
              if (itrk(18,1).eq.1.and.itrk(20,1).eq.1.and.
     .            itrk(22,1).eq.1.and.
     .            itrk(24,1).eq.1.and.itrk(26,1).eq.1.and.
     .            itrk(28,1).eq.1.and.
     .            itrk(30,1).eq.1.and.itrk(32,1).eq.1) ig2=1
              if (itrk(19,1).eq.1.and.itrk(21,1).eq.1.and.
     .            itrk(23,1).eq.1.and.
     .            itrk(25,1).eq.1.and.itrk(27,1).eq.1.and.
     .            itrk(29,1).eq.1.and.
     .            itrk(31,1).eq.1.and.itrk(33,1).eq.1) ig3=1
C         Write out the group names we have found. Zero out these
C         track names in a copy of the track table. Then list any
C         tracks still left in the table.
              do i=1,max_track
                itrk2(i)=itrk(i,1)
              enddo
              if (ig0.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V0,')
                do i=2,16,2
                  itrk2(i)=0
                enddo
              endif
              if (ig1.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V1,')
                do i=3,17,2
                  itrk2(i)=0
                enddo
              endif
              if (ig2.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V2,')
                do i=18,32,2
                  itrk2(i)=0
                enddo
              endif
              if (ig3.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V3,')
                do i=19,33,2
                  itrk2(i)=0
                enddo
              endif
              im0=0
              im1=0
              im2=0
              im3=0
              if (ig0.eq.0.and.itrk(4,1).eq.1.and.itrk(6,1).eq.1.and.
     .            itrk(8,1).eq.1.and.itrk(10,1).eq.1.and.
     .            itrk(12,1).eq.1.and.
     .            itrk(14,1).eq.1.and.itrk(16,1).eq.1) im0=1
              if (ig1.eq.0.and.itrk(5,1).eq.1.and.itrk(7,1).eq.1.and.
     .            itrk(9,1).eq.1.and.itrk(11,1).eq.1.and.
     .            itrk(13,1).eq.1.and.
     .            itrk(15,1).eq.1.and.itrk(17,1).eq.1) im1=1
              if (itrk(18,1).eq.1.and.itrk(20,1).eq.1.and.
     .            itrk(22,1).eq.1.and.
     .            itrk(24,1).eq.1.and.itrk(26,1).eq.1.and.
     .            itrk(28,1).eq.1.and.
     .            itrk(30,1).eq.1.and.ig2.eq.0) im2=1
              if (itrk(19,1).eq.1.and.itrk(21,1).eq.1.and.
     .            itrk(23,1).eq.1.and.
     .            itrk(25,1).eq.1.and.itrk(27,1).eq.1.and.
     .            itrk(29,1).eq.1.and.
     .            itrk(31,1).eq.1.and.ig3.eq.0) im3=1
C         Write out the group names we have found. Zero out these
C         track names in a copy of the track table. Then list any
C         tracks still left in the table.
              if (im0.eq.1) then
                nch = ichmv_ch(ibuf,nch,'M0,')
                do i=4,16,2
                  itrk2(i)=0
                enddo
              endif
              if (im1.eq.1) then
                nch = ichmv_ch(ibuf,nch,'M1,')
                do i=5,17,2
                  itrk2(i)=0
                enddo
              endif
              if (im2.eq.1) then
                nch = ichmv_ch(ibuf,nch,'M2,')
                do i=18,30,2
                  itrk2(i)=0
                enddo
              endif
              if (im3.eq.1) then
                nch = ichmv_ch(ibuf,nch,'M3,')
                do i=19,31,2
                  itrk2(i)=0
                enddo
              endif
              do i=2,33 ! pick up leftover tracks not in a whole group
                if (itrk2(i).eq.1) then
                  nch = nch + ib2as(i,ibuf,nch,Z8000+2)
                  nch = MCOMA(IBUF,nch)
                endif
              enddo ! pick up leftover tracks
              NCH = NCH-1
              CALL IFILL(IBUF,NCH,1,oblank)
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            endif ! kvrack.or.km4rack and .not. km3mode
          endif ! km3rec .or.km4recor kvrec
C  REC_MODE=<mode>,$,<roll>
C  USER_INFO=1,field,,auto
C  USER_INFO=2,field,,auto
C  DATA_VALID=OFF
          if (ks2rec) then ! S2 mode
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'REC_MODE=')
            nch = ichmv(ibuf,nch,ls2mode(1,istn,icode),1,
     .      iflch(ls2mode(1,istn,icode),16))
            nch = ichmv_ch(ibuf,nch,',$')
C           If roll is NOT blank then use it.
            if (ichcm_ch(lbarrel(1,istn,icode),1,'    ').ne.0) then 
              nch = MCOMA(IBUF,nch)
              nch = ichmv(ibuf,nch,lbarrel(1,istn,icode),1,4)
            endif
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            nch = ichmv_ch(IBUF,1,'user_info=1,field,,auto  ')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH)/2)
            nch = ichmv_ch(IBUF,1,'user_info=2,field,,auto  ')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH)/2)
            nch = ichmv_ch(IBUF,1,'data_valid=off  ')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH)/2)
          endif ! ks2rec
C  FORM=m,r,fan,barrel   (m=mode,r=rate=2*b) (no barrel for Mk4)
C  For S2, leave out command entirely
C  For 8-BBC stations, use "M" for Mk3 modes
          if ((kvrack.or.km3rack.or.km4rack).and..not.ks2rec) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'FORM=')
            if (km3mode) then
              if ((klsblo.and.(kvrack.or.km4rack))
     .          .or.k8bbc.and.(km3be.or.km3a)) then
                nch = ichmv_ch(ibuf,nch,'M')
              else IF ((kvrack.or.km3rack).and.
     .          ichcm_ch(lmode(1,istn,icode),1,'E').eq.0) THEN 
C                    !MODE E = B ON ODD, C ON EVEN PASSES
                IF (MOD(IPASS,2).EQ.0) THEN
                  nch = ichmv_ch(ibuf,nch,'C')
                ELSE
                  nch = ichmv_ch(ibuf,nch,'B')
                ENDIF
              else ! not mode E or else Mk4 formatter
                nch = ICHMV(IBUF,nch,lmode(1,istn,icode),1,1)
              ENDIF
            else ! not Mk3 mode
              nch = ICHMV(IBUF,nch,lmFMT(1,istn,icode),1,1)
            endif
C           Add group index for Mk4 formatter
C           ... but not for LSB case
            if (km4rack.and.km3mode.and..not.klsblo.and.
     .        ichcm_ch(lmode(1,istn,icode),1,'A').ne.0) then ! 
              if (ichcm_ch(lmode(1,istn,icode),1,'E').eq.0) THEN ! add group
                if (itrk(2,1).eq.1.or.itrk(4,1).eq.1.or.
     .              itrk(6,1).eq.1.or.
     .              itrk(8,1).eq.1.or.itrk(10,1).eq.1.or.
     .              itrk(12,1).eq.1.or.
     .              itrk(14,1).eq.1.or.itrk(16,1).eq.1) ig=1
                if (itrk(3,1).eq.1.or.itrk(5,1).eq.1.or.
     .              itrk(7,1).eq.1.or.
     .              itrk(9,1).eq.1.or.itrk(11,1).eq.1.or.
     .              itrk(13,1).eq.1.or.
     .              itrk(15,1).eq.1.or.itrk(17,1).eq.1) ig=2
                if (itrk(18,1).eq.1.or.itrk(20,1).eq.1.or.
     .              itrk(22,1).eq.1.or.
     .              itrk(24,1).eq.1.or.itrk(26,1).eq.1.or.
     .              itrk(28,1).eq.1.or.
     .              itrk(30,1).eq.1.or.itrk(32,1).eq.1) ig=3
                if (itrk(19,1).eq.1.or.itrk(21,1).eq.1.or.
     .              itrk(23,1).eq.1.or.
     .              itrk(25,1).eq.1.or.itrk(27,1).eq.1.or.
     .              itrk(29,1).eq.1.or.
     .              itrk(31,1).eq.1.or.itrk(33,1).eq.1) ig=4
                nch = nch+ib2as(ig,ibuf,nch,1) ! mode E group
              else ! add subpass number
                nch = nch+ib2as(ipass,ibuf,nch,1) ! mode B or C subpass
              endif
            endif ! add group or subpass
C           Add sample rate
            nch = MCOMA(IBUF,nch)
            nch = nch+IR2AS(samprate(ICODE),IBUF,nch,6,3)
            if (.not.ks2rec) then ! non-S2 only
C           If no fan, or if fan is 1:1, skip it unless we have roll.
            if ((ifan(istn,icode).ne.0.and.ifan(istn,icode).ne.1) .or.
     .        (ichcm_ch(lbarrel(1,istn,icode),1,'    ').ne.0.and.
     .          ichcm_ch(lbarrel(1,istn,icode),1,'NONE').ne.0.and.
     .          ichcm_ch(lbarrel(1,istn,icode),1,'off ').ne.0)) then ! barrel or fan
              nch = MCOMA(IBUF,nch)
C             Put in fan only if non-zero
              if (ifan(istn,icode).ne.0) then ! fan
                nch = ichmv_ch(ibuf,nch,'1:')
                nch = nch+ib2as(ifan(istn,icode),ibuf,nch,1)
              endif
              if ((ichcm_ch(lbarrel(1,istn,icode),1,'    ').ne.0.and.
     .          ichcm_ch(lbarrel(1,istn,icode),1,'NONE').ne.0.and.
     .          ichcm_ch(lbarrel(1,istn,icode),1,'off ').ne.0)) then ! a roll mode
                if (kvrack) then ! only for VLBA racks
                  nch = MCOMA(IBUF,nch)
                  nch = ichmv(ibuf,nch,lbarrel(1,istn,icode),1,4)
                else if (km4rack) then
                  write(luscn,9137) 
9137              format(/'PROCS05 - WARNING! Barrel roll is not',
     .            ' supported for Mark IV racks.')
                endif
              endif
            endif ! barrel or fan
            endif ! non-S2 only
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif ! kvrack or km3rac.or.km4rackk but not S2
C  FORM=RESET
          if (km3rack) then ! form=reset
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'FORM=RESET')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  !*
          if (kvrack.and..not.ks2rec) then ! wait mark for formatter reset
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!*')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  BIT_DENSITY=33333
          if (kvrack.and..not.ks2rec) then ! bit_density
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'bit_density=')
            ibit=bitdens(istn,icode)
            nch = nch + ib2as(ibit,ibuf,nch,5)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  SYSTRACKS=
          if (kvrec) then ! for all VLBA recorders
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'SYSTRACKS=')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  BBCffb   
          if (km3rack.or.km4rack.or.kvrack) then
            call ifill(ibuf,1,ibuflen,oblank)
            if (kvrack) nch = ichmv_ch(IBUF,1,'BBC')
            if (km3rack.or.km4rack) nch = ichmv_ch(IBUF,1,'VC')
            nch = ichmv(ibuf,nch,lcode(icode),1,nco)
            CALL M3INF(ICODE,SPDIPS,IB)
            NCH=ICHMV(ibuf,NCH,LBNAME,IB,1)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  IFDff
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'IFD')
            nch = ICHMV(IBUF,nch,LCODE(ICODE),1,nco)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif ! kvrack or km3rac.or.km4rackk
C  TAPE=LOW
          if (kvrec.or.km3rec.or.km4rec) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'TAPE=LOW')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  ENABLE=tracks 
C  Remember that tracks are VLBA track numbers in itrk.
          itrka=0
          itrkb=0
          if (kvrec.or.km3rec.or.km4rec) then
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'ENABLE=')
            if (kvrec) then ! group-only enables for VLBA recorders
              if (itrk(2,1).eq.1.or.itrk(4,1).eq.1.or.itrk(6,1).eq.1.or.
     .          itrk(8,1).eq.1.or.itrk(10,1).eq.1.or.itrk(12,1).eq.1.or.
     .          itrk(14,1).eq.1.or.itrk(16,1).eq.1) then
                ig0=1
                itrka=6
                itrkb=8
                nch = ichmv_ch(ibuf,nch,'G0')
                nch = MCOMA(IBUF,nch)
              endif
              if (itrk(3,1).eq.1.or.itrk(5,1).eq.1.or.
     .            itrk(7,1).eq.1.or.
     .            itrk(9,1).eq.1.or.itrk(11,1).eq.1.or.
     .            itrk(13,1).eq.1.or.
     .            itrk(15,1).eq.1.or.itrk(17,1).eq.1) then
                ig1=1
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=7
                  itrkb=9
                else
                  itrkb=9
                endif
                nch = ichmv_ch(ibuf,nch,'G1')
                nch = MCOMA(IBUF,nch)
              endif
              if (itrk(18,1).eq.1.or.itrk(20,1).eq.1.or.
     .            itrk(22,1).eq.1.or.
     .            itrk(24,1).eq.1.or.itrk(26,1).eq.1.or.
     .            itrk(28,1).eq.1.or.
     .            itrk(30,1).eq.1.or.itrk(32,1).eq.1) then
                ig2=1
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=20
                  itrkb=22
                else
                  itrkb=22
                endif
                nch = ichmv_ch(ibuf,nch,'G2')
                nch = MCOMA(IBUF,nch)
              endif
              if (itrk(19,1).eq.1.or.itrk(21,1).eq.1.or.
     .            itrk(23,1).eq.1.or.
     .            itrk(25,1).eq.1.or.itrk(27,1).eq.1.or.
     .            itrk(29,1).eq.1.or.
     .            itrk(31,1).eq.1.or.itrk(33,1).eq.1) then
                ig3=1
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=21
                  itrkb=23
                else
                  itrkb=23
                endif
                nch = ichmv_ch(ibuf,nch,'G3')
                nch = MCOMA(IBUF,nch)
              endif
            else if (km3rec) then ! group enables plus leftovers
              if (itrk(4,1).eq.1.and.itrk(6,1).eq.1.and.
     .            itrk(8,1).eq.1.and.
     .            itrk(10,1).eq.1.and.itrk(12,1).eq.1.and.
     .            itrk(14,1).eq.1.and.itrk(16,1).eq.1) then
                ig0=1
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=3 ! Mk3 track number
                  itrkb=5
                endif
                nch = ichmv_ch(ibuf,nch,'G1')
                nch = MCOMA(IBUF,nch)
              endif
              if (itrk(5,1).eq.1.and.itrk(7,1).eq.1.and.
     .            itrk(9,1).eq.1.and.itrk(11,1).eq.1.and.
     .            itrk(13,1).eq.1.and.
     .            itrk(15,1).eq.1.and.itrk(17,1).eq.1) then
                ig1=1
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=4
                  itrkb=6
                else
                  itrkb=6
                endif
                nch = ichmv_ch(ibuf,nch,'G2')
                nch = MCOMA(IBUF,nch)
              endif
              if (itrk(18,1).eq.1.and.itrk(20,1).eq.1.and.
     .            itrk(22,1).eq.1.and.
     .            itrk(24,1).eq.1.and.itrk(26,1).eq.1.and.
     .            itrk(28,1).eq.1.and.
     .            itrk(30,1).eq.1) then
                ig2=1
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=17
                  itrkb=19
                else
                  itrkb=19
                endif
                nch = ichmv_ch(ibuf,nch,'G3')
                nch = MCOMA(IBUF,nch)
              endif
              if (itrk(19,1).eq.1.and.itrk(21,1).eq.1.and.
     .            itrk(23,1).eq.1.and.
     .            itrk(25,1).eq.1.and.itrk(27,1).eq.1.and.
     .            itrk(29,1).eq.1.and.
     .            itrk(31,1).eq.1) then
                ig3=1
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=18
                  itrkb=20
                else
                  itrkb=20
                endif
                nch = ichmv_ch(ibuf,nch,'G4')
                nch = MCOMA(IBUF,nch)
              endif
C         Write out the Mk3 group names we have found. Zero out these
C         track names in a copy of the track table. Then list any
C         tracks still left in the table.
              do i=1,max_track
                itrk2(i)=itrk(i,1)
              enddo
              if (ig0.eq.1) then
                do i=4,16,2
                  itrk2(i)=0
                enddo
              endif
              if (ig1.eq.1) then
                do i=5,17,2
                  itrk2(i)=0
                enddo
              endif
              if (ig2.eq.1) then
                do i=18,30,2
                  itrk2(i)=0
                enddo
              endif
              if (ig3.eq.1) then
                do i=19,31,2
                  itrk2(i)=0
                enddo
              endif
              do i=4,31 ! pick up leftover Mk3 tracks not in a whole group
                if (itrk2(i).eq.1) then ! Mark3 numbering
                  nch = nch + ib2as(i-3,ibuf,nch,Z8000+2)
                  nch = MCOMA(IBUF,nch)
                endif
              enddo ! pick up leftover tracks
            else if (km4rec) then ! stack enables 
              kok=.false.
              do i=2,33 ! if any tracks are on, enable the stack
                if (itrk(i,1).eq.1) then
                  kok=.true.
                  if (itrka.ne.0.and.itrkb.eq.0) itrkb=i
                  if (itrka.eq.0) itrka=i
                endif
              enddo
              nch = ichmv_ch(ibuf,nch,'S1')
              nch = MCOMA(IBUF,nch)
            endif
            NCH = NCH-1
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif
C REPRO=byp,itrka,itrkb
          if (kvrec.or.km3rec.or.km4rec.and..not.ks2rec) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'repro=byp,')
            nch = nch+ib2as(itrka,ibuf,nch,Z8000+2)
            nch = MCOMA(IBUF,nch)
            nch = nch+ib2as(itrkb,ibuf,nch,Z8000+2)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C !*+8s
          if (kvrack.and..not.ks2rec) then ! formatter wait
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'!*+8s')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C ENDDEF
          CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')

        ENDDO ! loop on number of passes
C
C Now continue with procedures that are code-based

C 3. Write out the baseband converter frequency procedure.
C Name is VCffb or BBCffb      (ff=code,b=bandwidth)
C Contents: VCnn=freq,bw or BBCnn=freq,if,bw,bw
        if (kvrack.or.km3rack.or.km4rack) then
          CALL IFILL(LNAMEP,1,12,oblank)
          if (kvrack) nch = ichmv_ch(LNAMEP,1,'BBC')
          if (km3rack.or.km4rack) nch = ichmv_ch(LNAMEP,1,'VC')
          nch = ICHMV(LNAMEP,nch,LCODE(ICODE),1,nco)
          CALL M3INF(ICODE,SPDIPS,IB)
          NCH=ICHMV(LNAMEP,NCH,LBNAME,IB,1)
          CALL CRPRC(LU_OUTFILE,LNAMEP)
          if (nprocs.eq.6) then
            write(luscn,'()')
            nprocs=0
          endif
          nprocs=nprocs+1
          WRITE(LUSCN,9112) LNAMEP
C
          if (freqlo(1,istn,icode).lt.0.05) then ! missing LO
            write(luscn,9910)
9910        format(/'PROCS02 - WARNING! LO frequencies are missing!'/
     .      '   BBC or VC frequency procedure will ',
     .      'not be correct, nor will IFD procedure.') 
            knolo=.true.
          else
            knolo=.false.
          endif

          kfirst8 = .false.
          klast8  = .false.
          if (k8bbc.and.jchar(lpmode,1).eq.ocapa) then
            write(luscn,9922)
9922        format(/' This is a Mode A experiment at an 8-BBC station.')
            kdone = .false.
            do while (.not.kdone)
              write(luscn,9923) 
9923          format(' Do you want the first 8 channels or the ',
     .        'last 8 recorded (F/L) ? ',$)
              read(luusr,'(A)') response
              response(1:1) = upper(response(1:1))
              if (response(1:1).eq.'F'.or.response(1:1).eq.'L') then
                kdone = .true.
              end if
            end do
            if (response(1:1).eq.'F') kfirst8=.true.
            if (response(1:1).eq.'L') klast8=.true.
          endif

C         Initialize the bbc array to "not written yet"
          do ib=1,max_bbc
            igotbbc(ib)=0
          enddo
          DO ichan=1,nchan(istn,icode) !loop on channels
            ic=invcx(ichan,istn,icode) ! channel number
C           Skip the LSB channels because they are duplicates
C           Well that's stupid. Figure out a better way to check for
C           duplicates.
C           if (ichcm_ch(lnetsb(ic,istn,icode),1,'U').eq.0) then ! USB only
              ib=ibbcx(ic,istn,icode) ! BBC number
C             If we already did this BBC, then skip it.
              if (igotbbc(ib).eq.0) then ! do this BBC command
                igotbbc(ib)=1
C             For 8-BBC stations use the loop index number to get 1-7
              kinclude=.true.
              if (k8bbc) then
                if (km3be) then
                  ib=ichan
                else if (km3a) then
                  if (kfirst8) then
                    ib=ichan
                    if (ib.gt.8) kinclude=.false.
C                   Write out a max of 8 channels for 8-BBC stations
                  else if (klast8) then
                    ib=ichan-6
                    if (ib.le.0) kinclude=.false.
                  endif
                endif
              endif
              if (kinclude) then ! include this channel
                call ifill(ibuf,1,ibuflen,oblank)
                DRF = FREQRF(ic,istn,ICODE)
                DLO = FREQLO(ic,ISTN,ICODE)
                DFVC = DRF-DLO   ! BBCfreq = RFfreq - LOfreq
                rFVC = DFVC
                rFVC = ABS(rFVC)
                if (knolo) rFVC=-1.0 ! set to invalid value
                fvc(ib) = rfvc
                if (kvrack) nch = ichmv_ch(ibuf,1,'BBC')
                if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'VC')
                nch = nch + ib2as(ib,ibuf,nch,Z4000+2*Z100+2)
                nch = ichmv_ch(IBUF,nch,'=')
                NCH = nch + IR2AS(rFVC,IBUF,nch,6,2)
                kok=.false.
C               Make a copy of the IF input
                idummy=ichmv(linp(ic),1,lifinp(ic,istn,icode),1,2)
                if (km3rack.or.km4rack) then
                  if(ichcm_ch(linp(ic),1,'1N').eq.0 .or.
     .               ichcm_ch(linp(ic),1,'2N').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3N').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3I').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3O').eq.0.or.
     .               ichcm_ch(linp(ic),1,'1A').eq.0.or.
     .               ichcm_ch(linp(ic),1,'2A').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3A').eq.0) 
     .               kok=.true.
                  endif
                  if (kvrack) then
                  if (ichcm_ch(linp(ic),1,'A').eq.0.or.
     .            ichcm_ch(linp(ic),1,'B').eq.0.or.
     .            ichcm_ch(linp(ic),1,'C').eq.0.or.
     .            ichcm_ch(linp(ic),1,'D').eq.0) then
                    kok=.true.
                  else
                    if (ichcm_ch(linp(ic),1,'1N').eq.0) 
     .                idummy=ichmv_ch(linp(ic),1,'A ')
                    if (ichcm_ch(linp(ic),1,'2N').eq.0) 
     .                idummy=ichmv_ch(linp(ic),1,'B ')
                    if (ichcm_ch(linp(ic),1,'1A').eq.0) 
     .                idummy=ichmv_ch(linp(ic),1,'C ')
                    if (ichcm_ch(linp(ic),1,'2A').eq.0) 
     .                idummy=ichmv_ch(linp(ic),1,'D ')
                  endif
                endif
                if ((km3rack.or.km4rack).and..not.kok) write(luscn,9919) 
     .            lifinp(ic,istn,icode)
9919                format(/'PROCS04 - WARNING! IF input ',a2,' not',
     .            ' consistent with Mark III/IV rack.')
                if (kvrack.and..not.kok) write(luscn,9909) 
     .            lifinp(ic,istn,icode)
C    .            lifinp(ic,istn,icode),linp(ic)
9909              format(/'PROCS04 - WARNING! IF input ',a2,' not',
     .            ' consistent with VLBA rack.')
C                  /'          Changing',
C    .            ' IF input to ',a2)
                if (kvrack.and.(rfvc.lt.500.0.or.rfvc.gt.1000.0)) then
                  write(luscn,9911) ib,rfvc
9911              format(/'PROCS03 - WARNING! BBC ',i2,' frequency '
     .            f7.2,' is out of range.'/
     .            21x,' Check LO and IF in schedule.')
                else if ((km3rack.or.km4rack).and.
     .            (rfvc.lt.0.0.or.rfvc.gt.500.0)) then
                  write(luscn,9912) ib,rfvc
9912              format(/'PROCS03 - WARNING! VC ',i2,' frequency '
     .            f7.2,' is out of range.'/
     .            21x,' Check LO and IF in schedule.')
                endif
                if (kvrack) then
                  NCH = MCOMA(IBUF,NCH)
C                 Write out actual IF input from schedule file.
C                 This effectively disables the translation to VLBA IFs.
                  nch = ichmv(ibuf,nch,lifinp(ic,istn,icode),1,1)
                endif
                NCH = MCOMA(IBUF,NCH)
C               Converter bandwidth
                if (km4rack.and.(vcband(ic,istn,icode).eq.1.0.or.
     .                           vcband(ic,istn,icode).eq.0.25)) then ! external
                  NCH = ichmv_ch(ibuf,nch,'0.0(')
                  NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
                  NCH = ichmv_ch(ibuf,nch,')')
                else
                  NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
                endif
                if (kvrack) then
                  NCH = MCOMA(IBUF,NCH)
                  NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
                endif
                call hol2lower(ibuf,nch+1)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
              endif ! include this channel
              endif ! do this BBC command
C           endif ! USB only
          ENDDO !loop on channels
          if (km3rack.or.km4rack) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+1s')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'valarm')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif
          CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
        endif ! vrack or m3rack
C
C 4. Write out the IF distributor setup procedure.
C    for VLBA:  IFDAB=0,0,nor,nor
C               IFDCD=0,0,nor,nor
C               LO=lo1,lo2,lo3
C    for Mk3:   ifd=atn1,atn2,nor/alt,nor/alt
C               if3=atn3,out,1,1 (out for narrow)
C               if3=atn3,in,2,2 (in for WB)
C               lo=lo1,lo2,lo3
C               patch=lo1,...
C               patch=lo2,...
C               patch=lo3,...
C Later: add a check of patching to determine how the IF3 switches
C should really be set. 
C         if (VC3  is LOW) switch 1 = 1, else 2
C         if (VC11 is LOW) switch 2 = 1, else 2

        if (km3rack.or.km4rack.or.kvrack) then
          CALL IFILL(LNAMEP,1,12,oblank)
          IDUMMY = ichmv_ch(LNAMEP,1,'IFD')
          IDUMMY = ICHMV(LNAMEP,4,LCODE(ICODE),1,nco)
          CALL CRPRC(LU_OUTFILE,LNAMEP)
          if (nprocs.eq.6) then
            write(luscn,'()')
            nprocs=0
          endif
          nprocs=nprocs+1
          WRITE(LUSCN,9112) LNAMEP
C
            do i=1,max_bbc
              igotbbc(i)=0
            enddo
C IFD command
          if (km3rack.or.km4rack) then
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'IFD=')
            i1=0
            i2=0
            i3=0
            do i=1,nchan(istn,icode) ! which IFs are in use
              ic=invcx(i,istn,icode) ! channel number
              if (i1.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'1')
     .          .eq.0) i1=ic
              if (i2.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'2')
     .          .eq.0) i2=ic
              if (i3.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'3')
     .          .eq.0) i3=ic
            enddo ! which IFs are in use
            NCH = ichmv_ch(IBUF,NCH,'atn1,atn2,')
            if (i1.ne.0) then ! IF1 is in use
              IF (ichcm_ch(lifinp(i1,istn,ICODE),2,'N').EQ.0) then
                NCH = ichmv_ch(IBUF,NCH,'NOR,')
              ELSE ! must be 'A'
                NCH = ichmv_ch(IBUF,NCH,'ALT,')
              ENDIF
            else
              nch = ichmv_ch(ibuf,nch,',')
            endif
            if (i2.ne.0) then ! IF2 is in use
              IF (ichcm_ch(lifinp(i2,istn,ICODE),2,'N').EQ.0) THEN
                NCH = ichmv_ch(IBUF,NCH,'NOR')
              ELSE ! must be 'A'
                NCH = ichmv_ch(IBUF,NCH,'ALT')
              ENDIF
            else
              nch = ichmv_ch(ibuf,nch,',')
            endif
            call hol2lower(ibuf,nch)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
C           Always write the IF3 command until sked upgrades.
C           Not needed for the VEX file unless it's specified.
            if (kvex) then ! we know about IF3
              if (i3.ne.0) then ! IF3 is in use, write the command
                NCH = ichmv_ch(IBUF,1,'IF3=atn3,')
                IF (ichcm_ch(lifinp(i3,istn,ICODE),2,'O').EQ.0) THEN
                  NCH = ichmv_ch(IBUF,NCH,'OUT,1,1')
                ELSE ! must be 'I' or 'N'
                  NCH = ichmv_ch(IBUF,NCH,'IN,2,2')
                endif
                call hol2lower(ibuf,nch)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
              ENDIF
            else ! always write it
              NCH = ichmv_ch(IBUF,1,'IF3=atn3,')
              if (i3.ne.0) then ! IF3 is in use, add "in"
                NCH = ichmv_ch(IBUF,NCH,'IN,2,2')
              else ! force IF3 to "out"
                NCH = ichmv_ch(IBUF,NCH,'OUT,1,1')
              endif ! IF3 is in use
              call hol2lower(ibuf,nch)
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            endif ! we know/don't know about IF3
C
C LO command
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'LO=')
            if (i1.gt.0) then
              fr=freqlo(i1,istn,icode)
              if (freqlo(i1,istn,icode).gt.100000.d0) then
                igig=freqlo(i1,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(i1,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2)
            endif
            NCH = MCOMA(IBUF,NCH)
            if (i2.gt.0) then
              fr=freqlo(i2,istn,icode)
              if (freqlo(i2,istn,icode).gt.100000.d0) then
                igig=freqlo(i2,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(i2,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2)
            endif
            NCH = MCOMA(IBUF,NCH)
            if (i3.gt.0) then
              fr=freqlo(i3,istn,icode)
              if (freqlo(i3,istn,icode).gt.100000.d0) then
                igig=freqlo(i3,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(i3,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2)
            endif
            call hol2lower(ibuf,nch)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
C
C PATCH command
            DO I=1,3 ! three IFs need a patch command
              if (i.eq.1.and.i1.gt.0.or.i.eq.2.and.i2.gt.0.or.
     .        i.eq.3.and.i3.gt.0) then ! this LO in use
                call ifill(ibuf,1,ibuflen,oblank)
                NCH = ichmv_ch(IBUF,1,'PATCH=LO')
                NCH = NCH + IB2AS(I,IBUF,NCH,1)
                DO ic = 1,nchan(istn,icode)
                  iv=invcx(ic,istn,icode) ! channel number
C                 if (ichcm_ch(lnetsb(iv,istn,icode),1,'U').eq.0) then ! USB only
                  ib=ibbcx(iv,istn,icode) ! VC number
                  if (igotbbc(ib).eq.0) then! do this BBC 
                    if ((ichcm_ch(lifinp(iv,istn,icode),1,'1').eq.0.
     .                  and.i.eq.1).or.
     .                  (ichcm_ch(lifinp(iv,istn,icode),1,'2').eq.0.
     .                  and.i.eq.2).or.
     .                  (ichcm_ch(lifinp(iv,istn,icode),1,'3').eq.0.
     .                  and.i.eq.3)) then ! correct LO
                      igotbbc(ib)=1
                      NCH = MCOMA(IBUF,NCH)
                      NCH = nch+IB2AS(ib,IBUF,NCH,2+z8000) ! VC number
                      if (i.eq.3) then !IF3 always high
                        nch=ichmv_ch(ibuf,nch,'H')
                      else  ! IF1 and IF2 may be high or low
                        if (fvc(ib).lt.220.0) then !low 
                          nch=ichmv_ch(ibuf,nch,'L')
                        else ! high
                          nch=ichmv_ch(ibuf,nch,'H')
                        endif
                      endif
                    endif ! correct LO
                  endif ! do this BBC
C                 endif ! USB only
                ENDDO
                call hol2lower(ibuf,nch)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,((NCH+1))/2)
              endif ! this LO in use
            ENDDO ! three IFs need a patch command
          endif ! m3rack
          if (kvrack) then 
            CALL IFILL(IBUF,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'IFDAB=0,0,NOR,NOR')
            call hol2lower(ibuf,nch)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'IFDCD=0,0,NOR,NOR')
            call hol2lower(ibuf,nch)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
C
            i1=0
            i2=0
            i3=0
            i4=0
C           Find out which IFs are in use for this mode
C           Check against the local variable which might have been
C           adjusted if the schedule had Mk3 names for IFs.
C Disable the above by checking lifinp instead of linp
            do i=1,nchan(istn,icode)
              ic=invcx(i,istn,icode) ! channel number
              if (i1.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'A')
     .          .eq.0) i1=ic
              if (i2.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'B')
     .           .eq.0) i2=ic
              if (i3.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'C')
     .          .eq.0) i3=ic
              if (i4.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'D')
     .             .eq.0) i4=ic
            enddo
C
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'LO=')
            if (i1.gt.0) then 
              fr=freqlo(i1,istn,icode)
              if (freqlo(i1,istn,icode).gt.100000.d0) then
                igig=freqlo(i1,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(i1,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2)
            endif
              NCH = MCOMA(IBUF,NCH)
            if (i2.gt.0) then
              fr=freqlo(i2,istn,icode)
              if (freqlo(i2,istn,icode).gt.100000.d0) then
                igig=freqlo(i2,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(i2,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2)
            endif
              NCH = MCOMA(IBUF,NCH)
            if (i3.gt.0) then
              fr=freqlo(i3,istn,icode)
              if (freqlo(i3,istn,icode).gt.100000.d0) then
                igig=freqlo(i3,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(i3,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2)
            endif
              NCH = MCOMA(IBUF,NCH)
            if (i4.gt.0) then
              fr=freqlo(i4,istn,icode)
              if (freqlo(i4,istn,icode).gt.100000.d0) then
                igig=freqlo(i4,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqlo(i4,istn,icode)-igig*100000.d0
              endif
              NCH = NCH+IR2AS(FR,IBUF,NCH,8,2)
            endif
            nch=nch-1
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,nch)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif ! vlba
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
      endif ! km3rack .or.km4rackor kvrack
C
C 5. Write TAPEFRMffm procedure.
C    command format: TAPEFORM=index,offset lists

      if (kvrec.or.km3rec.or.km4rec) then
        CALL IFILL(LNAMEP,1,12,oblank)
        nch = ichmv_ch(LNAMEP,1,'TAPEFRM')
        nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco)
        nch = ICHMV(LNAMEP,nch,lpmode,1,npmode)
        cALL CRPRC(LU_OUTFILE,LNAMEP)
          if (nprocs.eq.6) then
            write(luscn,'()')
            nprocs=0
          endif
          nprocs=nprocs+1
        WRITE(LUSCN,9112) LNAMEP

        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'TAPEFORM=')
        do i=1,max_pass
          if (ihdpos(1,i,istn,icode).ne.9999) then 
            nch = nch + ib2as(i,ibuf,nch,3) ! pass number
            nch = mcoma(ibuf,nch)
            nch = nch + ib2as(ihdpos(1,i,istn,icode),ibuf,nch,4) ! offset
            nch = mcoma(ibuf,nch)
            ib=1
          endif
          if (ib.gt.0.and.nch.gt.60) then ! write a line
            nch=nch-1
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'TAPEFORM=')
            ib=0
          endif
        enddo
        if (ib.gt.0) then ! finish last line
          nch=nch-1
          CALL IFILL(IBUF,NCH,1,oblank)
          call hol2lower(ibuf,nch)
          call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
        endif
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
      endif
C
C 6. Write TRKFRM procedures, one per pass.
C    trkfrm=track,BBC#-sb-bit

      if (kvrec.or.km3rec.or.km4rec) then
        if ((km4rack.or.kvrack).and.
     .      (.not.km3mode.or.klsblo
     .      .or.((km3be.or.km3a).and.k8bbc))) then
          DO IPASS=1,NPASSF(istn,ICODE) !loop on subpasses
            call trkall(itras(1,1,1,1,ipass,istn,icode),
     .      lmode(1,istn,icode),
     .      itrk,lpmode,npmode,ifan(istn,icode),itrax)

            CALL IFILL(LNAMEP,1,12,oblank)
            nch = ichmv_ch(LNAMEP,1,'TRKFRM')
            nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco)
            nch = ICHMV(LNAMEP,nch,lpmode,1,npmode)
            if (jchar(lmode,1).eq.ocapv) then
              NCH=ICHMV_ch(LNAMEP,NCH,cvPASS(IPASS:ipass))
            else
              NCH=ICHMV_ch(LNAMEP,NCH,cPASS(IPASS:ipass))
            endif      
            CALL CRPRC(LU_OUTFILE,LNAMEP)
          if (nprocs.eq.6) then
            write(luscn,'()')
            nprocs=0
          endif
          nprocs=nprocs+1
            WRITE(LUSCN,9112) LNAMEP

            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'TRACKFORM=')
            ib=0
            DO ichan=1,nchan(istn,icode) !loop on channels
              ic=invcx(ichan,istn,icode) ! channel number
              do isb=1,2 ! sidebands
                do ibit=1,2 ! bits
                  it=itras(isb,ibit,1,ic,ipass,istn,icode)
                  if (it.ne.-99) then ! assigned
C                   Use BBC number, not channel number
                    ib=ibbcx(ic,istn,icode) ! BBC number
                    kinclude=.true.
                    if (k8bbc) then
                      if (km3be) then
                        ib=ichan
                      else if (km3a) then
                        if (kfirst8) then
                          ib=ichan
                          if (ib.gt.8) kinclude=.false.
C                         Write out a max of 8 channels for 8-BBC stations
                        else if (klast8) then
                          ib=ichan-6
                          if (ib.le.0) kinclude=.false.
                        endif
                      endif
                    endif
                    if (kinclude) then
                      isbx=isb
                      klsblo=freqrf(ic,istn,icode).lt.
     .                       freqlo(ic,istn,icode)
                      if (klsblo) then ! reverse sidebands
                        if (isb.eq.1) isbx=2
                        if (isb.eq.2) isbx=1
                      endif ! reverse sidebands
                      nch = iaddtr(ibuf,nch,it+3,ib,isbx,ibit)
                      ib=1
                    endif
                  endif ! assigned
                  if (kinclude.and.ib.ne.0.and.nch.gt.60) then ! write a line
                    nch=nch-1
                    CALL IFILL(IBUF,NCH,1,oblank)
                    call hol2lower(ibuf,nch)
                    call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
                    call ifill(ibuf,1,ibuflen,oblank)
                    nch = ichmv_ch(ibuf,1,'TRACKFORM=')
                    ib=0
                  endif
                enddo ! bits
              enddo ! sidebands
            enddo ! channels
            if (ib.ne.0) then ! final line
              nch=nch-1
              CALL IFILL(IBUF,NCH,1,oblank)
              call hol2lower(ibuf,nch)
              call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            endif
            CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
          enddo ! loop on sub-passes
        endif 
      endif

      endif ! code is defined
      write(luscn,'()')
      ENDDO ! loop on codes

C 7. Write out standard tape loading procedures

C UNLOADER procedure
      CALL IFILL(LNAMEP,1,12,oblank)
      nch = ichmv_ch(LNAMEP,1,'UNLOADER')
      CALL CRPRC(LU_OUTFILE,LNAMEP)
      WRITE(LUSCN,9112) LNAMEP
      if (ks2rec) then
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'rec_mode=16x8-1,0 ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'rec=eject ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
      else if (kvrec.or.km3rec.or.km4rec) then
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'!+5s ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'enable= ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'tape=off ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        if (kvrec) nch = ichmv_ch(ibuf,1,'rec=unload ')
        if (km3rec.or.km4rec) nch = ichmv_ch(ibuf,1,'st=rev,135,off ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
      endif
      CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
     
C LOADER procedure
      CALL IFILL(LNAMEP,1,12,oblank)
      nch = ichmv_ch(LNAMEP,1,'LOADER')
      CALL CRPRC(LU_OUTFILE,LNAMEP)
      WRITE(LUSCN,9112) LNAMEP
      if (ks2rec) then
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'rw  ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'!+20s  ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'et  ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'!+10s  ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'tape=reset ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
      endif
      if (kvrec) then
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'rec=load ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'!+10s ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'tape=low,reset ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
      endif
      if (kvrec.or.km3rec.or.km4rec) then
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'st=for,135,off ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'!+11s ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'et')
        call writf_asc(lu_outfile,ierr,ibuf,1)
        call ifill(ibuf,1,ibuflen,oblank)
        nch = ichmv_ch(ibuf,1,'!+3s ')
        call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
      endif
      CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
      write(luscn,'()')

C 8. Finally, write out the procedures in the $PROC section.
C Read each line and if our station is mentioned, write out the proc.
      IF (IRECPR.NE.0)  THEN ! procedures
        rewind(lu_infile)
        do i=1,irecpr-1
          CALL READF_ASC(lu_infile,iERR,IBUF,ILEN,ILen)
        enddo
        CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
        DO WHILE (IERR.GE.0.AND.ILEN.NE.-1.AND.JCHAR(IBUF,1).NE.odollar)
C         read $PROC section
          ICH = 1
          KUS=.FALSE.
          CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
          DO I=IC1,IC2
            IF (JCHAR(IBUF,I).EQ.JCHAR(LSTCOD(ISTN),1)) KUS=.TRUE.
          ENDDO
C
          IF (KUS) THEN ! a proc for us
            CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
            IF (IC1.NE.0) THEN ! write proc file
              CALL IFILL(LNAMEP,1,12,oblank)
              IDUMMY = ICHMV(LNAMEP,1,IBUF,IC1,MIN0(IC2-IC1+1,12))
              CALL CRPRC(LU_OUTFILE,LNAMEP)
              WRITE(LUSCN,9112) LNAMEP
              CALL GTSNP(ICH,ILEN,IC1,IC2)
              DO WHILE (IC1.NE.0) ! get and write commands
                NCH = ICHMV(IBUF2,1,IBUF,IC1,IC2-IC1+1)
                CALL IFILL(IBUF2,NCH,1,oblank)
                call hol2lower(ibuf,(nch+1))
                call writf_asc(LU_OUTFILE,IERR,IBUF2,(NCH)/2)
                CALL GTSNP(ICH,ILEN,IC1,IC2)
              ENDDO ! get and write commands
              CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
            ENDIF ! write proc file
          ENDIF ! a proc for us
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
        ENDDO ! read $PROC section
      ENDIF ! procedures

      CLOSE(LU_OUTFILE,IOSTAT=IERR)
      call drchmod(prcname,iperm,ierr)
      write(luscn,'()')
C
      RETURN
      END

