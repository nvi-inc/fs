        SUBROUTINE PROCS

C PROCS writes procedure file for the Field System.
C Version 9.0 is supported with this routine.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
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
C 970915 nrv Add iin=6 for VLBA4, add VLBA4 to VEX file types
C 971003 nrv Ask for first-8 or last-8 for Mode C (as well as Mode A)
C 971111 nrv Add ",same" for VLBA4 "pass" command.
C 971111 nrv Change 135 to 80 in unloader for Mk3/4/VLBA.
C 971205 nrv Remove "rec=mode..." from S2 unloader.
C 971205 nrv Collapse separate blocks for each LO into loops.
C 971205 nrv Add DECODE commands for Mk4, VLBA4, Mk3.
C 971208 nrv Add SIDEBAND and POLARIZATION commands per LO in IFD proc.
C 971208 nrv Add PCALFRMffmp procedure, PCALFORM and PCALFREQ commands.
C 971211 nrv Add "et" to UNLOADER for S2.
C 971216 nrv Revised format for LO command includes information in
C            SIDEBAND, POLARIZATION, and PCALFREQ commands in one.
C 971216 nrv Add PCALD=off, PCALD=, and PCALD to setup procedures
C 971229 nrv Add PCALFORM=, LO=, PATCH= to initialize setups.
C 980218 nrv Add iin=7,8,9 for various K4 equipment.
C 980218 nrv Add K4 LOADER, UNLOADER procedures
C 980301 nrv Add K4 VCLO command, finish VC command. Add K3 FORM.
C 980302 nrv Add IFD procedure for K4.
C 980929 nrv Modifications for K4 per Ed's memo and Koyama's table.
C 981001 nrv bit_density is for VLBA recorders (not racks)
C 981028 nrv Close and re-open schedule file to find the $PROC line.
C 981118 nrv Had skipped writing the bandwidth for Mk4 racks VCs.
C 990113 nrv Add option for VLBA/Mk3/4 rack with K4 recorder.
C 990304 nrv Add 7s pause before tape=reset for K4 recorders.
C 990304 nrv Move check for missing LO to within loop on BBCs.
C 990304 nrv Add RECPATCH commands in RECP procedures.
C 990308 nrv REC_MODE recording bandwidth should be integer.
C 990413 nrv Write TRKFRM command in setup using same if-tests as
C            when writing out the procedure.
C 990428 nrv Add options 18 and 19 for hybrid systems
C 990512 nrv Add rack and rec types to procintr call.
C 990520 nrv Remove comment from before LO command for K4.
C 990523 nrv Renumbered the options because K4 option 2 was inserted.
C 990523 nrv Changed K4-2 rack VC numbers to 1-8 instead of 01-08.
C 990523 nrv No call to RECP procedure if it's a Mk3 mode.
C 990527 nrv For K4 type 2 rack and rec use VABW=wide and VBBW=wide.
C 990527 nrv For K4 type 1 rack and type 2 rec use VCBW=4 regardless of bw.
C 990527 nrv For K4 type 2 rec use max bw on VC for Mk3/Mk4/VLBA racks.
C 990527 nrv Need TRACKS= for k4m4fm .
C 990608 nrv Write "invalid" for BBC frequency if out of range.
C 990620 nrv Check for rack/rec "unknown" instead of only for VEX file.
C 990620 nrv Add check for LSTFORM.
C 990803 nrv Change st=for,0,on to st=*,*,on
C 990819 nrv Add option 21 for VLBA4+VLBA.
C 990909 nrv Add check for length of rack and rec strings so that 
C            VLBA and VLBA4 don't both get set.
C 990910 nrv Allow FREQLO=0 to mean that the LO is really a valid 0.0 MHz,
C            but -1.0 means it's missing.
C 990910 nrv Force FORM=v or m regardless of the format in the schedule.
C 990910 nrv Fixed a bug: was checking kv4rec instead of kv4rack for
C            writing BBC procedure.
C 990918 nrv Add parameters to REPRO for higher speeds (not for Mk3).
C 990920 nrv Remove REPRO parameters until FS can handle them consistently,
C            instead comment out the DECODE command for 8 Mb/s/track.
C 991028 nrv Change "frm" in proc names to "f" to save 2 characters.
C 991101 nrv Change recorder commands to append "A" or "B". Loop on
C            number of recorders to make extra procedures. Change all
C            "k" switches to dimension 2 for two possible recorders.
C            Don't allow iin any more, get input from Option 11 or
C            control file.
C 991102 nrv Move setting the "k" switches to SET_TYPE. Return if
C            equipment is unknown. Move setup name to SETUP_NAME.
C 991108 nrv Check for pcaltones. If none, don't output PCAL routines.
C 991119 nrv Add SELECT=A/B and DRIVEA/B at start of setup procedures.
C 991119 nrv LOADER/UNLOD procs are empty if there are two drives.
C 991123 nrv Recorders 1 and 2 instead of A and B.
C 991206 nrv Use 1-letter sub-pass codes. Add rec index to 'pass='.
C 991208 nrv If 'unused' skip the procedures.
C 991208 nrv Add 'mounterx' procedures.
C 991211 nrv Use 'ir' index instead of '1' for procs not dependent on recorder.
C 991214 nrv Remove calling parametes from procintr.
C 991214 nrv Add kk3fmk4rack.
C 000302 nrv For K4 UNLOADER add !+15s after oldtape command.
C 000302 nrv Output a FORM= command for K4 formatter also.
C 000302 nrv Write out K4-1 type PATCH commands.
C 000321 nrv Add newtape command to K4 LOADER. Adjust timing in K4
C            LOADER and UNLOADER.
C 000509 nrv For S2 treat 'none' barrel roll same as blank, i.e. don't
C            print it.
C 000516 nrv Replace DECODE commands with CHECKCRC.
C 000530 nrv Add more USER_INFO commands per C. Klatt.
C 000615 nrv Add PCALON and PCALOFF procedures.
C 000620 nrv For K4 LOADER change 2s to 5s after TAPE=RESET.
C 000810 nrv Use recording format per schedule for VLBA formatters,
C            don't force it to be VLBA always.   
C 000816 nrv Add SETUP_NAME= command to setup procedures.
C 010207 nrv Change default attnuators for IFD and IF3 to null.
C 010207 nrv Change LOADER to shorten waits per Tasso.
C 010405 nrv Change IF3 command to correctly indicate patching
C            for VC3 and VC10.
C 010604 nrv Add PCAL on/off to IF3 command.
C 010604 nrv Defer setup_name.
C 010622 dg  Added code for 2-head recording. These lines are all
C            marked with "dg" or "debug". From D. Graham.
C 010711 nrv Move phase cal switch in IF3 command to the 7th parameter.
C 010724 nrv Leftover tracks not part of an entire group were not
C            being written out due to overwriting an internal
C            temporary variable by the 2-head code.
C 010820 nrv For 'none' don't put out procs, same as for 'unused'. 
C            Set up krec_2rec and
C            check that for whether to append suffix to rec commands.
C 010920 nrv Add code from D. Graham to enable "S2" for 2-head.
C 011002 nrv Change second wait in K4 LOADER to 6s per H. Osaki.
C 011011 nrv Wrong character counting variable in user_info setup.
C 011022 nrv Remove NEWTAPE from K4 LOADER.

C Called by: FDRUDG
C Calls: TRKALL,IADDTR,IADDPC,IADDK4,SET_TYPE,PROCINTR

C LOCAL VARIABLES:
      integer*2 IBUF2(40) ! secondary buffer for writing files
      integer*2 lpmode(2) ! mode for procedure names
      integer*2 linp(max_chan) ! IF input local variable
      LOGICAL KUS ! true if our station is listed for a procedure
      logical krec_2rec ! true to append '1' or '2' to rec commands
C     integer itrax(2,2,max_headstack,max_chan) ! fanned-out version of itras
      integer IC,ierr,i,idummy,nch,ipass,icode,it,iv,nchx,
     .ilen,ich,ic1,ic2,ibuflen,itrk(max_track,max_headstack),
     .ig,ig0,ig1,ig2,ig3,irecbw,irec,ir,
     .im0,im1,im2,im3,igotbbc(max_bbc),
     .npmode,itrk2(max_track,max_headstack),itype,
     .isbx,isb,ibit,ichan,ib,itrka,itrkb,nprocs,vc3_patch,vc10_patch
      logical kok,km3mode,km3be,km3ac,km4done,kpcal_d,kpcal
      logical kinclude,klast8,kfirst8,klsblo,knolo
      logical kvrack,kv4rack,km3rack,km4rack,kk41rack,kk42rack,
     .km4fmk4rack,k8bbc,kk4vcab,kk3fmk4rack
      logical kv4rec(2),kvrec(2),km3rec(2),ks2rec(2),
     .km4rec(2),kk42rec(2),kk41rec(2),kuse(2)
C     real speed,spd
      real spdips
C     integer*2 lspd(4)
C     integer nspd
        CHARACTER UPPER
        CHARACTER*4 STAT
        CHARACTER*4 RESPONSE
        integer*2 LNAMEP(6)
        logical ex
        logical kdone
      double precision DRF,DLO,DFVC
      character*2 cvc2k41(max_bbc)
      character*1 cvc2k42(max_bbc)
      character*1 cvchan(max_bbc)
      character*1 crec(2) ! recorder designation 1 or 2
      real fvc(max_bbc),fr,rfvc  !VC frequencies
      real rpc ! pc freq
      real samptest
      integer Z8000,Z4000,Z100
      integer igig,i1,i2,i3,i4,nco,ix
      integer ir2as,ib2as,mcoma,trimlen,jchar,ichmv ! functions
      integer iflch,ichcm_ch,ichmv_ch,iaddtr,iaddpc,iaddk4
      integer mhead,head2active ,ig4,ig5,ig6,ig7 !debug
      character*28 cpass,cvpass
C
C INITIALIZED VARIABLES:
        data ibuflen/80/
      data Z4000/Z'4000'/,Z100/Z'100'/,Z8000/Z'8000'/
      data cpass  /'123456789ABCDEFGHIJKLMNOPQRS'/
      data cvpass /'ABCDEFGHIJKLMNOPQRSTUVWXYZAB'/
      data cvc2k41/'01','02','03','04','05','06','07','08',
     .             '09','10','11','12','13','14','15','16'/
      data cvc2k42/'1','2','3','4','5','6','7','8',
     .             '1','2','3','4','5','6','7','8'/
      data cvchan /8*'A',8*'B'/
      data crec/'1','2'/
      data head2active /0/ !debug
C
C  1. Create the file. Initialize

      if (kmissing) then
        write(luscn,9101)
9101    format(/' PROCS00 - Missing or inconsistent head/track/pass',
     .  ' information.'/' Your procedures may be incorrect, or ',
     .  ' may cause a program abort.')
      endif

      if (ichcm_ch(lstrack(1,istn),1,'unknown').eq.0.or.
     .    ichcm_ch(lstrec(1,istn),1,'unknown').eq.0) then
        write(luscn,9102)
9102    format(/' PROCS01 - Rack or recorder type is unknown. Please',
     .  ' specify your '/
     .  ' equipment using Option 11 or the EQUIPMENT line in the ',
     .  ' control file.')
        return
      endif

      call set_type(istn,km3rack,km4rack,kvrack,kv4rack,
     .kk41rack,kk42rack,km4fmk4rack,kk3fmk4rack,k8bbc,
     .km3rec,km4rec,kvrec,
     .kv4rec,ks2rec,kk41rec,kk42rec)
      kk4vcab=.false.
      if ((kk41rack.or.kk42rack).and..not.km4fmk4rack) then
        if (nrecst(istn).eq.2) then
          if (kk41rec(1).and.kk42rec(2)) kk4vcab=.true.
          if (kk42rec(1).and.kk41rec(2)) kk4vcab=.true.
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
9114  format(' **NOTE** These procedures are for',
     .' the following equipment:')
      write(luscn,'("   >> ",4a2," rack")') (lstrack(i,istn),i=1,4)
      write(luscn,'("   >> ",4a2," recorder 1")') (lstrec(i,istn),i=1,4)
      if (nrecst(istn).eq.2) write(luscn,'("   >> ",4a2,
     ." recorder 2")') (lstrec2(i,istn),i=1,4)

      if (nrecst(istn).eq.1) then ! use rec 1 only
        kuse(1) = .true.
        kuse(2) = .false.
        ir = 1 ! index for procs that are not recorder dependent
        krec_2rec = .false. ! don't append '1' or '2' to rec commands
      endif ! use rec 1 only
      if (nrecst(istn).eq.2) then ! one rec might be unused or 'none'
        kuse(1) = ichcm_ch(lstrec(1,istn),1,'unused').ne.0.and.
     .            ichcm_ch(lstrec(1,istn),1,'none').ne.0
        kuse(2) = ichcm_ch(lstrec2(1,istn),1,'unused').ne.0.and.
     .            ichcm_ch(lstrec2(1,istn),1,'none').ne.0
        ir = 1
        if (kuse(2).and..not.kuse(1)) ir = 2
        krec_2rec = .true. ! do append '1' or '2' to rec commands
        if (ichcm_ch(lstrec(1,istn),1,'none').eq.0) then ! first rec is none
          krec_2rec = .false. ! don't append '1' or '2' to rec commands
        endif ! first rec is none
      endif

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
C    .(km3rack,km4rack,kvrack,kv4rack,
C    .kk41rack,kk42rack,km4fmk4rack,kk3fmk4rack,km3rec,km4rec,kvrec,
C    .kv4rec,ks2rec,kk41rec,kk42rec)
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

        kpcal = .true. ! on/off switch, default is on for non-VEX files
        if (kvex) then ! check for on/off
          kpcal = .false.
          do ic=1,nchan(istn,icode)
            if (freqpcal(ic,istn,icode).gt.0) kpcal = .true.
          enddo
        endif ! check for on/off
        
        kpcal_d = .false. ! detection or not
        if (kvex) then ! check for pcal on this code
          ic=1
          do while (.not.kpcal_d.and.ic.le.nchan(istn,icode))
            kpcal_d = npctone(ic,istn,icode).ne.0 
            ic=ic+1
          enddo
        endif ! check for pcal on this code


        DO IPASS=1,NPASSF(istn,ICODE) !loop on number of sub passes

          do irec=1,nrecst(istn) ! loop on number of recorders
            if (kuse(irec)) then ! procs for this recorder
          CALL IFILL(LNAMEP,1,12,oblank)
          itype=2
          if (ks2rec(irec)) itype=1
          call setup_name(itype,icode,ipass,lnamep,nch)
              
          call trkall(itras(1,1,1,1,ipass,istn,icode),
     .    lmode(1,istn,icode),
     .    itrk,lpmode,npmode,ifan(istn,icode))
          km3mode=jchar(lpmode,1).eq.ocapa
     .          .or.jchar(lpmode,1).eq.ocapb
     .          .or.jchar(lpmode,1).eq.ocapc
     .          .or.jchar(lpmode,1).eq.ocapd
     .          .or.jchar(lpmode,1).eq.ocape
          km3be=km3mode.and.(jchar(lpmode,1).eq.ocapb
     .          .or.jchar(lpmode,1).eq.ocape)
          km3ac=km3mode.and.(jchar(lpmode,1).eq.ocapa
     .          .or.jchar(lpmode,1).eq.ocapc)
C Find out if any channel is LSB, to decide what procedures are needed.
          klsblo=.false.
          DO ichan=1,nchan(istn,icode) !loop on channels
            ic=invcx(ichan,istn,icode) ! channel number
            if (freqrf(ic,istn,icode).lt.freqlo(ic,istn,icode)) 
     .        klsblo=.true.
          enddo
          if (krec_2rec      ) nch=ichmv_ch(lnamep,nch,crec(irec))
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
C
C Setup name for IFADJUST data base reference.
C SETUP_NAME=experiment
C DEFERRED
C       call ifill(ibuf,1,ibuflen,oblank)
C       nch = ichmv_ch(IBUF,1,'setup_name=')
C       NCH = ICHMV(IBUF,NCH,LEXPER,1,iflch(lexper,8))
C       if (ncodes.gt.1) then ! append code name
C         nch = ICHMV(ibuf,nch,LCODE(ICODE),1,nco)
C       endif ! append code name
C       call hol2lower(ibuf,(nch+1))
C       CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)

C SELECT=A/B
C DRIVEA/B
        if (nrecst(istn).gt.1.and.krec_2rec) then ! dual drives
          if (kvrec(irec).or.km3rec(irec).or.km4rec(irec).or.
     .        kv4rec(irec).or.ks2rec(irec).or.kk41rec(irec).or.
     .        kk42rec(irec)) then 
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'select=')
            nch = ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'drive')
            nch = ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
        endif ! dual drives

C  PCALON or PCALOFF
          call ifill(ibuf,1,ibuflen,oblank)
          if (kpcal) then
            nch = ichmv_ch(IBUF,1,'pcalon')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          else
            nch = ichmv_ch(IBUF,1,'pcaloff')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif

          if (kvrec(irec).or.km3rec(irec).or.km4rec(irec)
     .      .or.kv4rec(irec)) then 
C  PCALD=STOP
            if (kpcal_d) then
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'pcald=stop')
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            endif
C  TAPEFffm
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'TAPEF')
            nch = ICHMV(ibuf,nch,LCODE(ICODE),1,nco)
            nch = ichmv(ibuf,nch,lpmode,1,npmode)
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
c..debug:check if 2nd head active, i.e. hd posns are set
          head2active=0 !debug
          do i=1,max_pass !debug
            if (ihdpos(2,i,istn,icode).ne.9999)head2active=1       !debug
          enddo !debug
C  PASS=$,SAME
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'pass')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(IBUF,nch,'=$')
            if (km3rec(irec).or.km4rec(irec).or.kv4rec(irec)) then  !debug
               if(head2active .eq. 0)nch = ichmv_ch(ibuf,nch,',same') ! debug 2 heads on Mk3 
            endif  !debug
            if (km4rec(irec).or.kv4rec(irec)) then  !debug
               if(head2active .eq. 1)nch = ichmv_ch(ibuf,nch,',mk4') ! debug Mk4 2 write hedz
            endif  !debug
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C  TRKFffmp
C  Also write trkf for Mk3 modes if it's an 8 BBC station or LSB LO
            if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .        km4rec(irec).or.kk41rec(irec).or.kk42rec(irec)) then
            if ((km4rack.or.kvrack.or.kv4rack.or.kk41rack.or.kk42rack)
     .          .and.(.not.km3mode.or.
     .          klsblo.or.((km3ac.or.km3be).and.k8bbc))) then
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'TRKF')
              nch = ICHMV(ibuf,nch,LCODE(ICODE),1,nco)
              nch = ichmv(ibuf,nch,lpmode,1,npmode)
              NCH=ICHMV_ch(ibuf,NCH,cvPASS(IPASS:ipass))
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            endif
            endif
C  PCALFff
            if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'PCALF')
              nch = ICHMV(ibuf,nch,LCODE(ICODE),1,nco) ! code
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            endif
C  TRACKS=tracks   
C  Also write tracks for Mk3 modes if it's an 8 BBC station or LSB LO
            if ((kvrack.or.km4rack.or.kv4rack.or.km4fmk4rack).and.
     .        (.not.km3mode.or.klsblo.or.
     .         ((km3ac.or.km3be).and.k8bbc))) then
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
c....debug hd2 section
              ig4=0
              ig5=0
              ig6=0
              ig7=0
              if (itrk(2,2).eq.1.and.itrk(4,2).eq.1.and.
     .            itrk(6,2).eq.1.and.
     .            itrk(8,2).eq.1.and.itrk(10,2).eq.1.and.
     .            itrk(12,2).eq.1.and.
     .            itrk(14,2).eq.1.and.itrk(16,2).eq.1) ig4=1
              if (itrk(3,2).eq.1.and.itrk(5,2).eq.1.and.
     .            itrk(7,2).eq.1.and.
     .            itrk(9,2).eq.1.and.itrk(11,2).eq.1.and.
     .            itrk(13,2).eq.1.and.
     .            itrk(15,2).eq.1.and.itrk(17,2).eq.1) ig5=1
              if (itrk(18,2).eq.1.and.itrk(20,2).eq.1.and.
     .            itrk(22,2).eq.1.and.
     .            itrk(24,2).eq.1.and.itrk(26,2).eq.1.and.
     .            itrk(28,2).eq.1.and.
     .            itrk(30,2).eq.1.and.itrk(32,2).eq.1) ig6=1
              if (itrk(19,2).eq.1.and.itrk(21,2).eq.1.and.
     .            itrk(23,2).eq.1.and.
     .            itrk(25,2).eq.1.and.itrk(27,2).eq.1.and.
     .            itrk(29,2).eq.1.and.
     .            itrk(31,2).eq.1.and.itrk(33,2).eq.1) ig7=1
c...end debug hd 2 section
c.. incomplete, haven't done it for m4..m7 yet.....
C         Write out the group names we have found. Zero out these
C         track names in a copy of the track table in itrk2 Then list any
C         tracks still left in the table.
              do i=1,max_track
                itrk2(i,1)=itrk(i,1)
              enddo
              if (ig0.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V0,')
                do i=2,16,2
                  itrk2(i,1)=0
                enddo
              endif
              if (ig1.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V1,')
                do i=3,17,2
                  itrk2(i,1)=0
                enddo
              endif
              if (ig2.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V2,')
                do i=18,32,2
                  itrk2(i,1)=0
                enddo
              endif
              if (ig3.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V3,')
                do i=19,33,2
                  itrk2(i,1)=0
                enddo
              endif
c...another hd2 section
              do i=1,max_track
                itrk2(i,2)=itrk(i,2)
              enddo
              if (ig4.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V4,')
                do i=2,16,2
                  itrk2(i,2)=0
                enddo
              endif
              if (ig5.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V5,')
                do i=3,17,2
                  itrk2(i,2)=0
                enddo
              endif
              if (ig6.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V6,')
                do i=18,32,2
                  itrk2(i,2)=0
                enddo
              endif
              if (ig7.eq.1) then
                nch = ichmv_ch(ibuf,nch,'V7,')
                do i=19,33,2
                  itrk2(i,2)=0
                enddo
              endif
c....end of hd2 section
c.. for the moment dont do the m4-m7 things
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
                  itrk2(i,1)=0
                enddo
              endif
              if (im1.eq.1) then
                nch = ichmv_ch(ibuf,nch,'M1,')
                do i=5,17,2
                  itrk2(i,1)=0
                enddo
              endif
              if (im2.eq.1) then
                nch = ichmv_ch(ibuf,nch,'M2,')
                do i=18,30,2
                  itrk2(i,1)=0
                enddo
              endif
              if (im3.eq.1) then
                nch = ichmv_ch(ibuf,nch,'M3,')
                do i=19,31,2
                  itrk2(i,1)=0
                enddo
              endif
C  Now pick up leftover tracks that didn't appear in a whole group
C  and list each one separately.
              do i=2,33 
                if (itrk2(i,1).eq.1) then
                  nch = nch + ib2as(i,ibuf,nch,Z8000+2)
                  nch = MCOMA(IBUF,nch)
                endif
              enddo 
C  Leftovers for the second headstack.
              do i=2,33 
                if (itrk2(i,2).eq.1) then
                  nch = nch + ib2as(i,ibuf,nch,Z8000+2)
                  nch = MCOMA(IBUF,nch)
                endif
              enddo 
              NCH = NCH-1
              CALL IFILL(IBUF,NCH,1,oblank)
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            endif ! kvrack.or.km4rack.or.kv4rack and .not. km3mode
          endif ! km3rec .or.km4rec or kvrec or kv4rec
C  REC_MODE=<mode>,$,<roll>
C  user_info=1,label,station
C  user_info=2,label,source
C  user_info=3,label,experiment
C  USER_INFO=1,field,,auto
C  USER_INFO=2,field,,auto
C  user_info=3,field,XXX
C  DATA_VALID=OFF
          if (ks2rec(irec)) then ! S2 mode
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'REC_MODE')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(IBUF,nch,'=')
            nch = ichmv(ibuf,nch,ls2mode(1,istn,icode),1,
     .      iflch(ls2mode(1,istn,icode),16))
            nch = ichmv_ch(ibuf,nch,',$')
C           If roll is NOT blank and NOT NONE then use it.
            if (ichcm_ch(lbarrel(1,istn,icode),1,'    ').ne.0.and.
     .        ichcm_ch(lbarrel(1,istn,icode),1,'NONE').ne.0) then 
              nch = MCOMA(IBUF,nch)
              nch = ichmv(ibuf,nch,lbarrel(1,istn,icode),1,4)
            endif
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nchx = ichmv_ch(IBUF,1,'user_info')
            if (krec_2rec      ) nchx = ichmv_ch(ibuf,nchx,crec(irec))
            CALL IFILL(IBUF,nchx,ibuflen,32)
            NCH = ICHMV_ch(IBUF,nchx,'=1,label,station')
            CALL WRITF_ASC(LU_OUTFILE,ierr,IBUF,(NCH+1)/2)
            CALL IFILL(IBUF,nchx,ibuflen,32)
            NCH = ICHMV_ch(IBUF,nchx,'=2,label,source')
            CALL WRITF_ASC(LU_OUTFILE,ierr,IBUF,(NCH+1)/2)
            CALL IFILL(IBUF,nchx,ibuflen,32)
            NCH = ICHMV_ch(IBUF,nchx,'=3,label,experiment')
            CALL WRITF_ASC(LU_OUTFILE,ierr,IBUF,(NCH+1)/2)
            CALL IFILL(IBUF,nchx,ibuflen,32)
            NCH = ICHMV_ch(IBUF,nchx,'=3,field,')
            NCH = ICHMV(IBUF,NCH,LEXPER,1,8)
            CALL WRITF_ASC(LU_OUTFILE,ierr,IBUF,(NCH+1)/2)
            call ifill(ibuf,nchx,ibuflen,oblank)
            nch = ichmv_ch(IBUF,nchx,'=1,field,,auto ')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            call ifill(ibuf,nchx,ibuflen,oblank)
            nch = ichmv_ch(IBUF,nchx,'=2,field,,auto  ')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'data_valid')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(IBUF,nch,'=off')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif ! ks2rec
C REC_MODE=<mode> for K4
C !* to mark the time
          if (kk42rec(irec).or.kk41rec(irec)) then ! K4 recorder 
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'rec')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=synch_on')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            if (kk42rec(irec)) then ! type 2 rec_mode
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'REC_MODE')
              if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
              nch = ichmv_ch(IBUF,nch,'=')
              irecbw = 16.0*samprate(icode)
              nch = nch+Ib2AS(irecbw,IBUF,nch,Z8000+6)
              CALL IFILL(IBUF,NCH,1,oblank)
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(ibuf,1,'!*')
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            endif ! type 2 rec_mode
C  RECPff
C           No RECP procedure if it's a Mk3 mode.
            if ((km4rack.or.kvrack.or.kv4rack.or.kk41rack.or.kk42rack)
     .       .and. (.not.km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'RECP')
              nch = ICHMV(ibuf,nch,LCODE(ICODE),1,nco)
C             nch = ichmv_ch(ibuf,nch,crec(irec))
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            endif
          endif ! K4 recorder
C  BBCffb or VCffb
          if (km3rack.or.km4rack.or.kvrack.or.kv4rack.or.
     .        kk41rack.or.kk42rack) then
            call ifill(ibuf,1,ibuflen,oblank)
            if (kvrack.or.kv4rack) nch = ichmv_ch(IBUF,1,'BBC')
            if (km3rack.or.km4rack.or.
     .        kk41rack.or.kk42rack) 
     .        nch = ichmv_ch(IBUF,1,'VC')
            nch = ichmv(ibuf,nch,lcode(icode),1,nco)
            CALL M3INF(ICODE,SPDIPS,IB)
            NCH=ICHMV(ibuf,NCH,LBNAME,IB,1)
            if (kk4vcab.and.krec_2rec      ) 
     .      nch=ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif ! kvrack or km3rac.or.km4rackk .or. any k4rack
C  IFDff
          if (km3rack.or.km4rack.or.kvrack.or.kv4rack.or.
     .        kk41rack.or.kk42rack) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'IFD')
            nch = ICHMV(IBUF,nch,LCODE(ICODE),1,nco)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif ! kvrack or km3rac.or.km4rackk
C  PCALD=
          if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'pcald=')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  FORM=m,r,fan,barrel   (m=mode,r=rate=2*b) (no barrel for Mk4)
C  For S2, leave out command entirely
C  For 8-BBC stations, use "M" for Mk3 modes
          if (kvrack.or.km3rack.or.km4rack.or.kv4rack
     .          .or.km4fmk4rack.or.kk3fmk4rack) then 
            if (.not.(ks2rec(irec).or.kk41rec(irec).or.
     .        kk42rec(irec))) then 
C           if (km3rec(irec).or.km4rec(irec).or.kvrec(irec).or.
C    .        kv4rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'FORM=')
            if (km3mode) then
              if ((klsblo.and.(kv4rack.or.kvrack.or.km4rack
     .          .or.km4fmk4rack))
     .          .or.k8bbc.and.(km3be.or.km3ac)) then
                nch = ichmv_ch(ibuf,nch,'M')
              else IF ((kvrack.or.km3rack.or.kk3fmk4rack).and.
     .          ichcm_ch(lmode(1,istn,icode),1,'E').eq.0) THEN 
C                    MODE E = B ON ODD, C ON EVEN PASSES
                IF (MOD(IPASS,2).EQ.0) THEN 
                  nch = ichmv_ch(ibuf,nch,'C')
                ELSE
                  nch = ichmv_ch(ibuf,nch,'B')
                ENDIF
              else ! not mode E or else Mk4 formatter
                nch = ICHMV(IBUF,nch,lmode(1,istn,icode),1,1)
              ENDIF
            else ! not Mk3 mode
C             Use format from schedule, 'v' or 'm'
              nch = ICHMV(IBUF,nch,lmFMT(1,istn,icode),1,1)
C             Don't use the format from the schedule but use the one
C             appropriate for the type of equipment, m or v.
              if (kvrack) then ! add format to FORM command
C               nch = ICHMV_ch(IBUF,nch,'v')
              else if (kv4rack.or.km4rack.or.km4fmk4rack) then
C               nch = ICHMV_ch(IBUF,nch,'m')
              else 
                write(luscn,9138) 
9138              format(/'PROCS08 - WARNING! Non-Mk3 modes are not',
     .            ' supported by your station equipment.')
              endif ! add format to FORM command
            endif
C           Add group index for Mk4 formatter
C           ... but not for LSB case
            if ((km4rack.or.kv4rack.or.km4fmk4rack)
     .        .and.km3mode.and..not.klsblo.and.
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
            if (.not.ks2rec(irec)) then ! non-S2 only
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
                else if (kv4rack.or.km4rack.or.km4fmk4rack) then
                  write(luscn,9137) 
9137              format(/'PROCS05 - WARNING! Barrel roll is not',
     .            ' supported for Mark IV formatters.')
                endif
              endif
            endif ! barrel or fan
            endif ! non-S2 only
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
          endif ! kv4rack.or.kvrack or km3rac.or.km4rack but not S2 or K4
C  FORM=RESET
          if (km3rack.and..not.ks2rec(irec)) then ! form=reset
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'FORM=RESET')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  !*
          if (kvrack.and..not.ks2rec(irec).and.
     .    .not.kk41rec(irec).and..not.kk42rec(irec)) then ! wait mark for formatter reset
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!*')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  BIT_DENSITY=
          if ((kv4rec(irec).or.kvrec(irec)).and..not.ks2rec(irec)) then ! bit_density
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'bit_density')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=')
            ibit=bitdens(istn,icode)
            nch = nch + ib2as(ibit,ibuf,nch,5)
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  SYSTRACKS=
          if (kvrec(irec).or.kv4rec(irec)) then ! for all VLBA recorders
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'SYSTRACKS')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(IBUF,nch,'=')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  TAPE=LOW
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'TAPE')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(IBUF,nch,'=LOW')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  ENABLE=tracks 
C  Remember that tracks are VLBA track numbers in itrk.
          itrka=0
          itrkb=0
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'ENABLE')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            NCH = ichmv_ch(IBUF,nch,'=')
            if (kvrec(irec).or.kv4rec(irec)) then ! group-only enables for VLBA recorders
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
            else if (km3rec(irec)) then ! group enables plus leftovers
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
                itrk2(i,1)=itrk(i,1)
              enddo
              if (ig0.eq.1) then
                do i=4,16,2
                  itrk2(i,1)=0
                enddo
              endif
              if (ig1.eq.1) then
                do i=5,17,2
                  itrk2(i,1)=0
                enddo
              endif
              if (ig2.eq.1) then
                do i=18,30,2
                  itrk2(i,1)=0
                enddo
              endif
              if (ig3.eq.1) then
                do i=19,31,2
                  itrk2(i,1)=0
                enddo
              endif
              do i=4,31 ! pick up leftover Mk3 tracks not in a whole group
                if (itrk2(i,1).eq.1) then ! Mark3 numbering
                  nch = nch + ib2as(i-3,ibuf,nch,Z8000+2)
                  nch = MCOMA(IBUF,nch)
                endif
              enddo ! pick up leftover tracks
            else if (km4rec(irec)) then ! stack enables 
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
c.....2-head
              kok=.false.
              if(head2active .eq. 1)then
                do i=2,33 ! if any tracks are on, enable the stack
                  if (itrk(i,2).eq.1) then
                    kok=.true.
                  endif
                enddo
                if(kok)then
                  nch = ichmv_ch(ibuf,nch,'S2')
                  nch = MCOMA(IBUF,nch)
                endif
              endif
c... end 2-head
            endif
            NCH = NCH-1
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif
C REPRO=byp,itrka,itrkb
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec).and..not.ks2rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'repro')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(IBUF,nch,'=byp,')
            nch = nch+ib2as(itrka,ibuf,nch,Z8000+2)
            nch = MCOMA(IBUF,nch)
            nch = nch+ib2as(itrkb,ibuf,nch,Z8000+2)
C           spd = 12.0*speed(icode,istn)
C           call spdstr(spd,lspd,nspd)
C           if (km4rec.or.kv4rec) then ! repro=byp,a,b,speed
C             if (nspd.gt.0) then
C               nch = MCOMA(IBUF,nch)
C               nch = ichmv(ibuf,nch,lspd,1,nspd)
C             else ! invalid speed
C               write(luscn,9942) spd
C             endif
C           endif
C           if (kvrec) then ! repro=byp,a,b,byp,speed,speed
C             nch = ichmv_ch(ibuf,nch,',byp,')
C             if (ichcm_ch(lspd,1,'133.33').eq.0) then ! force 135
C               nspd=ichmv_ch(lspd,1,'135')-1
C             endif
C             if (nspd.gt.0) then
C               nch = ichmv(ibuf,nch,lspd,1,nspd)
C               nch = mcoma(ibuf,nch)
C               nch = ichmv(ibuf,nch,lspd,1,nspd)
C             else ! invalid speed
C               write(luscn,9942) spd
9942            format('PROCS12 - Illegal speed: ',f6.2,'. Cannot ',
     .          'specify equalizer in REPRO command.')
C             endif
C           endif
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C DECODE=a,crc
C replaced with CHECKCRC station-specific procedure
          if ((kv4rack.or.km3rack.or.km4rack).and..not.
     .    (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then ! decode commands
            samptest = samprate(icode)
            if (ifan(istn,icode).gt.0) 
     .        samptest=samptest/ifan(istn,icode)
            if (samptest.lt.7.5) then ! no double speed decoding 
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'checkcrc ')
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            endif
C           if (km4rec(irec)) then ! set up with st
C             call ifill(ibuf,1,ibuflen,oblank)
C             nch = ichmv_ch(IBUF,1,'st=*,*,on')
C             CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C           endif ! set up with st
C           call ifill(ibuf,1,ibuflen,oblank)
C           if (samprate(icode).lt.7.5) then ! single speed ok
C             nch = ichmv_ch(IBUF,1,'decode=a,crc')
C           else ! double speed is a comment
C             nch = ichmv_ch(IBUF,1,'"decode=a,crc')
C           endif
C           CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
C           call ifill(ibuf,1,ibuflen,oblank)
C           if (samprate(icode).lt.7.5) then ! single speed ok
C             nch = ichmv_ch(IBUF,1,'decode')
C           else ! double speed is a comment
C             nch = ichmv_ch(IBUF,1,'"decode')
C           endif
C           CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif ! decode commands
C !*+8s for VLBA formatter
          if (kvrack.and..not.ks2rec(irec).
     .     and..not.kk41rec(irec).and..not.kk42rec(irec)) then ! formatter wait
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'!*+8s')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C !*+20s for K4 type 2 recorder
          if (kk42rec(irec)) then ! formatter wait
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'!*+20s')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
C  PCALD
            if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'pcald')
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            endif
C ENDDEF
          CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')

          endif ! procs for this recorder
        enddo ! loop on number of recorders
      ENDDO ! loop on number of passes
C
C Now continue with procedures that are code-based only.

C 3. Write out the baseband converter frequency procedure.
C Name is VCffb or BBCffb      (ff=code,b=bandwidth)
C Contents: VCnn=freq,bw or BBCnn=freq,if,bw,bw
C For K4 VCs the content of this procedure will vary depending
C on the type of recorder, so two procedures may be necessary
C if the two recorders are different.
C For most cases only one copy of this proc should be made.

        do irec=1,nrecst(istn) ! loop on recorders
C         If both recorders are in use then do the check to see if
C         we should do one or both procs
          if ((kuse(1).ne.kuse(2).and.kuse(irec)).or.
     .        ((kuse(1).and.kuse(2)).and.(irec.eq.1.or.
     .                (irec.eq.2.and.kk4vcab)))) then ! do this
        if (kvrack.or.kv4rack.or.km3rack.or.km4rack.or.
     .        kk41rack.or.kk42rack) then
          CALL IFILL(LNAMEP,1,12,oblank)
          if (kvrack.or.kv4rack) nch = ichmv_ch(LNAMEP,1,'BBC')
          if (km3rack.or.km4rack.or.kk41rack.or.kk42rack) 
     .        nch = ichmv_ch(LNAMEP,1,'VC')
          nch = ICHMV(LNAMEP,nch,LCODE(ICODE),1,nco)
          CALL M3INF(ICODE,SPDIPS,IB)
          NCH=ICHMV(LNAMEP,NCH,LBNAME,IB,1)
          if (kk4vcab.and.krec_2rec      ) 
     .        nch=ichmv_ch(lnamep,nch,crec(irec))
          CALL CRPRC(LU_OUTFILE,LNAMEP)
          if (nprocs.eq.6) then
            write(luscn,'()')
            nprocs=0
          endif
          nprocs=nprocs+1
          WRITE(LUSCN,9112) LNAMEP
C
          kfirst8 = .false.
          klast8  = .false.
          if (k8bbc.and.(jchar(lpmode,1).eq.ocapa.or.
     .                   jchar(lpmode,1).eq.ocapc)) then
            write(luscn,9922)
9922        format(/' This is a Mode A or C experiment at an ',
     .             '8-BBC station.')
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
            ib=ibbcx(ic,istn,icode) ! BBC number
C           If we already did this BBC, then skip it.
            if (igotbbc(ib).eq.0) then ! do this BBC command
              igotbbc(ib)=1
C             For 8-BBC stations use the loop index number to get 1-7
              kinclude=.true.
              if (k8bbc) then
                if (km3be) then
                  ib=ichan
                else if (km3ac) then
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
                if (DLO.lt.0.d0) then ! missing LO
                  write(luscn,9910) ic
9910              format(/'PROCS02 - WARNING! LO frequency for',
     .            ' channel ',i2,' is missing!'/
     .            '   BBC or VC frequency procedure will ',
     .            'not be correct, nor will IFD procedure.') 
                  knolo=.true.
                else
                  knolo=.false.
                endif
                if (DLO.eq.-1.d0) DLO=0.d0 ! set to zero LO

                DFVC = DRF-DLO   ! BBCfreq = RFfreq - LOfreq
                rFVC = DFVC
                rFVC = ABS(rFVC)
                if (knolo) rFVC=-1.0 ! set to invalid value
                fvc(ib) = rfvc
                if (km3rack.or.km4rack.or.kvrack.or.kv4rack) then
                  if (kvrack.or.kv4rack) nch = ichmv_ch(ibuf,1,'BBC')
                  if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'VC')
                  nch = nch + ib2as(ib,ibuf,nch,Z4000+2*Z100+2)
                  nch = ichmv_ch(IBUF,nch,'=')
                endif
                if (kk41rack.or.kk42rack) then ! k4-2
                  nch = ichmv_ch(ibuf,1,'V')
                  if (kk41rack) then ! k4-1
                    nch = ichmv_ch(ibuf,nch,'CLO=')
                    nch = ichmv_ch(ibuf,nch,cvc2k41(ib))
                  else ! k4-2
                    nch=ichmv_ch(ibuf,nch,cvchan(ib)) ! 'A' or 'B'
                    nch = ichmv_ch(ibuf,nch,'LO=')
                    nch = ichmv_ch(ibuf,nch,cvc2k42(ib))
                  endif ! k4-1/2
                  nch = mcoma(ibuf,nch)
                endif ! k4-2
                kok=.false.
C               Make a copy of the IF input. Why? Not used later.
                idummy=ichmv(linp(ic),1,lifinp(ic,istn,icode),1,2)
                if (kk41rack.or.kk42rack) then
                  if(ichcm_ch(linp(ic),1,'1').eq.0 .or.
     .               ichcm_ch(linp(ic),1,'2').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3').eq.0) kok=.true.
                endif
                if (km3rack.or.km4rack) then
                  if(ichcm_ch(linp(ic),1,'1N').eq.0 .or.
     .               ichcm_ch(linp(ic),1,'2N').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3N').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3I').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3O').eq.0.or.
     .               ichcm_ch(linp(ic),1,'1A').eq.0.or.
     .               ichcm_ch(linp(ic),1,'2A').eq.0.or.
     .               ichcm_ch(linp(ic),1,'3A').eq.0) kok=.true.
                endif
                if (kvrack.or.kv4rack) then
                  if (ichcm_ch(linp(ic),1,'A').eq.0.or.
     .              ichcm_ch(linp(ic),1,'B').eq.0.or.
     .              ichcm_ch(linp(ic),1,'C').eq.0.or.
     .              ichcm_ch(linp(ic),1,'D').eq.0) kok=.true.
                endif
C               else if (km3rack.or.km4rack) then
C                 if (ichcm_ch(linp(ic),1,'1N').eq.0) 
C    .              idummy=ichmv_ch(linp(ic),1,'A ')
C                 if (ichcm_ch(linp(ic),1,'2N').eq.0) 
C    .              idummy=ichmv_ch(linp(ic),1,'B ')
C                 if (ichcm_ch(linp(ic),1,'1A').eq.0) 
C    .              idummy=ichmv_ch(linp(ic),1,'C ')
C                 if (ichcm_ch(linp(ic),1,'2A').eq.0) 
C    .              idummy=ichmv_ch(linp(ic),1,'D ')
C               endif
C  The warning messages.
                if ((km3rack.or.km4rack).and..not.kok) write(luscn,9919) 
     .            lifinp(ic,istn,icode)
9919                format(/'PROCS04 - WARNING! IF input ',a2,' not',
     .            ' consistent with Mark III/IV rack.')
                if ((kvrack          ).and..not.kok) write(luscn,9909) 
     .            lifinp(ic,istn,icode)
9909              format(/'PROCS04 - WARNING! IF input ',a2,' not',
     .            ' consistent with VLBA rack.')
                if ((kvrack.or.kv4rack).and.
     .            (rfvc.lt.499.9.or.rfvc.gt.1000.0)) 
     .            write(luscn,9911) ib,rfvc
9911              format(/'PROCS03 - WARNING! BBC ',i2,' frequency '
     .            f7.2,' is out of range.'/
     .            21x,' Check LO and IF in schedule.')
                if ((km3rack.or.km4rack).and.
     .            (rfvc.lt.0.0.or.rfvc.gt.499.9)) 
     .            write(luscn,9912) ib,rfvc
9912              format(/'PROCS03 - WARNING! VC ',i2,' frequency '
     .            f7.2,' is out of range.'/
     .            21x,' Check LO and IF in schedule.')
                if ((kk41rack.and.
     .            (rfvc.lt. 99.99.or.rfvc.gt.511.99)) .or.
     .            (kk42rack.and.(rfvc.lt.499.99.or.rfvc.gt.999.99))) 
     .            write(luscn,9913) ib,rfvc
9913              format(/'PROCS03 - WARNING! K4 VC ',i2,' frequency '
     .            f7.2,' is out of range.'/
     .            21x,' Check LO and IF in schedule.')
                if (km3rack.and.vcband(ic,istn,icode).gt.7.9) 
     .            write(luscn,9192)
9192              format(/'PROCS07 - WARNING! Video bandwidths ',
     .              'greater than 4 '/'  are not supported for ',
     .              'Mark III racks.')
                if (kk41rack.and.vcband(ic,istn,icode).gt.7.9) 
     .            write(luscn,9191)
9191              format(/'PROCS06 - WARNING! Channel bandwidths ',
     .              'greater than 4 '/'  are not supported for ',
     .              'K4 type 1 racks.')
C               if (kok) then
                  NCH = nch + IR2AS(rFVC,IBUF,nch,6,2) ! converter freq
C               else
C                 nch = ichmv_ch(ibuf,nch,'invalid')
C               endif
                if (kvrack.or.kv4rack) then
                  NCH = MCOMA(IBUF,NCH)
C                 Write out actual IF input from schedule file.
C                 This effectively disables the translation to VLBA IFs.
                  nch = ichmv(ibuf,nch,lifinp(ic,istn,icode),1,1)
                endif
C               Converter bandwidth
                km4done = .false.
                if (km4rack.and.(vcband(ic,istn,icode).eq.1.0.or.
     .                           vcband(ic,istn,icode).eq.0.25)) then ! external
                  NCH = MCOMA(IBUF,NCH)
                  NCH = ichmv_ch(ibuf,nch,'0.0(')
                  NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
                  NCH = ichmv_ch(ibuf,nch,')')
                  km4done = .true.
                else if (kvrack.or.kv4rack.or.km3rack.or.(km4rack.and.
     .                 .not.km4done)) then
                  NCH = MCOMA(IBUF,NCH)
                  if (kk42rec(irec).and.(km4rack.or.kvrack.or.
     .              kv4rack)) then
                    nch = ichmv_ch(ibuf,nch,'16.0') ! max for K42 rec
                  else if (kk42rec(irec).and.km3rack) then
                    nch = ichmv_ch(ibuf,nch,'4.0') ! max for K42 rec
                  else
                    NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,
     .                  NCH,6,3)
                  endif
                endif
                if (kvrack.or.kv4rack) then
                  NCH = MCOMA(IBUF,NCH)
                  if (kk42rec(irec)) then
                    nch = ichmv_ch(ibuf,nch,'16.0') ! max for K42 rec
                  else
                    NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,
     .                     NCH,6,3)
                  endif
                endif
                call hol2lower(ibuf,nch+1)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
                if (kk41rack.or.kk42rack) then ! k4
                  call ifill(ibuf,1,ibuflen,oblank)
                  nch = ichmv_ch(ibuf,1,'V')
                  if (kk41rack) then ! k4-1
                    nch=ichmv_ch(ibuf,nch,'C')
                    nch = ichmv_ch(ibuf,nch,'=')
                    nch = ichmv_ch(ibuf,nch,cvc2k41(ib))
                  else ! k4-2
                    nch=ichmv_ch(ibuf,nch,cvchan(ib)) ! 'A' or 'B'
                    nch = ichmv_ch(ibuf,nch,'=')
                    nch = ichmv_ch(ibuf,nch,cvc2k42(ib))
                  endif ! k4-1/2
                  call hol2lower(ibuf,nch+1)
                  CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
                endif ! k4
              endif ! include this channel
            endif ! do this BBC command
          ENDDO !loop on channels
          if (km3rack.or.km4rack) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+1s')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'valarm')
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif
C         For K4, use bandwidth of channel 1
          if (kk41rack) then ! k4-1
            call ifill(ibuf,1,ibuflen,oblank)
            nch=ichmv_ch(ibuf,1,'vcbw=')
            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'4.0')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif ! k4-1
          if (kk42rack) then ! k4-2
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'vabw=')
            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'wide')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'vbbw=')
            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'wide')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif ! k4-2
          CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
        endif ! vrack or m3rack
        endif ! do this
        enddo ! loop on recorders
C
C 4. Write out the IF distributor setup procedure.
C  old          LO=lo1,lo2,lo3
C  new          LO=LOn,freq,usb,rcp,pcal,offset
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
C Later: add a check of patching to determine how the IF3 switches
C should really be set. 
C         if (VC3  is LOW) switch 1 = 1, else 2
C         if (VC11 is LOW) switch 2 = 1, else 2

        if (km3rack.or.km4rack.or.kvrack.or.kv4rack.or.
     .     kk41rack.or.kk42rack) then ! 
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
          if (km3rack.or.km4rack .or. kk41rack.or.kk42rack) then 
C                        m3rack IFD, LO, PATCH, SIDEBAND
C                        k4rack LO, PATCH
C           First find out which IFs are in use for this code
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
C IFD command
            if (km3rack.or.km4rack ) then ! mk3/4 IFD
              call ifill(ibuf,1,ibuflen,oblank)
              NCH = ichmv_ch(IBUF,1,'IFD=')
C             NCH = ichmv_ch(IBUF,NCH,'atn1,atn2,')
              NCH = ichmv_ch(IBUF,NCH,',,') ! default atn is now null
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
C             Always write the IF3 command until sked upgrades to
C             indicate whether a station has an IF3 module. VC3 and
C             VC10 are assumed to be the VCs connected to IF3.
C  First determine the patching for VC3 and VC10.
              vc3_patch=1
              vc10_patch=1
              DO ic = 1,nchan(istn,icode)
                iv=invcx(ic,istn,icode) ! channel number
                ib=ibbcx(iv,istn,icode) ! VC number
                if (ib.eq.3.and.fvc(ib).gt.210.0) vc3_patch=2
                if (ib.eq.10.and.fvc(ib).gt.210.0) vc10_patch=2
              enddo 
              if (kvex) then ! we know about IF3
                if (i3.ne.0) then ! IF3 exists, write the command
C   I'm not sure that "i3.ne.0" means that IF3 exists, just that
C   it's in use. The VEX file is supposed to indicate whether a
C   station has IF3 regardless of whether it's being used.
C                 NCH = ichmv_ch(IBUF,1,'IF3=atn3,')
                  NCH = ichmv_ch(IBUF,1,'IF3=,') ! default atn is now null
                  IF (ichcm_ch(lifinp(i3,istn,ICODE),2,'O').EQ.0) THEN
                    NCH = ichmv_ch(IBUF,NCH,'OUT,')
                  ELSE ! must be 'I' or 'N'
                    NCH = ichmv_ch(IBUF,NCH,'IN,')
                  endif
                  nch = nch+ib2as(vc3_patch,ibuf,nch,1)
                  NCH = MCOMA(IBUF,NCH)
                  nch = nch+ib2as(vc10_patch,ibuf,nch,1)
C                 Add phase cal on/off info as 7th parameter. 
                  NCH = MCOMA(IBUF,NCH)
                  NCH = MCOMA(IBUF,NCH)
                  NCH = MCOMA(IBUF,NCH)
                  if (kpcal) then ! on
                    nch=ichmv_ch(ibuf,nch,'on')
                  else ! off
                    nch=ichmv_ch(ibuf,nch,'off')
                  endif ! value/off
                  call hol2lower(ibuf,nch)
                  CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
                ENDIF ! IF3 exists, write the command
              else ! always write it
C               NCH = ichmv_ch(IBUF,1,'IF3=atn3,')
                NCH = ichmv_ch(IBUF,1,'IF3=,') ! default atn is now null
                if (i3.ne.0) then ! IF3 is in use, add "in"
                  NCH = ichmv_ch(IBUF,NCH,'IN,')
                else ! force IF3 to "out"
                  NCH = ichmv_ch(IBUF,NCH,'OUT,')
                endif ! IF3 is in use
                nch = nch+ib2as(vc3_patch,ibuf,nch,1)
                NCH = MCOMA(IBUF,NCH)
                nch = nch+ib2as(vc10_patch,ibuf,nch,1)
C               Add phase cal on/off info next. 
                NCH = MCOMA(IBUF,NCH)
                NCH = MCOMA(IBUF,NCH)
                NCH = MCOMA(IBUF,NCH)
                if (kpcal) then ! on
                  nch=ichmv_ch(ibuf,nch,'on')
                else ! off
                  nch=ichmv_ch(ibuf,nch,'off')
                endif ! value/off
                call hol2lower(ibuf,nch)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
              endif ! we know/don't know about IF3
            endif ! mk3/4 IFD
C
C LO command for Mk3/4 and K4
C           First reset all
            call ifill(ibuf,1,ibuflen,oblank)
            if (kk41rack.or.kk42rack) nch = ichmv_ch(ibuf,1,'lo=')
            if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'lo=')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            do i=1,3 ! up to 3 LOs
              call ifill(ibuf,1,ibuflen,oblank)
              if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'lo=lo')
              if (kk41rack.or.kk42rack) nch = ichmv_ch(ibuf,1,'lo=lo')
              if (i.eq.1) ix=i1
              if (i.eq.2) ix=i2
              if (i.eq.3) ix=i3
              if (ix.gt.0) then ! this LO in use
                NCH = NCH + IB2AS(I,IBUF,NCH,1) ! LO number
                NCH = MCOMA(IBUF,NCH)
                fr=freqlo(ix,istn,icode)
                if (freqlo(ix,istn,icode).gt.100000.d0) then
                  igig=freqlo(ix,istn,icode)/100000.d0
                  nch=nch+ib2as(igig,ibuf,nch,1)
                  fr=freqlo(ix,istn,icode)-igig*100000.d0
                endif
                NCH = NCH+IR2AS(FR,IBUF,NCH,8,2) ! LO frequency
                NCH = MCOMA(IBUF,NCH)
                klsblo=freqrf(ix,istn,icode).lt.freqlo(ix,istn,icode)
                if (.not.klsblo) then ! upper
                  nch=ichmv(ibuf,nch,losb(ix,istn,icode),1,1)
                else ! lower, so reverse
                  if (ichcm_ch(losb(ix,istn,icode),1,'U').eq.0) then
                    nch=ichmv_ch(ibuf,nch,'L')
                  else 
                    nch=ichmv_ch(ibuf,nch,'U')
                  endif 
                endif ! lower, so reverse
                nch=ichmv_ch(ibuf,nch,'sb')
                if (kvex) then ! have pol and pcal
                  NCH = MCOMA(IBUF,NCH)
                  nch=ichmv(ibuf,nch,lpol(ix,istn,icode),1,1) ! polarization
                  nch=ichmv_ch(ibuf,nch,'cp')
                  NCH = MCOMA(IBUF,NCH)
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
                endif ! have pol and pcal
                call hol2lower(ibuf,nch)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
              endif ! this LO in use
            enddo ! up to 3 LOs
C
C PATCH command for Mk3/4 and K4
C           First reset all
            call ifill(ibuf,1,ibuflen,oblank)
            if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'patch=')
            if (kk41rack.or.kk42rack) nch = ichmv_ch(ibuf,1,'patch=')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            DO I=1,3 ! up to three Mk3/4, K4 IFs need a patch command
              if (i.eq.1.and.i1.gt.0.or.i.eq.2.and.i2.gt.0.or.
     .          i.eq.3.and.i3.gt.0) then ! this LO in use
                call ifill(ibuf,1,ibuflen,oblank)
                if (kk41rack.or.kk42rack) 
     .            NCH = ichmv_ch(IBUF,1,'PATCH=LO')
                if (km3rack.or.km4rack) 
     .            NCH = ichmv_ch(IBUF,1,'PATCH=LO')
                NCH = NCH + IB2AS(I,IBUF,NCH,1)
                DO ic = 1,nchan(istn,icode)
                  iv=invcx(ic,istn,icode) ! channel number
                  ib=ibbcx(iv,istn,icode) ! VC number
                  if (igotbbc(ib).eq.0) then! do this BBC 
                    if ((ichcm_ch(lifinp(iv,istn,icode),1,'1').eq.0.
     .                and.i.eq.1).or.
     .                (ichcm_ch(lifinp(iv,istn,icode),1,'2').eq.0.
     .                and.i.eq.2).or.
     .                (ichcm_ch(lifinp(iv,istn,icode),1,'3').eq.0.
     .                and.i.eq.3)) then ! correct LO
                      igotbbc(ib)=1
                      NCH = MCOMA(IBUF,NCH)
                      if (km3rack.or.km4rack) then ! mk3/4
                        NCH = nch+IB2AS(ib,IBUF,NCH,2+z8000) ! VC number
                        if (i.eq.3) then !IF3 always high
                          nch=ichmv_ch(ibuf,nch,'H')
                        else  ! IF1 and IF2 may be high or low
                          if (fvc(ib).gt.210.0) then ! high
                            nch=ichmv_ch(ibuf,nch,'H')
                          else ! low
                            nch=ichmv_ch(ibuf,nch,'L')
                          endif
                        endif
                      endif ! mk3/4
                      if (kk41rack.or.kk42rack) then ! k4
                        if (kk41rack) then
                          if (ib.ge.1.and.ib.le.4) then
                            igotbbc(1)=1
                            igotbbc(2)=1
                            igotbbc(3)=1
                            igotbbc(4)=1
                            nch = ichmv_ch(ibuf,nch,'1-4')
                          endif
                          if (ib.ge.5.and.ib.le.8) then
                            igotbbc(5)=1
                            igotbbc(6)=1
                            igotbbc(7)=1
                            igotbbc(8)=1
                            nch = ichmv_ch(ibuf,nch,'5-8')
                          endif
                          if (ib.ge.9.and.ib.le.12) then
                            igotbbc(9)=1
                            igotbbc(10)=1
                            igotbbc(11)=1
                            igotbbc(12)=1
                            nch = ichmv_ch(ibuf,nch,'9-12')
                          endif
                          if (ib.ge.13.and.ib.le.16) then
                            igotbbc(13)=1
                            igotbbc(14)=1
                            igotbbc(15)=1
                            igotbbc(16)=1
                            nch = ichmv_ch(ibuf,nch,'13-16')
                          endif
                        endif
                        if (kk42rack) then
                          nch = ichmv_ch(ibuf,nch,cvchan(ib)) ! A or B
                          nch = ichmv_ch(ibuf,nch,cvc2k42(ib))
                        endif
                      endif ! k4
                    endif ! correct LO
                  endif ! do this BBC
                ENDDO
                call hol2lower(ibuf,nch)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,((NCH+1))/2)
              endif ! this LO in use
            ENDDO ! three Mk3/4 IFs need a patch command
          endif ! m3rack IFD, LO, PATCH commands

C IFDAB, IFDCD commands
          if (kvrack.or.kv4rack) then ! vlba IFD, LO commands
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
C LO command for VLBA
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'lo=')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            do i=1,4
              call ifill(ibuf,1,ibuflen,oblank)
              NCH = ichmv_ch(IBUF,1,'LO=LO')
              if (i.eq.1) ix=i1
              if (i.eq.2) ix=i2
              if (i.eq.3) ix=i3
              if (i.eq.4) ix=i4
              if (ix.gt.0) then ! this LO in use
                NCH = ichmv_ch(ibuf,nch,char(ichar('a')+i-1)) ! LO name
                NCH = MCOMA(IBUF,NCH)
                fr=freqlo(ix,istn,icode)
                if (freqlo(ix,istn,icode).gt.100000.d0) then
                  igig=freqlo(ix,istn,icode)/100000.d0
                  nch=nch+ib2as(igig,ibuf,nch,1)
                  fr=freqlo(ix,istn,icode)-igig*100000.d0
                endif
                NCH = NCH+IR2AS(FR,IBUF,NCH,8,2) ! LO frequency
                NCH = MCOMA(IBUF,NCH)
                klsblo=freqrf(ix,istn,icode).lt.freqlo(ix,istn,icode)
                if (.not.klsblo) then ! upper
                  nch=ichmv(ibuf,nch,losb(ix,istn,icode),1,1)
                else ! lower, so reverse
                  if (ichcm_ch(losb(ix,istn,icode),1,'U').eq.0) then
                    nch=ichmv_ch(ibuf,nch,'L')
                  else 
                    nch=ichmv_ch(ibuf,nch,'U')
                  endif 
                endif ! lower, so reverse
                nch=ichmv_ch(ibuf,nch,'sb')
                if (kvex) then ! have pol and pcal
                  NCH = MCOMA(IBUF,NCH)
                  nch=ichmv(ibuf,nch,lpol(ix,istn,icode),1,1) ! polarization
                  nch=ichmv_ch(ibuf,nch,'cp')
                  NCH = MCOMA(IBUF,NCH)
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
                endif ! have pol and pcal
                call hol2lower(ibuf,nch)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
              endif ! this LO in use
            enddo
          endif ! vlba IFD, LO commands
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
      endif ! km3rack .or.km4rack or kvrac.or.kv4rackk
C
C 5. Write TAPEFffm procedure.
C    command format: TAPEFORM=index,offset lists

      do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec)) then ! procs for this recorder
        if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .    km4rec(irec)) then
          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'TAPEF')
          nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco)
          nch = ICHMV(LNAMEP,nch,lpmode,1,npmode)
          if (krec_2rec      ) nch = ichmv_ch(lnamep,nch,crec(irec))
          cALL CRPRC(LU_OUTFILE,LNAMEP)
            if (nprocs.eq.6) then
              write(luscn,'()')
              nprocs=0
            endif
            nprocs=nprocs+1
          WRITE(LUSCN,9112) LNAMEP

          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(ibuf,1,'TAPEFORM')
          if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
          nch = ichmv_ch(ibuf,nch,'=')
      do mhead=1,max_headstack               !debug
          do i=1,max_pass
cdg            if (ihdpos(1,i,istn,icode).ne.9999) then    
            if (ihdpos(mhead,i,istn,icode).ne.9999) then       !debug
cdg              nch = nch + ib2as(i,ibuf,nch,3) ! pass number
              nch = nch + ib2as((i+100*(mhead-1)),ibuf,nch,3) ! pass number debug
              nch = mcoma(ibuf,nch)
cdg              nch = nch + ib2as(ihdpos(1,i,istn,icode),ibuf,nch,4) ! offset
              nch = nch + ib2as(ihdpos(mhead,i,istn,icode),ibuf,nch,4) ! offset debug
              nch = mcoma(ibuf,nch)
              ib=1
            endif
            if (ib.gt.0.and.nch.gt.60) then ! write a line
              nch=nch-1
              CALL IFILL(IBUF,NCH,1,oblank)
              call hol2lower(ibuf,nch)
              call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(ibuf,1,'TAPEFORM')
              if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
              nch = ichmv_ch(ibuf,nch,'=')
              ib=0
            endif
          enddo
      enddo  !debug end headstack loop
          if (ib.gt.0) then ! finish last line
            nch=nch-1
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          endif
          CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
        endif
        endif ! procs for this recorder
      enddo ! loop on recorders
C
C 6. Write TRKF and RECP procedures, one per pass.
C    trackform=track,BBC#-sb-bit
C    recpatch=track,BBC#-sb
C These procedures do not depend on the type of recorder.
C The check for recorder type is included only so that the
C same logic can be used for TRKF and RECP.
C Therefore, use the index of the recorder in use for all the tests 
C in this section.
C    
      if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)
     .        .or.kk41rec(ir).or.kk42rec(ir)) then
        if ((km4rack.or.kvrack.or.kv4rack.or.kk41rack.or.kk42rack).and.
     .      (.not.km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then
          DO IPASS=1,NPASSF(istn,ICODE) !loop on subpasses
            call trkall(itras(1,1,1,1,ipass,istn,icode),
     .      lmode(1,istn,icode),
     .      itrk,lpmode,npmode,ifan(istn,icode))

            CALL IFILL(LNAMEP,1,12,oblank)
            if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)) 
     .        then
              nch = ichmv_ch(LNAMEP,1,'TRKF')
              nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco)
              nch = ICHMV(LNAMEP,nch,lpmode,1,npmode)
C             Use 1-letter pass
              NCH=ICHMV_ch(LNAMEP,NCH,cvPASS(IPASS:ipass))
C             if (jchar(lmode,1).eq.ocapv) then
C               NCH=ICHMV_ch(LNAMEP,NCH,cvPASS(IPASS:ipass))
C             else
C               NCH=ICHMV_ch(LNAMEP,NCH,cPASS(IPASS:ipass))
C             endif      
            endif
            if (kk41rec(ir).or.kk42rec(ir)) then
              nch = ichmv_ch(LNAMEP,1,'RECP')
              nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco)
            endif
            CALL CRPRC(LU_OUTFILE,LNAMEP)
          if (nprocs.eq.6) then
            write(luscn,'()')
            nprocs=0
          endif
          nprocs=nprocs+1
            WRITE(LUSCN,9112) LNAMEP

            call ifill(ibuf,1,ibuflen,oblank)
            if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)) 
     .        then
              nch = ichmv_ch(ibuf,1,'TRACKFORM=')
            endif
            if (kk41rec(ir).or.kk42rec(ir)) then
              nch = ichmv_ch(ibuf,1,'RECPATCH=')
            endif
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            ib=0
            DO ichan=1,nchan(istn,icode) !loop on channels
              ic=invcx(ichan,istn,icode) ! channel number
      do mhead =1,max_headstack !debug hedzz
              do isb=1,2 ! sidebands
                do ibit=1,2 ! bits
cdg                  it=itras(isb,ibit,1,ic,ipass,istn,icode)
                  it=itras(isb,ibit,mhead,ic,ipass,istn,icode)    !debug
                  if (it.ne.-99) then ! assigned
C                   Use BBC number, not channel number
                    ib=ibbcx(ic,istn,icode) ! BBC number
                    kinclude=.true.
                    if (k8bbc) then
                      if (km3be) then
                        ib=ichan
                      else if (km3ac) then
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
                      if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.
     .                  km4rec(ir)) then
                         if (mhead .eq. 2)then               !debug
                           if((it+3) .lt.10)nch=ichmv_ch(ibuf,nch,'10') !debug
                           if((it+3) .ge.10)nch=ichmv_ch(ibuf,nch,'1') !debug
                         endif               !debug
                        nch = iaddtr(ibuf,nch,it+3,ib,isbx,ibit)
                      endif
                      if (kk41rec(ir).or.kk42rec(ir)) then
                        nch = iaddk4(ibuf,nch,it,ib,isbx,
     .                  kk41rack,kk42rack,
     .                  km3rack,km4rack,kvrack,kv4rack)
                      endif
                      ib=1
                    endif
                  endif ! assigned
                  if (kinclude.and.ib.ne.0.and.nch.gt.60) then ! write a line
                    nch=nch-1
                    CALL IFILL(IBUF,NCH,1,oblank)
                    call hol2lower(ibuf,nch)
                    call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
                    call ifill(ibuf,1,ibuflen,oblank)
                    if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.
     .                km4rec(ir)) then
                      nch = ichmv_ch(ibuf,1,'TRACKFORM=')
                    endif
                    if (kk41rec(ir).or.kk42rec(ir)) then
                      nch = ichmv_ch(ibuf,1,'RECPATCH=')
                    endif
                    ib=0
                  endif
                enddo ! bits
              enddo ! sidebands
            enddo ! loop on channels
      enddo !debug loop on hedzz
            if (ib.ne.0) then ! final line
              nch=nch-1
              CALL IFILL(IBUF,NCH,1,oblank)
              call hol2lower(ibuf,nch)
              call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            endif
            CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
          enddo ! loop on sub-passes
        endif ! km4rack.or.kvrack.or.kv4rack
      endif ! kvrec.or.kv4rec.or.km3rec.or.km4rec

C 7. Write PCALF procedure.
C    pcalform=bbc-sb,tone,tone,...
C These procedures do not depend on the type of recorder.
C The check for recorder type is included only so that the
C same logic can be used for TRKF and RECP.
C Therefore, use index 1 for all the tests in this section.

      if (kpcal_d) then 
      if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)) then
        if ((km4rack.or.kvrack.or.kv4rack).and.
     .      (.not.km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then

          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'PCALF')
          nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco) ! code
          CALL CRPRC(LU_OUTFILE,LNAMEP)
          if (nprocs.eq.6) then
            write(luscn,'()')
            nprocs=0
          endif
          nprocs=nprocs+1
          WRITE(LUSCN,9112) LNAMEP
C PCALFORM=
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(ibuf,1,'pcalform=')
          call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
C PCALFORM commands
          DO ichan=1,nchan(istn,icode) !loop on channels
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'PCALFORM=')
            ic=invcx(ichan,istn,icode) ! channel number
C           Use BBC number, not channel number
            ib=ibbcx(ic,istn,icode) ! BBC number
            if (ichcm_ch(lnetsb(ic,istn,icode),1,'U').eq.0) isb=1
            if (ichcm_ch(lnetsb(ic,istn,icode),1,'L').eq.0) isb=2
            kinclude=.true.
            if (k8bbc) then
              if (km3be) then
                ib=ichan
              else if (km3ac) then
                if (kfirst8) then
                  ib=ichan
                  if (ib.gt.8) kinclude=.false.
C                 Write out a max of 8 channels for 8-BBC stations
                else if (klast8) then
                  ib=ichan-6
                  if (ib.le.0) kinclude=.false.
                endif
              endif
            endif
            if (kinclude) then
              isbx=isb
              klsblo=freqrf(ic,istn,icode).lt.
     .        freqlo(ic,istn,icode)
              if (klsblo) then ! reverse sidebands
                if (isb.eq.1) isbx=2
                if (isb.eq.2) isbx=1
              endif ! reverse sidebands
            endif
            nch = iaddpc(ibuf,nch,ib,isbx,ipctone(1,ic,istn,icode),
     .           npctone(ic,istn,icode))
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          enddo ! loop on channels
          CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
        endif ! km4rack.or.kvrack.or.kv4rack
      endif ! kvrec.or.kv4rec.or.km3rec.or.km4rec
      endif ! only vex knows pcal

      endif ! code is defined
      write(luscn,'()')
      ENDDO ! loop on codes

C 8. Write out standard tape loading and unloading procedures

C UNLOADER procedure
      do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec)) then ! procs for this recorder
          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'UNLOADER')
          if (krec_2rec      ) nch = ichmv_ch(lnamep,nch,crec(irec)) 
          CALL CRPRC(LU_OUTFILE,LNAMEP)
          WRITE(LUSCN,9112) LNAMEP
          if (ks2rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'et')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'rec')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=eject')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          else if (kk41rec(irec).or.kk42rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'rec')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=eject')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+10s')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'oldtape=$')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+20s')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          else if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+5s')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'enable')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'= ')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'tape')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=off ')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            if (kvrec(irec).or.kv4rec(irec)) then
              nch = ichmv_ch(ibuf,1,'rec')
              if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
              nch = ichmv_ch(ibuf,nch,'=unload ')
            endif
            if (km3rec(irec).or.km4rec(irec)) then
              nch = ichmv_ch(ibuf,1,'st')
              if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
              nch = ichmv_ch(ibuf,nch,'=rev,80,off ')
            endif
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          endif
C       endif ! non-empty proces for single recorder
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
        endif ! procs for this recorder
      enddo ! loop on recorders
     
C LOADER procedure
      do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec)) then ! procs for this recorder
          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'LOADER')
          if (krec_2rec      ) nch = ichmv_ch(lnamep,nch,crec(irec)) 
          CALL CRPRC(LU_OUTFILE,LNAMEP)
          WRITE(LUSCN,9112) LNAMEP
          if (ks2rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'rw')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+10s')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'et')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+3s  ')
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'tape')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=reset ')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          endif
          if (kk41rec(irec).or.kk42rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
C           nch = ichmv_ch(ibuf,1,'newtape=$')
C           call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
C           call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+25s ')
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'tape')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=reset ')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+6s ')
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
          endif
          if (kvrec(irec).or.kv4rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'rec')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=load ')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+10s ')
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'tape')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=low,reset ')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
          endif
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'st')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=for,135,off ')
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+11s ')
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'et')
            if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'!+3s ')
            call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
          endif
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
        endif ! procs for this recorder
      enddo ! loop on recorders

C MOUNTER procedure
      if (krec_2rec        ) then ! only for 2-rec stations
       do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec)) then ! procs for this recorder
        CALL IFILL(LNAMEP,1,12,oblank)
        nch = ichmv_ch(LNAMEP,1,'MOUNTER')
        if (krec_2rec      ) nch = ichmv_ch(lnamep,nch,crec(irec)) 
        CALL CRPRC(LU_OUTFILE,LNAMEP)
        WRITE(LUSCN,9112) LNAMEP
        if (kvrec(irec).or.kv4rec(irec)) then
          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(ibuf,1,'rec')
          if (krec_2rec      ) nch = ichmv_ch(ibuf,nch,crec(irec))
          nch = ichmv_ch(ibuf,nch,'=load ')
          call hol2lower(ibuf,nch)
          call writf_asc(lu_outfile,ierr,ibuf,(nch)/2)
        endif ! non-empty only for VLBA/4
        CALL writf_asc_ch(LU_OUTFILE,IERR,'enddef')
        endif ! procs for this recorder
      enddo ! loop on recorders
      endif ! only for 2-rec stations
      write(luscn,'()')

C 9. Finally, write out the procedures in the $PROC section.
C Read each line and if our station is mentioned, write out the proc.
      IF (IRECPR.NE.0)  THEN ! procedures
        close(unit=LU_INFILE)
        open(unit=LU_INFILE,file=LSKDFI,status='old',iostat=IERR)
        if (ierr.ne.0) then
          write(luscn,9991) ierr,lskdfi
9991      format('PROCS91 - Error ',i5,' opening ',a)
          return
        endif
C       rewind(lu_infile) May not be open any more.
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
                call writf_asc(LU_OUTFILE,IERR,IBUF2,(NCH+1)/2)
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
