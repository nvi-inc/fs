        SUBROUTINE PROCS

C PROCS writes procedure file for the Field System.
C Version 9.0 is supported with this routine.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
      include 'hardware.ftni'           !common block containing info on hardware
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
C            marked with "2hd". From D. Graham.
C 010711 nrv Move phase cal switch in IF3 command to the 7th parameter.
C 010724 nrv Leftover tracks not part of an entire group were not
C            being written out due to overwriting an internal
C            temporary variable by the 2-head code.
C 010820 nrv For 'none' don't put out procs, same as for 'unused'. 
C            Set up krec_append and
C            check that for whether to append suffix to rec commands.
C 010920 nrv Add code from D. Graham to enable "S2" for 2-head.
C 011002 nrv Change second wait in K4 LOADER to 6s per H. Osaki.
C 011011 nrv Wrong character counting variable in user_info setup.
C 011022 nrv Remove NEWTAPE from K4 LOADER.
C 011130 nrv Add comments with sky frequencies if no rack.
C 020111 nrv Change REPRO command to add the track bitrate parameter.
C 020111 nrv Barrell roll parameter OK for Mk4 formatters.
C 020114 nrv ROLLFORM commands.
C 020304 nrv Mk5 piggyback mode.
C 020320 nrv Add "*" in front of second TRACKS line for piggyback.
C 020327 nrv Add ":1" for roll on VLBA racks if it's not there.
C 020327 nrv Check data modulation and insert "ON" if on.
C 020508 nrv Add TPI daemon commands.
C 020510 nrv Add tpi sideband to VC commands.
C 020514 nrv Check head 2 for BBC connections.
C 020515 nrv Correct the placement of TPI daemon commands.
C 020522 nrv Correct the reading of prompt for TPI.
C 020524 nrv Move statement initializing itpid_period_use out of
C            prompt block.
C 020606 nrv Initialize IBUF2 for writing out procedures. Add kcomment
C            to GTSNP call.
C 020618 nrv Inconsistent use of itype in setup_name for K4 between
C            procs and snap. Use itype=2 for both K4 and S2.
C 020705 nrv Add recorder number to RECPATCH and OLDTAPE commands.
C 020923 nrv Add km5prec to set_type call.
C 020925 nrv Add km5prec tests so that tape-only commands are not written.
C 021003 nrv With a Mk4 formatter, with Mk5 recorder only, use the
C            second headstack, same as piggyback mode.
C 021111 jfq Added new LBA rack procedures
C 021111 jfq Also use 200ft in LOADER for thin tapes
C 2002Dec23 JMG If IF3  and lo1=lo3, then out, else in.
C 2002Dec30 JMG RCP added to LO commands for geodetic schedules.
C 2003Feb11 JMG for Mk5.  Remove barrel-roll from Form=.
C 2003Apr25 JMG Mark5A additions.  Previous MK5 renamed MK5P, added MK5A

C Called by: FDRUDG
C Calls: TRKALL,IADDTR,IADDPC,IADDK4,SET_TYPE,PROCINTR

! Functions
      character upper     
      integer ir2as,ib2as,mcoma,trimlen,jchar,ichmv ! functions
      logical kCheckGrpOr
      integer num_tracks_rec

C LOCAL VARIABLES:
      integer*2 IBUF2(40) ! secondary buffer for writing files
      LOGICAL KUS ! true if our station is listed for a procedure
      logical ku,kl,kul,kux,klx,kcomment
      integer ichanx,ibx,icx
C     integer itrax(2,2,max_headstack,max_chan) ! fanned-out version of itras
      integer IC,ICA,ierr,i,j,idummy,nch,ipass,icode,it,iv,nchx,
     .ilen,ich,ic1,ic2,ibuflen,itrk(max_track,max_headstack),
     .ig,irecbw,ir,idef,ival,
     .igotbbc(max_bbc),itrkrate,
     .npmode,itrk2(max_track,max_headstack),itype,ipig,
     .isbx,isb,ibit,ichan,ib,itrka,itrkb,nprocs,vc3_patch,vc10_patch
      logical kok,km3mode,km3be,km3ac,km4done,kpcal_d,kpcal,kroll,kcan
      logical kinclude,klast8,kfirst8,klsblo,knolo,kmodu
      logical knorack

C     real speed,spd
      real spdips
C     integer*2 lspd(4)
C     integer nspd
      CHARACTER*128 RESPONSE
      integer*2 LNAMEP(6)
      character*12 cnamep
      equivalence (lnamep,cnamep)

      logical kdone
      double precision DRF,DLO,DFVC
      character*2 cvc2k41(max_bbc)
      character*1 cvc2k42(max_bbc)
      character*1 cvchan(max_bbc)
      real fvc(max_bbc),fr,rfvc  !VC frequencies
      real rpc ! pc freq
      real samptest
      integer Z8000,Z4000,Z100
      integer igig,i1,i2,i3,i4,nco,ix,il,itpid_period_use
      integer iflch,ichcm_ch,ichmv_ch,iaddtr,iaddpc,iaddk4
      integer mhead              !2hd
      logical khead2active       !head2 is used?
      logical kallow_pig         !2hd
      logical kpiggy_km3mode     !2hd
      logical kk4vcab

      logical kgrp0,kgrp1,kgrp2,kgrp3,kgrp4,kgrp5,kgrp6,kgrp7

      character*28 cvpass
! JMG
      character*2 ccode
      integer*2   iccode
      equivalence (ccode,iccode)    !cheap trick to convert form Holerith to ascii
      character*4 cpmode
      integer*2 lpmode(2),lpmode2(2) ! mode for procedure names
      equivalence (cpmode,lpmode2(1))
      integer ntrack_rec         !number of tracks observed
      integer ntrack_rec_mk5
      integer im5trk_dup
      integer im5trk
      integer im5trk_vec(64)
      character*80 ldum

      data im5trk_vec/
     >2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,
     >3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33,
     >2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,
     >3,5,7,9,11,13,15,17,19,21,23,25,27,29,31,33/
!     >102,104,106,108,110,112,114,116,118,120,122,124,126,128,130,132,
!     >103,105,107,109,111,113,115,117,119,121,123,125,127,129,131,133/

C
C INITIALIZED VARIABLES:
      data ibuflen/80/
      data Z4000/Z'4000'/,Z100/Z'100'/,Z8000/Z'8000'/
      data cvpass /'abcdefghijklmnopqrstuvwxyzab'/
      data cvc2k41/'01','02','03','04','05','06','07','08',
     .             '09','10','11','12','13','14','15','16'/
      data cvc2k42/'1','2','3','4','5','6','7','8',
     .             '1','2','3','4','5','6','7','8'/
      data cvchan /8*'A',8*'B'/
      data crec/'1','2'/

      if (kmissing) then
        write(luscn,9101)
9101    format(/' PROCS00 - Missing or inconsistent head/track/pass',
     .  ' information.'/' Your procedures may be incorrect, or ',
     .  ' may cause a program abort.')
      endif

        if(cstrack(istn).eq. "unknown" .or.
     >     cstrec(istn) .eq. "unknown") then
        write(luscn,9102)
9102    format(/' PROCS01 - Rack or recorder type is unknown. Please',
     .  ' specify your '/
     .  ' equipment using Option 11 or the EQUIPMENT line in the ',
     .  ' control file.')
        return
      endif

      call init_hardware_common(istn)

      ir = 1
      if (kuse(2).and..not.kuse(1)) ir = 2

      knorack=cstrack(istn) .eq. "none" .or. cstrack(istn) .eq. "NONE"
      kk4vcab=.false.
      if ((kk41rack.or.kk42rack).and..not.km4fmk4rack) then
        if (nrecst(istn).eq.2) then
          if (kk41rec(1).and.kk42rec(2)) kk4vcab=.true.
          if (kk42rec(1).and.kk41rec(2)) kk4vcab=.true.
        endif
      endif

      WRITE(LUSCN,'( "Procedures for ",a)') cstnna(istn)
C
      call purge_file(prcname,luscn,luusr,kbatch,ierr)
      if(ierr .ne. 0) return

      luFile=lu_outfile
      itpid_period_use = itpid_period
      if (tpid_prompt.eq."YES") then ! get TPID period
        kdone = .false.
        do while (.not.kdone)
9932      write(luscn,9132) itpid_period
9132      format(' Enter TPI period in centiseconds (default is',
     .    i5,', 0 for OFF):  ',$)
          read(luusr,'(A)') response
          il=trimlen(response)
          if (il.eq.0) then ! default
            itpid_period_use = itpid_period
            kdone = .true.
          else ! decode it
            read(response,'(i10)',ERR=9932) ival
            if (ival.ge.0) then
              itpid_period_use = ival
              kdone = .true.
            else 
              write(luscn,'("Invalid period, must be >=0.")')
            endif
          endif ! default/decode
        enddo
      endif ! get TPID period

      WRITE(LUSCN,9113) PRCNAME(1:trimlen(prcname)), cstnna(istn)
9113  FORMAT(' PROCEDURE LIBRARY FILE ',A,' FOR ',a8)
      write(luscn,'(a)')
     >      ' NOTE: These procedures are for the following equipment:'
      write(luscn,'(3x,"Rack:       ",a8)')  cstrack(istn)
      write(luscn,     '(3x,"Recorder 1: ",a8)')  cstrec(istn)
      if(nrecst(istn) .eq. 2)
     >     write(luscn,'(3x,"Recorder 2: ",a8)')  cstrec2(istn)

      open(unit=LU_OUTFILE,file=PRCNAME,iostat=IERR)
      IF (IERR.ne.0) THEN
        WRITE(LUSCN,9131) IERR,PRCNAME(1:IC)
9131    FORMAT(' PROCS02 - Error ',I6,' creating file ',A)
        return
      END IF
      call procintr
! write short exper_init
      call proc_write_define(lu_outfile,luscn," ")  !this initializes this routine
      call proc_exper_initi(lu_outfile,luscn)
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
        iccode=lcode(icode)     !Get this into ccode
        call c2lower(ccode,ccode)

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

        kmodu =  .not.kvrack.and.cmodulation(istn,icode).eq.'on'

        kroll = .false.
        if (.not.(cbarrel(istn,icode) .eq. " " .or.
     >            cbarrel(istn,icode) .eq. "off " .or.
     >            cbarrel(istn,icode) .eq. "NONE")) then
          kroll = .true.
          kcan = .true.
         if (ichcm_ch(lbarrel(1,istn,icode),1,"M").eq.0) kcan = .false.

         if(km5p .or. km5) kroll=.false.
        endif ! a roll mode

        DO IPASS=1,NPASSF(istn,ICODE) !loop on number of sub passes

          do irec=1,nrecst(istn) ! loop on number of recorders
            if (kuse(irec)) then ! procs for this recorder
            itype=2
            if (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec)
     .       .or.km5prec(irec).or. km5rec(irec)) itype=1

            cnamep=" "
            call setup_name(itype,icode,ipass,lnamep)
            call proc_write_define(lu_outfile,luscn,cnamep)

            call trkall(itras(1,1,1,1,ipass,istn,icode),
     >        lmode(1,istn,icode), itrk,lpmode,npmode,ifan(istn,icode))
            lpmode2(1)=lpmode(1)
            lpmode2(2)=lpmode(2)

            call c2lower(cpmode,cpmode)

            km3mode=cpmode(1:1).ge."a".and. cpmode(1:1).le."e"
            km3be=  cpmode(1:1).eq."b".or.  cpmode(1:1).eq."e"
            km3ac=  cpmode(1:1).eq."a".or.  cpmode(1:1).eq."c"
c-----------make sure piggy for mk3 on mk4 terminal too--2hd---
            kpiggy_km3mode =km3mode  !2hd mk3 on mk5  !------2hd---

            if(kmk5_piggyback)kpiggy_km3mode=.false.  !------2hd---
            if(km5) kpiggy_km3mode= .false.           !no piggyback for Mark5

c.. also no pig if 2nd head is set-----------------------2hd---
            kallow_pig=.true.
            do i=2,33
              if (itrk(i,2) .eq. 1)kallow_pig=.false.
            enddo
C Find out if any channel is LSB, to decide what procedures are needed.
            klsblo=.false.
            DO ichan=1,nchan(istn,icode) !loop on channels
              ic=invcx(ichan,istn,icode) ! channel number
              if (freqrf(ic,istn,icode).lt.freqlo(ic,istn,icode))
     >         klsblo=.true.
            enddo

          if(km5 .or. km5p) then
             ntrack_rec=num_tracks_rec(itras(1,1,1,1,ipass,istn,icode))
             call proc_mk5_init1(ntrack_rec,ntrack_rec_mk5,luscn,ierr)
             if(ierr .ne. 0) return
          endif

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
        if (nrecst(istn).gt.1.and.krec_append) then ! dual drives
          if (kvrec(irec).or.km3rec(irec).or.km4rec(irec).or.
     .        kv4rec(irec).or.ks2rec(irec).or.kk41rec(irec).or.
     .        kk42rec(irec)) then 
            write(lu_outfile,'("select=",a1)') crec(irec)
            write(lu_outfile,'("drive",a1)') crec(irec)
          endif
        endif ! dual drives

C  PCALON or PCALOFF
          if (kpcal) then
            write(lu_outfile,'(a)') 'pcalon'
          else
            write(lu_outfile,'(a)') 'pcaloff'
          endif

C  TPICD=STOP
          write(lu_outfile,'(a)') 'tpicd=stop'

          if (kvrec(irec).or.km3rec(irec).or.km4rec(irec)
     .      .or.kv4rec(irec).or.km5prec(irec) .or. km5rec(irec)) then ! all these for ....
C  PCALD=STOP
            if (kpcal_d) then
              write(lu_outfile,'(a)') 'pcald=stop'
            endif
c..debug:check if 2nd head active, i.e. hd posns are set
          khead2active=.false.
          do i=1,max_pass !2hd
            if (ihdpos(2,i,istn,icode).ne.9999)khead2active=.true.       !2hd
          enddo !2hd
C  TAPEFffm
          if (km3rec(irec).or.km4rec(irec).or.kvrec(irec)
     .           .or.kv4rec(irec)) then ! no TAPEFORM for mk5
            call snap_tapef(ccode,cpmode)
C  PASS=$,SAME
            if (km3rec(irec).or.km4rec(irec).or.kv4rec(irec) .and.
     >          .not.khead2active) then
              call snap_pass('=$,same')
            else if(km4rec(irec).or.kv4rec(irec).and.khead2active) then
               call snap_pass('=$,mk4')
            else
               call snap_pass('=$')
            endif
          endif  ! no TAPEFORM for mk5
C  TRKFffmp
C  Also write trkf for Mk3 modes if it's an 8 BBC station or LSB LO
c..2hd..if piggy make sure mk3 modes are written
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km5prec(irec).or.km5rec(irec).or.
     .      km4rec(irec).or.kk41rec(irec).or.kk42rec(irec)) then
            if ((km4rack.or.kvrack.or.kv4rack.or.kk41rack.or.kk42rack)
     .          .and.(.not.kpiggy_km3mode.or.
     .          klsblo.or.((km3ac.or.km3be).and.k8bbc))) then
              call name_trkf(cnamep,ccode,cpmode,cvpass(ipass:ipass))
              write(lufile,'(a)') cnamep
            endif
C  PCALFff
            if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
              call snap_pcalf(ccode)
            endif
C  ROLLFORMff
            if (kroll.and..not.kcan) then ! non-canned roll
              if (km4rack.or.kvrack.or.kv4rack.or.km4fmk4rack) then
                call snap_rollform(ccode)
              endif
            endif ! non-canned roll
          endif
C  TRACKS=tracks   
C  Also write tracks for Mk3 modes if it's an 8 BBC station or LSB LO
          if (km5) then
            if(ntrack_rec_mk5 .eq. 8) then
               write(lu_outfile,'(a)') "tracks=v0"
            else if(ntrack_rec_mk5 .eq. 16) then
               write(lu_outfile,'(a)') "tracks=v0,v2"
            else if(ntrack_rec_mk5 .eq. 32) then
               write(lu_outfile,'(a)') "tracks=v0,v1,v2,v3"
            else if(ntrack_rec_mk5 .eq. 64) then
               write(lu_outfile,'(a)')
     >           "tracks=v0,v1,v2,v3,v4,v5,v6,v7,v82"
            endif
          else if(kvrack.or.km4form.and.
     .           (.not.kpiggy_km3mode.or.klsblo.or.
     .           ((km3ac.or.km3be).and.k8bbc)) ) then
            do ipig=1,2 ! twice for piggyback
              if (ipig.eq.1.or.
     >           (ipig .eq. 2 .and. km4rack .and.
     >             ((km5_piggyback .and. kallow_pig) .or.
     >              (km5prec(irec) .and. km4rack   )) ))  then
C               use second headstack for Mk5
C         copy of the track table in itrk2
                do i=1,max_track
                  itrk2(i,1)=itrk(i,1)
                  itrk2(i,2)=itrk(i,2)
                enddo
                call ifill(ibuf,1,ibuflen,oblank)
! head1
! ...find marked groups and zero them in 2nd copy of track table, put "V0" etc as appropriate.
                if(ipig .eq. 1) then
                  NCH = ichmv_ch(IBUF,1,'TRACKS=')
                  call ChkGrpAndZeroWrite(itrk, 2,16,1,'V0',
     >              itrk2,kgrp0,ibuf,nch)
                  call ChkGrpAndZeroWrite(itrk, 3,17,1,'V1',
     >              itrk2,kgrp1,ibuf,nch)
                  call ChkGrpAndZeroWrite(itrk,18,32,1,'V2',
     >              itrk2,kgrp2,ibuf,nch)
                  call ChkGrpAndZeroWrite(itrk,19,33,1,'V3',
     >               itrk2,kgrp3,ibuf,nch)
              else if(ipig .eq. 2) then
                  NCH = ichmv_ch(IBUF,1,'TRACKS=*,')
                  call ChkGrpAndZeroWrite(itrk, 2,16,1,'V4',
     >               itrk2,kgrp0,ibuf,nch)
                  call ChkGrpAndZeroWrite(itrk, 3,17,1,'V5',
     >               itrk2,kgrp1,ibuf,nch)
                  call ChkGrpAndZeroWrite(itrk,18,32,1,'V6',
     >               itrk2,kgrp2,ibuf,nch)
                  call ChkGrpAndZeroWrite(itrk,19,33,1,'V7',
     >               itrk2,kgrp3,ibuf,nch)
              endif
! head2
              call ChkGrpAndZeroWrite(itrk, 2,16,2,'V4',
     >             itrk2,kgrp4,ibuf,nch)
              call ChkGrpAndZeroWrite(itrk, 3,17,2,'V5',
     >             itrk2,kgrp5,ibuf,nch)
              call ChkGrpAndZeroWrite(itrk,18,32,2,'V6',
     >             itrk2,kgrp6,ibuf,nch)
              call ChkGrpAndZeroWrite(itrk,19,33,2,'V7',
     >             itrk2,kgrp7,ibuf,nch)

c.. do  m0-m3
              if(ipig .eq. 1) then
                if(.not.kgrp0) call ChkGrpAndZeroWrite(itrk,
     >                   4, 16,1,'M0', itrk2,kgrp0,ibuf,nch)
                if(.not.kgrp1) call ChkGrpAndZeroWrite(itrk,
     >                   5, 17,1,'M1', itrk2,kgrp1,ibuf,nch)
                if(.not.kgrp2) call ChkGrpAndZeroWrite(itrk,
     >                   18,30,1,'M2', itrk2,kgrp2,ibuf,nch)
                if(.not.kgrp3) call ChkGrpAndZeroWrite(itrk,
     >                   19,31,1,'M3', itrk2,kgrp3,ibuf,nch)
              else if(ipig .eq. 2) then
                if(.not.kgrp0) call ChkGrpAndZeroWrite(itrk,
     >                   4, 16,1,'M4', itrk2,kgrp0,ibuf,nch)
                if(.not.kgrp1) call ChkGrpAndZeroWrite(itrk,
     >                   5, 17,1,'M5', itrk2,kgrp1,ibuf,nch)
                if(.not.kgrp2) call ChkGrpAndZeroWrite(itrk,
     >                   18,30,1,'M6', itrk2,kgrp2,ibuf,nch)
                if(.not.kgrp3) call ChkGrpAndZeroWrite(itrk,
     >                   19,31,1,'M7', itrk2,kgrp3,ibuf,nch)
              endif
! 2nd head
              if(.not.kgrp4) call ChkGrpAndZeroWrite(itrk,
     >                   4, 16,2,'M4', itrk2,kgrp4,ibuf,nch)
              if(.not.kgrp5) call ChkGrpAndZeroWrite(itrk,
     >                   5, 17,2,'M5', itrk2,kgrp5,ibuf,nch)
              if(.not.kgrp6) call ChkGrpAndZeroWrite(itrk,
     >                   18,30,2,'M6', itrk2,kgrp6,ibuf,nch)
              if(.not.kgrp7) call ChkGrpAndZeroWrite(itrk,
     >                   19,31,2,'M7', itrk2,kgrp7,ibuf,nch)

C  Now pick up leftover tracks that didn't appear in a whole group
C  and list each one separately.
              do j=1,2  !go through once for each headstack.
                do i=2,33
                  if (itrk2(i,j).eq.1) then
                    if (ipig.eq.1) then
                      nch = nch + ib2as(i,ibuf,nch,Z8000+2)
                    else
                       nch = nch + ib2as(i+100,ibuf,nch,Z8000+3)
                    endif
                    nch = MCOMA(IBUF,nch)
                  endif
                enddo
              end do

              NCH = NCH-1
              CALL IFILL(IBUF,NCH,1,oblank)
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
            endif ! second time for piggyback
            enddo ! twice for piggyback
            endif ! kvrack.or.km4rack.or.kv4rack and .not. km3mode
          endif ! all these for only km3rec km4rec kvrec kv4rec km5prec
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
            if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
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
            if (krec_append      ) nchx = ichmv_ch(ibuf,nchx,crec(irec))
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
            call snap_data_valid('=off')
          endif ! ks2rec
C REC_MODE=<mode> for K4
C !* to mark the time
          if (kk42rec(irec).or.kk41rec(irec)) then ! K4 recorder
            call snap_rec('=synch_on')
            if (kk42rec(irec)) then ! type 2 rec_mode
              irecbw = 16.0*samprate(icode)
              if(krec_append) then
                 write(ldum,'("rec_mode",a1,"=",i3)') crec(irec), irecbw
              else
                 write(ldum,'("rec_mode=",i3)') irecbw
              endif
              call squeezewrite(lu_outfile,ldum)
              write(lu_outfile,'("!*")')
            endif ! type 2 rec_mode
C  RECPff
C           No RECP procedure if it's a Mk3 mode.
            if ((km4rack.or.kvrack.or.kv4rack.or.kk41rack.or.kk42rack)
     .       .and. (.not.kpiggy_km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then
              call snap_recp(ccode)
            endif
          endif ! K4 recorder
C  NONE rack gets comments
          if (knorack) then ! none rack comments
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'"Channel  Sky freq  LO freq  video')
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            DO ichan=1,nchan(istn,icode) !loop on channels
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(ibuf,1,'"    ')
              ic=invcx(ichan,istn,icode) ! channel number
              nch = nch + ib2as(ic,ibuf,nch,Z4000+2*Z100+2) 
              nch = nch + 3
              fr = FREQRF(ic,istn,ICODE) ! sky freq
              if (freqrf(ic,istn,icode).gt.100000.d0) then
                igig=freqrf(ic,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqrf(ic,istn,icode)-igig*100000.d0
              endif
              NCH = nch + IR2AS(fr,IBUF,nch,8,2)
              nch = nch + 3
              fr = FREQLO(ic,istn,ICODE) ! sky freq
              if (freqLO(ic,istn,icode).gt.100000.d0) then
                igig=freqLO(ic,istn,icode)/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=freqLO(ic,istn,icode)-igig*100000.d0
              endif
              NCH = nch + IR2AS(fr,IBUF,nch,8,2)
              nch = nch + 3
              DLO = freqlo(ic,istn,icode) ! lo freq
              DRF = FREQRF(ic,istn,ICODE) ! sky freq
              rFVC = abs(DRF-DLO)   ! BBCfreq = RFfreq - LOfreq
              NCH = nch + IR2AS(rFVC,IBUF,nch,8,2)
              if (DRF-DLO .lt. 0.d0) nch = ichmv_ch(ibuf,nch+1,"LSB")
              call hol2lower(ibuf,(nch+1))
              CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
            enddo ! loop on channels
          endif ! none rack comments

C  BBCffb, IFPffb  or VCffb
          if (km3rack.or.km4rack.or.kvrack.or.kv4rack.or.
     .        kk41rack.or.kk42rack.or.klrack) then
            call ifill(ibuf,1,ibuflen,oblank)
            if (kvrack.or.kv4rack) nch = ichmv_ch(IBUF,1,'BBC')
            if (klrack) nch = ichmv_ch(IBUF,1,'IFP')
            if (km3rack.or.km4rack.or. kk41rack.or.kk42rack)
     >        nch = ichmv_ch(IBUF,1,'VC')
            nch = ichmv(ibuf,nch,lcode(icode),1,nco)
            CALL M3INF(ICODE,SPDIPS,IB)
            NCH=ICHMV(ibuf,NCH,LBNAME,IB,1)
            if (kk4vcab.and.krec_append      ) 
     .      nch=ichmv_ch(ibuf,nch,crec(irec))
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif ! kvrack or km3rac.or.km4rackk .or. any k4rack
C  TRKFffmp for LBA rack +s2 recorder
          if (klrack.and.ks2rec(irec)) then
            call name_trkf(cnamep,ccode,cpmode,cvpass(ipass:ipass))
            write(lufile,'(a)') cnamep
          endif ! klrack.and.ks2rec
C  IFDff
          if (km3rack.or.km4rack.or.kvrack.or.kv4rack.or.
     .        kk41rack.or.kk42rack.or.klrack) then
            call snap_ifd(ccode)
          endif ! kvrack or km3rac.or.km4rackk
C  PCALD=
          if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
            write(lu_outfile,'(a)') 'pcald='
          endif

C  FORM=m,r,fan,barrel,modu   (m=mode,r=rate=2*b) 
C  For S2, leave out command entirely
C  For 8-BBC stations, use "M" for Mk3 modes
          if (kvrack.or.km3rack.or.km4rack.or.kv4rack
     .          .or.km4fmk4rack.or.kk3fmk4rack) then
            if(ks2rec(irec) .or. kk41rec(irec) .or. kk42rec(irec)) then
               continue                 !leave out command
            else
C           if (km3rec(irec).or.km4rec(irec).or.kvrec(irec).or.
C    .        kv4rec(irec)) then
              call ifill(ibuf,1,ibuflen,oblank)
              nch = ichmv_ch(IBUF,1,'form=')
              if (kpiggy_km3mode) then
                if ((klsblo.and.(kv4rack.or.kvrack.or.km4rack
     .            .or.km4fmk4rack))
     .            .or.k8bbc.and.(km3be.or.km3ac)) then
                   nch = ichmv_ch(ibuf,nch,'m')
                elseif ((kvrack.or.km3rack.or.kk3fmk4rack).and.
     .            ichcm_ch(lmode(1,istn,icode),1,'e').eq.0) THEN
C                   MODE E = B ON ODD, C ON EVEN PASSES
                  IF (MOD(IPASS,2).EQ.0) THEN
                    nch = ichmv_ch(ibuf,nch,'c')
                  ELSE
                    nch = ichmv_ch(ibuf,nch,'b')
                  ENDIF
                else ! not mode E or else Mk4 formatter
                   nch = ICHMV(IBUF,nch,lmode(1,istn,icode),1,1)
                endif
              else ! not Mk3 mode
C             Use format from schedule, 'v' or 'm'
C              nch = ICHMV(IBUF,nch,lmFMT(1,istn,icode),1,1)
C             Don't use the format from the schedule but use the one
C             appropriate for the type of equipment, m or v.
                if (kvrack) then ! add format to FORM command
                  nch = ICHMV_ch(IBUF,nch,'v')
                else if (kv4rack.or.km4rack.or.km4fmk4rack) then
                  nch = ICHMV_ch(IBUF,nch,'m')
                else
                  write(luscn,9138)
9138              format(/'PROCS08 - WARNING! Non-Mk3 modes are not',
     .            ' supported by your station equipment.')
                endif ! add format to FORM command
              endif
C           Add group index for Mk4 formatter
C           ... but not for LSB case
            if (km4form .and.kpiggy_km3mode.and..not.klsblo.and.
     .        ichcm_ch(lmode(1,istn,icode),1,'a').ne.0) then !
              if (ichcm_ch(lmode(1,istn,icode),1,'e').eq.0) THEN ! add group
                if(kCheckGrpOr(itrk,2,16,1)) then
                  ig=1
                else if(kCheckGrpOr(itrk,3,17,1)) then
                  ig=2
                else if(kCheckGrpOr(itrk,18,32,1)) then
                  ig=3
                else if(kCheckGrpOr(itrk,19,33,1)) then
                  ig=4
                endif
                nch = nch+ib2as(ig,ibuf,nch,1) ! mode E group
              else ! add subpass number
                nch = nch+ib2as(ipass,ibuf,nch,1) ! mode B or C subpass
              endif
            endif ! add group or subpass
C           Add sample rate
            nch = MCOMA(IBUF,nch)
            nch = nch+IR2AS(samprate(ICODE),IBUF,nch,6,3)
            if (.not.ks2rec(irec)) then ! non-S2 only
C           If no fan, or if fan is 1:1, skip it unless we have roll
C           or modulation.
            if ((ifan(istn,icode).ne.0.and.ifan(istn,icode).ne.1) .or.
     .         kroll.or.kmodu) then ! barrel or fan or modulation
              nch = MCOMA(IBUF,nch)
C             Put in fan only if non-zero
              if (ifan(istn,icode).ne.0) then ! fan
                nch = ichmv_ch(ibuf,nch,'1:')
                nch = nch+ib2as(ifan(istn,icode),ibuf,nch,1)
              endif
C             Roll parameter
              if (kroll) then
C               if (kvrack) then ! only for VLBA racks
C               Now ok for Mk4 formatters too
                if (kvrack.or. km4form) then
                  nch = MCOMA(IBUF,nch)
                  nch = ichmv(ibuf,nch,lbarrel(1,istn,icode),1,4)
                  if (kvrack.and.
     .                ichcm_ch(lbarrel(1,istn,icode),1,"M").ne.0) then
                    if (ichcm_ch(lbarrel(1,istn,icode),1,"8:1").eq.0.or.
     .                  ichcm_ch(lbarrel(1,istn,icode),1,"16:1").eq.0) 
     .                  then ! already there
                     else ! add the :1 for VLBA racks
                       nchx = iflch(ibuf,nch)
                       nch = ichmv_ch(ibuf,nchx+1,":1")
                     endif ! already there/add
                   endif
C                else if (kv4rack.or.km4rack.or.km4fmk4rack) then
C                  write(luscn,9137) 
C9137              format(/'PROCS05 - WARNING! Barrel roll is not',
C     .            ' supported for Mark IV formatters.')
                endif
              endif ! roll
              if (kmodu) then ! modulation
                nch = iflch(ibuf,nch)+1
                if (.not.kroll) then ! insert comma
                  nch = MCOMA(IBUF,nch)
                endif ! insert comma
                nch = MCOMA(IBUF,nch)
                nch = ichmv_ch(ibuf,nch,'on')
              endif ! modulation
            endif ! barrel or fan or modulation
            endif ! non-S2 only
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(nch+1)/2)
          endif
          endif ! kv4rack.or.kvrack or km3rac.or.km4rack but not S2 or K4

          if(km5) then
!             write(lu_outfile,'(!+2s)')
             call proc_mk5_init2(ifan(istn,icode),
     >             samprate(1),ntrack_rec_mk5,luscn,ierr)
              if(ierr .ne. 0) return
          endif

C  FORM=RESET
          if (km3rack.and..not.ks2rec(irec).and. .not.
     >         (km5rec(irec) .or.
     >          (km5prec(irec) .and. .not. kmk5_piggyback))) then
            write(lu_outfile,'(a)') 'form=reset'
          endif
C  !*
          if (kvrack.and..not.
     >       (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then
             write(lu_outfile,'(a)') '!*'
          endif
C  TPICD=no,period
          if (km3rack.or.km4rack.or.kvrack.or.kv4rack) then
            call snap_tpicd("no",itpid_period_use)
          endif
C  BIT_DENSITY=
          if ((kv4rec(irec).or.kvrec(irec)).and..not.ks2rec(irec)) then ! bit_density
            ibit=bitdens(istn,icode)
            call snap_bit_density(ibit)
          endif
C  SYSTRACKS=
          if (kvrec(irec).or.kv4rec(irec)) then ! for all VLBA recorders
            call snap_systracks(" ")
          endif
C  TAPE=LOW
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call snap_tape("=low")
          endif
C  ENABLE=tracks 
C  Remember that tracks are VLBA track numbers in itrk.
          itrka=0
          itrkb=0
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            NCH = ichmv_ch(IBUF,1,'ENABLE')
            if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            NCH = ichmv_ch(IBUF,nch,'=')
            if (kvrec(irec).or.kv4rec(irec)) then ! group-only enables for VLBA recorders
              if(kCheckGrpOr(itrk,2,16,1)) then
                itrka=6
                itrkb=8
                nch = ichmv_ch(ibuf,nch,'G0,')
              endif
              if(kCheckGrpOr(itrk,3,17,1)) then
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=7
                  itrkb=9
                else
                  itrkb=9
                endif
                nch = ichmv_ch(ibuf,nch,'G1,')
              endif
              if(kCheckGrpOr(itrk,18,32,1)) then
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=20
                  itrkb=22
                else
                  itrkb=22
                endif
                nch = ichmv_ch(ibuf,nch,'G2,')
              endif
              if(kCheckGrpOr(itrk,19,33,1)) then
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=21
                  itrkb=23
                else
                  itrkb=23
                endif
                nch = ichmv_ch(ibuf,nch,'G3,')
              endif
            else if (km3rec(irec)) then ! group enables plus leftovers
              do i=1,max_track          ! Make a copy of the track table.
                itrk2(i,1)=itrk(i,1)
              enddo
! check if group g1 is present. If so, write it out.
              call ChkGrpAndZeroWrite(itrk, 4,16,1,'G1',
     >             itrk2,kgrp1,ibuf,nch)
               if(kgrp1) then
                  if (itrka.eq.0.and.itrkb.eq.0) then
                    itrka=3 ! Mk3 track number
                    itrkb=5
                  endif
               endif
! ditto fo g2
               call ChkGrpAndZeroWrite(itrk, 5,17,1,'G2',
     >             itrk2,kgrp2,ibuf,nch)
               if(kgrp2) then
                  if (itrka.eq.0.and.itrkb.eq.0) then
                    itrka=4
                    itrkb=6
                  else
                    itrkb=6
                  endif
               endif
! ... for g3
               call ChkGrpAndZeroWrite(itrk, 18,30,1,'G3',
     >               itrk2,kgrp3,ibuf,nch)
               if(kgrp3) then
                  if (itrka.eq.0.and.itrkb.eq.0) then
                    itrka=17
                    itrkb=19
                  else
                    itrkb=19
                  endif
               endif

               call ChkGrpAndZeroWrite(itrk, 19,31,1,'G4',
     >               itrk2,kgrp4,ibuf,nch)
               if(kgrp4) then
                  if (itrka.eq.0.and.itrkb.eq.0) then
                    itrka=18
                    itrkb=20
                  else
                    itrkb=18
                  endif
               endif
C         Then list any  tracks still left in the table.
              do i=4,31 ! pick up leftover Mk3 tracks not in a whole group
                if (itrk2(i,1).eq.1) then ! Mark3 numbering
                  nch = nch + ib2as(i-3,ibuf,nch,Z8000+2)
                  nch = MCOMA(IBUF,nch)
                endif
              enddo ! pick up leftover tracks
            else if (km5rec(irec).or.km5prec(irec).or.km4rec(irec)) then ! stack enables
              kok=.false.
              do i=2,33 ! if any tracks are on, enable the stack
                if (itrk(i,1).eq.1) then
                  kok=.true.
                  if (itrka.ne.0.and.itrkb.eq.0) itrkb=i
                  if (itrka.eq.0) itrka=i
                endif
              enddo
              nch = ichmv_ch(ibuf,nch,'S1,')
c.....2-head
              kok=.false.
              if(khead2active) then
                do i=2,33 ! if any tracks are on, enable the stack
                  if (itrk(i,2).eq.1) then
                    kok=.true.
                  endif
                enddo
                if(kok)then
                  nch = ichmv_ch(ibuf,nch,'S2,')
                endif
              endif
c... end 2-head
            endif
            NCH = NCH-1
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,(nch+1))
            CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
          endif
C REPRO=byp,itrka,itrkb,equalizer,bitrate   Mk3/4
C REPRO=byp,itrka,itrkb,equalizer,,,bitrate   VLBA,VLBA4
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec).and..not.ks2rec(irec)) then
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(IBUF,1,'repro')
            if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(IBUF,nch,'=byp,')
            nch = nch+ib2as(itrka,ibuf,nch,Z8000+2)
            nch = MCOMA(IBUF,nch)
            nch = nch+ib2as(itrkb,ibuf,nch,Z8000+2)
            if (km4rec(irec).or.kv4rec(irec).or.kvrec(irec)) then ! bitrate
              if (ifan(istn,icode).gt.0) then
                itrkrate = samprate(icode)/ifan(istn,icode)
              else
                itrkrate = samprate(icode)
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
              write(lu_outfile,'(a)') 'checkcrc'
            endif
          endif ! decode commands
C !*+8s for VLBA formatter
          if (kvrack.and..not.ks2rec(irec).
     .     and..not.kk41rec(irec).and..not.kk42rec(irec)) then ! formatter wait
            write(lu_outfile,"('!*+8s')")
          endif
C !*+20s for K4 type 2 recorder
          if (kk42rec(irec)) then ! formatter wait
            write(lu_outfile,"('!*+20s')")
          endif
C  PCALD
            if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
              write(lu_outfile,'(a)') 'pcald'
            endif
C  TPICD always issued
            write(lu_outfile,'(a)')  'tpicd'
            write(lu_outfile,"(a)") 'enddef'

          endif ! procs for this recorder
        enddo ! loop on number of recorders
      ENDDO ! loop on number of passes
C
C Now continue with procedures that are code-based only.
! Debug JMG
!      goto 9000

C 3. Write out the baseband converter frequency procedure.
C Name is VCffb or BBCffb or IFPffb      (ff=code,b=bandwidth)
C Contents: VCnn=freq,bw,tpisel or BBCnn=freq,if,bw,bw
C   or IFPnn=freq,br,mode,flipU,flipL,encode
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
     .        kk41rack.or.kk42rack.or.klrack) then
            
          CALL IFILL(LNAMEP,1,12,oblank)
          if(kvrack .or. kv4rack) then
              nch = ichmv_ch(LNAMEP,1,'BBC')
          else if (km3rack.or.km4rack.or.kk41rack.or.kk42rack)  then
              nch = ichmv_ch(LNAMEP,1,'VC')
          else if (klrack) then
            nch = ichmv_ch(LNAMEP,1,'IFP')
          endif
          nch = ICHMV(LNAMEP,nch,LCODE(ICODE),1,nco)
          CALL M3INF(ICODE,SPDIPS,IB)
          NCH=ICHMV(LNAMEP,NCH,LBNAME,IB,1)
          if (kk4vcab.and.krec_append)
     >       nch=ichmv_ch(lnamep,nch,crec(irec))
          call proc_write_define(lu_outfile,luscn,cnamep)
C
          kfirst8 = .false.
          klast8  = .false.
          if(k8bbc.and.(cpmode(1:1).eq."a".or.cpmode(1:1).eq."c"))then
            write(luscn,"(/,a)")
     >       " This is a Mode A or C experiment at an 8-BBC station."
            kdone = .false.
            do while (.not.kdone)
              write(luscn,'(a)') " Do you want the first 8 channels",
     >                           "or the last 8 recorded (F/L) ? "
              read(luusr,'(A)') response
              response(1:1) = upper(response(1:1))
              kdone = response(1:1).eq.'F'.or.response(1:1).eq.'L'
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
              ica=ic
              do i=ichan+1,nchan(istn,icode)
                if (ibbcx(invcx(i,istn,icode),istn,icode).eq.ib)
     .            ica=invcx(i,istn,icode)
              enddo
              if (FREQRF(ic,istn,ICODE).gt.FREQRF(ica,istn,ICODE)) then
                i = ic
                ic = ica
                ica = i
              endif
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
                if (klrack) then
                  if (ic.eq.ica) then
C                     use centreband filters where possible
                    if (ichcm_ch(lnetsb(ic,istn,ICODE),1,'L').eq.0) then
                      DRF = FREQRF(ic,istn,ICODE)
     .                      - VCBAND(ic,istn,ICODE) / 2.0
                    else
                      DRF = FREQRF(ic,istn,ICODE)
     .                      + VCBAND(ic,istn,ICODE) / 2.0
                    endif
                  else if (FREQRF(ic,istn,ICODE).eq.
     .                           FREQRF(ica,istn,ICODE)) then
C                     must be simple double sideband ie. L+U
                    if (lnetsb(ic,istn,ICODE).ne.lnetsb(ica,istn,ICODE))
     .                write(luscn,9900) ic,ica
9900                  format(/'PROCS00 - WARNING! Sideband',
     .                ' definitions for channels ',i2,' and ',
     .                i2,' conflict!')
                  else
C                     different frequencies must differ by bandwidth
                    if ((FREQRF(ica,istn,ICODE)-FREQRF(ic,istn,ICODE))
     .              .ne.VCBAND(ic,istn,ICODE))
     .                write(luscn,9901) ic,ica,ib
9901                  format (/'PROCS01 - WARNING! Channels ',i2,' and ',
     .                i2,' define IFP ',i2,' differently!')
C                     and one or other sideband must be flipped ie L+L or U+U
                    if (lnetsb(ic,istn,ICODE).ne.lnetsb(ica,istn,ICODE))
     .                write(luscn,9900) ic,ica
                    if (ichcm_ch(lnetsb(ic,istn,ICODE),1,'L').eq.0)
     .              then
C                     L+L is produced via L + flipped U
                      DRF = FREQRF(ic,istn,ICODE)
                    else
C                     U+U is produced via flipped L + U
                      DRF = FREQRF(ica,istn,ICODE)
                    endif
                  endif
                endif ! klrack
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
                if (km3rack.or.km4rack.or.kvrack.or.kv4rack
     .          .or.klrack) then
                  if (kvrack.or.kv4rack) nch = ichmv_ch(ibuf,1,'BBC')
                  if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'VC')
                  if (klrack) nch = ichmv_ch(ibuf,1,'IFP')
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
!                idummy=ichmv(linp(ic),1,lifinp(ic,istn,icode),1,2)
                if (kk41rack.or.kk42rack) then
                   kok=cifinp(ic,istn,icode)(1:1) .ge. "1" .and.
     >                 cifinp(ic,istn,icode)(1:1) .le. "3"
!                   kok=cinp(ic) .ge. "1" .and. cinp(ic) .le. "3"
!                  if(ichcm_ch(linp(ic),1,'1').eq.0 .or.
!     .               ichcm_ch(linp(ic),1,'2').eq.0.or.
!     .               ichcm_ch(linp(ic),1,'3').eq.0) kok=.true.
                endif
                if (km3rack.or.km4rack) then
                  kok=cifinp(ic,istn,icode) .eq. "1N" .or.
     >                cifinp(ic,istn,icode) .eq. "2N" .or.
     >                cifinp(ic,istn,icode) .eq. "3N" .or.
     >                cifinp(ic,istn,icode) .eq. "3I" .or.
     >                cifinp(ic,istn,icode) .eq. "3O" .or.
     >                cifinp(ic,istn,icode) .eq. "1A" .or.
     >                cifinp(ic,istn,icode) .eq. "2A" .or.
     >                cifinp(ic,istn,icode) .eq. "3A"
                endif
                if (kvrack.or.kv4rack) then
                   kok=cifinp(ic,istn,icode)(1:1) .ge. "A" .and.
     >                 cifinp(ic,istn,icode)(1:1) .le. "D"
                endif
                if (klrack) then
                   kok=cifinp(ic,istn,icode)(1:1) .ge. "1" .and.
     >                 cifinp(ic,istn,icode)(1:1) .le. "4"
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
                if ((kvrack).and..not.kok) write(luscn,9909)
     .            lifinp(ic,istn,icode)
9909              format(/'PROCS04 - WARNING! IF input ',a2,' not',
     .            ' consistent with VLBA rack.')
                if ((klrack).and..not.kok) write(luscn,9929)
     .            lifinp(ic,istn,icode)
9929              format(/'PROCS04 - WARNING! IF input ',a2,' not',
     .            ' consistent with LBA rack.')
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
                if ((klrack).and.
     .            (rfvc.lt.0.0.or.rfvc.gt.192.0)) 
     .            write(luscn,9914) ib,rfvc
9914              format(/'PROCS03 - WARNING! IFP ',i2,' frequency '
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
C               TPI selection
                if (km3rack.or.km4rack) then 
                  NCH = MCOMA(IBUF,NCH)
C                 itras(sideband,bit,head,channel,subpass,station,code)
                  ku = itras(1,1,1,ic,1,istn,icode).ne.-99  
     .            .or.  itras(1,1,2,ic,1,istn,icode).ne.-99  ! head 2
                  kl = itras(2,1,1,ic,1,istn,icode).ne.-99
     .            .or.  itras(2,1,2,ic,1,istn,icode).ne.-99  ! head 2
C                 Find other channels that this BBC goes to.
                  DO ichanx=ic,nchan(istn,icode) !remaining channels
                    icx=invcx(ichanx,istn,icode) ! channel number
                    ibx=ibbcx(icx,istn,icode) ! BBC number
                    if (ibx.eq.ib) then ! same BBC
                      kux = itras(1,1,1,icx,1,istn,icode).ne.-99
     .                 .or.  itras(1,1,2,icx,1,istn,icode).ne.-99
                      klx = itras(2,1,1,icx,1,istn,icode).ne.-99
     .                 .or.  itras(2,1,2,icx,1,istn,icode).ne.-99
                      kul = ku.and.klx .or. kux.and.kl 
                    endif
                  enddo
                  if (ku.and..not.kul) nch = ichmv_ch(ibuf,nch,'u')
                  if (kl.and..not.kul) nch = ichmv_ch(ibuf,nch,'l')
                  if (kul) nch = ichmv_ch(ibuf,nch,'ul')
                endif
                if (kvrack.or.kv4rack.or.klrack) then
                  NCH = MCOMA(IBUF,NCH)
                  if (kk42rec(irec)) then
                    nch = ichmv_ch(ibuf,nch,'16.0') ! max for K42 rec
                  else
                    NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,
     .                     NCH,6,3)
                  endif
                endif
                if (klrack) then
                  NCH = MCOMA(IBUF,NCH)
                  if (ic.eq.ica) then
                    nch = ichmv_ch(ibuf,nch,'SCB') ! for single centreband filter
                  else
                    nch = ichmv_ch(ibuf,nch,'DSB') ! for double sideband filter
                  endif
                  NCH = MCOMA(IBUF,NCH)
                  if ((ichcm_ch(lnetsb(ica,istn,ICODE),1,'L').ne.0
     .                .and. (.not.klsblo)) .or. (klsblo .and.
     .                (ichcm_ch(lnetsb(ica,istn,ICODE),1,'L').eq.0)))
     .            then
                    nch = ichmv_ch(ibuf,nch,'NAT')
                  else
                    nch = ichmv_ch(ibuf,nch,'FLIP')
                  endif
                  NCH = MCOMA(IBUF,NCH)
                  if (ic.ne.ica) then
C                     Normally LSB so login inverts
                    if ((ichcm_ch(lnetsb(ic,istn,ICODE),1,'L').eq.0
     .                  .and. (.not.klsblo)) .or. (klsblo .and.
     .                  (ichcm_ch(lnetsb(ic,istn,ICODE),1,'L').ne.0)))
     .              then
                      nch = ichmv_ch(ibuf,nch,'NAT')
                    else
                      nch = ichmv_ch(ibuf,nch,'FLIP')
                    endif
                  endif
                  NCH = MCOMA(IBUF,NCH)
                  nch = ichmv(ibuf,nch,ls2data(1,istn,icode),1,
     .            iflch(ls2data(1,istn,icode),8))
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
            write(lu_outfile,"('!+1s')")
            write(lu_outfile,'(a)') 'valarm'
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
          write(lu_outfile,"(a)") 'enddef'

        endif ! vrack or m3rack
        endif ! do this
        enddo ! loop on recorders
!      goto 9000
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
C    for LBA:   lo=same as Mk3 ( but allow up to 4 IFs)
C Later: add a check of patching to determine how the IF3 switches
C should really be set. 
C         if (VC3  is LOW) switch 1 = 1, else 2
C         if (VC11 is LOW) switch 2 = 1, else 2

        if (km3rack.or.km4rack.or.kvrack.or.kv4rack.or.
     .     kk41rack.or.kk42rack.or.klrack) then ! 
          CALL IFILL(LNAMEP,1,12,oblank)
          IDUMMY = ichmv_ch(LNAMEP,1,'IFD')
          IDUMMY = ICHMV(LNAMEP,4,LCODE(ICODE),1,nco)
          call proc_write_define(lu_outfile,luscn,cnamep)
C
          do i=1,max_bbc
            igotbbc(i)=0
          enddo
          if (km3rack.or.km4rack .or. kk41rack.or.kk42rack
     .    .or. klrack) then 
C                        m3rack IFD, LO, PATCH, SIDEBAND
C                        k4rack LO, PATCH
C                        lrack LO
C           First find out which IFs are in use for this code
            i1=0
            i2=0
            i3=0
            i4=0
            do i=1,nchan(istn,icode) ! which IFs are in use
              ic=invcx(i,istn,icode) ! channel number
              if (i1.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'1')
     .          .eq.0) i1=ic
              if (i2.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'2')
     .          .eq.0) i2=ic
              if (i3.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'3')
     .          .eq.0) i3=ic
              if (i4.eq.0.and.ichcm_ch(lifinp(ic,istn,icode),1,'4')
     .          .eq.0) i4=ic
            enddo ! which IFs are in use
C IFD command
            if (km3rack.or.km4rack ) then ! mk3/4 IFD
              call ifill(ibuf,1,ibuflen,oblank)
              NCH = ichmv_ch(IBUF,1,'ifd=')
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
                  NCH = ichmv_ch(IBUF,1,'if3=,') ! default atn is now null
                  IF (ichcm_ch(lifinp(i3,istn,ICODE),2,'O').EQ.0) THEN
                    NCH = ichmv_ch(IBUF,NCH,'out,')
                  ELSE ! must be 'I' or 'N'
                    NCH = ichmv_ch(IBUF,NCH,'in,')
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
                  CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
                ENDIF ! IF3 exists, write the command
              else ! always write it
C               NCH = ichmv_ch(IBUF,1,'IF3=atn3,')
                if (i3.ne.0) then ! IF3 is in use, add "in"
                  if(freqlo(i3,istn,icode) .eq.
     >               freqlo(i1,istn,icode)) then           !if lo3=lo1, then out, else in.
                    NCH = ichmv_ch(IBUF,1,'if3=,out,')
                  else
                    NCH = ichmv_ch(IBUF,1,'if3=,in,')
                  endif
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
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
                endif ! IF3 is in use
! JMG End.
              endif ! we know/don't know about IF3
            endif ! mk3/4 IFD
C
C LO command for Mk3/4 and K4 and LBA
C           First reset all
            call ifill(ibuf,1,ibuflen,oblank)
            if (klrack) nch = ichmv_ch(ibuf,1,'lo=')
            if (kk41rack.or.kk42rack) nch = ichmv_ch(ibuf,1,'lo=')
            if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'lo=')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            do i=1,4 ! up to 4 LOs
              call ifill(ibuf,1,ibuflen,oblank)
              if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'lo=lo')
              if (kk41rack.or.kk42rack) nch = ichmv_ch(ibuf,1,'lo=lo')
              if (klrack) nch = ichmv_ch(ibuf,1,'lo=lo')
              if (i.eq.1) ix=i1
              if (i.eq.2) ix=i2
              if (i.eq.3) ix=i3
              if (i.eq.4) ix=i4
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
                else if(kgeo) then
! JMG 2002Dec30:   Add ,rcp,1 for geodetic schedules.
                   nch=ichmv_ch(ibuf,nch,",rcp,1")
! End JMG 2002Dec30
                endif ! have pol and pcal
                call hol2lower(ibuf,nch)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
              endif ! this LO in use
            enddo ! up to 4 LOs
          endif
C
C PATCH command for Mk3/4 and K4
C           First reset all
          if (km3rack.or.km4rack .or. kk41rack.or.kk42rack) then
            call ifill(ibuf,1,ibuflen,oblank)
            if (km3rack.or.km4rack) nch = ichmv_ch(ibuf,1,'patch=')
            if (kk41rack.or.kk42rack) nch = ichmv_ch(ibuf,1,'patch=')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            DO I=1,3 ! up to three Mk3/4, K4 IFs need a patch command
              if (i.eq.1.and.i1.gt.0.or.i.eq.2.and.i2.gt.0.or.
     .            i.eq.3.and.i3.gt.0) then ! this LO in use
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
            write(lu_outfile,'(a)') 'ifdab=0,0,nor,nor'
            write(lu_outfile,'(a)') 'ifdcd=0,0,nor,nor'
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
            write(lu_outfile,'(a)') 'lo='

            do i=1,4
              call ifill(ibuf,1,ibuflen,oblank)
              NCH = ichmv_ch(IBUF,1,'lo=lo')
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
                else if(kgeo) then
                  nch=ichmv_ch(ibuf,nch,",rcp,1")
                endif ! have pol and pcal
                call hol2lower(ibuf,nch)
                CALL writf_asc(LU_OUTFILE,IERR,IBUF,(NCH+1)/2)
              endif ! this LO in use
            enddo
          endif ! vlba IFD, LO commands
          write(lu_outfile,"(a)") 'enddef'

      endif ! km3rack .or.km4rack or kvrac.or.kv4rackk
!      goto 9000
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
          if (krec_append      ) nch = ichmv_ch(lnamep,nch,crec(irec))
          call proc_write_define(lu_outfile,luscn,cnamep)

          call ifill(ibuf,1,ibuflen,oblank)
          nch = ichmv_ch(ibuf,1,'TAPEFORM')
          if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
          nch = ichmv_ch(ibuf,nch,'=')
      do mhead=1,max_headstack               !2hd
          do i=1,max_pass
cdg            if (ihdpos(1,i,istn,icode).ne.9999) then    
            if (ihdpos(mhead,i,istn,icode).ne.9999) then       !2hd
cdg              nch = nch + ib2as(i,ibuf,nch,3) ! pass number
              nch = nch + ib2as((i+100*(mhead-1)),ibuf,nch,3) ! pass number hd
              nch = mcoma(ibuf,nch)
cdg              nch = nch + ib2as(ihdpos(1,i,istn,icode),ibuf,nch,4) ! offset
              nch = nch + ib2as(ihdpos(mhead,i,istn,icode),ibuf,nch,4) ! offset hd
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
              if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
              nch = ichmv_ch(ibuf,nch,'=')
              ib=0
            endif
          enddo
      enddo  !2hd end headstack loop
          if (ib.gt.0) then ! finish last line
            nch=nch-1
            CALL IFILL(IBUF,NCH,1,oblank)
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          endif
          write(lu_outfile,"(a)") 'enddef'

        endif
        endif ! procs for this recorder
      enddo ! loop on recorders
 !     goto 9000
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
     .        .or.km5prec(ir).or.km5rec(ir)
     .        .or.kk41rec(ir).or.kk42rec(ir).or.ks2rec(ir)) then
        if (((km4rack.or.kvrack.or.kv4rack.or.kk41rack.or.kk42rack).and.
     .       (.not.kpiggy_km3mode.or.klsblo
     >             .or.((km3be.or.km3ac).and.k8bbc))).or.
     .      (klrack.and.ks2rec(ir))) then
          DO IPASS=1,NPASSF(istn,ICODE) !loop on subpasses
            call trkall(itras(1,1,1,1,ipass,istn,icode),
     >      lmode(1,istn,icode),  itrk,lpmode,npmode,ifan(istn,icode))
            im5trk_dup=ntrack_rec_mk5-ntrack_rec            !This is the number of passes to duplicate.
            im5trk=0
            if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)
     .        .or.km5prec(ir).or.km5rec(ir).or.ks2rec(ir)) then
!              goto 9000
              call name_trkf(cnamep,ccode,cpmode,cvpass(ipass:ipass))
            else if (kk41rec(ir).or.kk42rec(ir)) then
              write(cnamep,"('recp',A)") lcode(icode)
            endif
            call proc_write_define(lu_outfile,luscn,cnamep)
!            goto 9000

            call ifill(ibuf,1,ibuflen,oblank)
            if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)
     .        .or.km5prec(ir).or.km5rec(ir).or.ks2rec(ir)) then
              nch = ichmv_ch(ibuf,1,'TRACKFORM=')
            endif
            if (kk41rec(ir).or.kk42rec(ir)) then
              nch = ichmv_ch(ibuf,1,'RECPATCH')
              if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(ir))
              nch = ichmv_ch(ibuf,nch,'=')
            endif
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            do ipig=1,2 ! twice through for piggyback mode
            if (ipig.eq.1.or.(ipig.eq.2 .and. km4rack .and.
     >              (kmk5_piggyback .or. km5prec(ir)))) then
C                 use second headstack for Mk5
              if (ipig.eq.2) then ! initialize buffer
                 call ifill(ibuf,1,ibuflen,oblank)
                 nch = ichmv_ch(ibuf,1,'trackform=')
              endif ! initialize buffer
              ib=0
              DO ichan=1,nchan(istn,icode) !loop on channels
                ic=invcx(ichan,istn,icode) ! channel number
                do mhead =1,max_headstack !2hd hedzz
                  do isb=1,2 ! sidebands
                    do ibit=1,2 ! bits
                      it=itras(isb,ibit,mhead,ic,ipass,istn,icode)    !2hd
                      if (it.ne.-99) then ! assigned
C                   Use BBC number, not channel number
                       ib=ibbcx(ic,istn,icode) ! BBC number
                       kinclude=.true.
                       if(k8bbc) then
                         if (km3be) then
                         ib=ichan
                       else if (km3ac) then
                         if (kfirst8) then
                           ib=ichan
                           if (ib.gt.8) kinclude=.false.
C                          Write out a max of 8 channels for 8-BBC stations
                         else if (klast8) then
                           ib=ichan-6
                           if (ib.le.0) kinclude=.false.
                         endif
                       endif
                      endif
                      if (kinclude) then
                        isbx=isb
                        klsblo=freqrf(ic,istn,icode).lt.
     >                         freqlo(ic,istn,icode)
                        if (klsblo) then ! reverse sidebands
                        if (isb.eq.1) isbx=2
                        if (isb.eq.2) isbx=1
                      endif ! reverse sidebands
                      if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.
     .                   km4rec(ir).or.km5prec(ir).or.km5rec(ir)) then
                         if (mhead .eq. 2.or.ipig.eq.2)then               !2hd
                           if((it+3) .lt.10)nch=ichmv_ch(ibuf,nch,'10') !2hd
                           if((it+3) .ge.10)nch=ichmv_ch(ibuf,nch,'1') !2hd
                         endif               !2hd
                         if(km5) then
                           im5trk=im5trk+1
                           nch = iaddtr(ibuf,nch,
     >                        im5trk_vec(im5trk), ib,isbx,ibit)
                           if(im5trk_dup .gt. 0) then
                              im5trk_dup =im5trk_dup-1
                              im5trk=im5trk+1
                              nch = iaddtr(ibuf,nch,
     >                          im5trk_vec(im5trk), ib,isbx,ibit)
                           endif
                         else
                           nch = iaddtr(ibuf,nch,it+3,ib,isbx,ibit)
                         endif
                      else if (ks2rec(ir)) then
                         nch = iaddtr(ibuf,nch,it+2,ib,isbx,ibit)
                      else if (kk41rec(ir).or.kk42rec(ir)) then
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
C In Mk5 piggybackmode write the same line again with 100 added to
C the track number.
C These lines
C trackform=2,1us,6,2us,10,3us,14,4us,18,5us,22,6us,26,7us,3,8us
C trackform=7,9us,11,10us,15,11us,19,12us,23,13us,27,14us
C become 
C trackform=102,1us,106,2us,110,3us,114,4us,118,5us,122,6us,126,7us,103,8us
C trackform=107,9us,111,10us,115,11us,119,12us,123,13us,127,14us
                    call ifill(ibuf,1,ibuflen,oblank)
                    if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.
     >                km4rec(ir).or.km5prec(ir).or.km5rec(ir).or.
     >                ks2rec(ir)) then
                      nch = ichmv_ch(ibuf,1,'TRACKFORM=')
                    endif
                    if (kk41rec(ir).or.kk42rec(ir)) then
                      nch = ichmv_ch(ibuf,1,'RECPATCH')
                      if (krec_append) nch = ichmv_ch(ibuf,nch,crec(ir))
                      nch = ichmv_ch(ibuf,nch,'=')
                    endif
                    ib=0
                  endif
                enddo ! bits
              enddo ! sidebands
      enddo !2hd loop on hedzz
            enddo ! loop on channels
            if (ib.ne.0) then ! final line
              nch=nch-1
              CALL IFILL(IBUF,NCH,1,oblank)
              call hol2lower(ibuf,nch)
              call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            endif
            endif ! second time for piggyback mode
         enddo ! twice through for piggyback mode
            write(lu_outfile,"(a)") 'enddef'
           
          enddo ! loop on sub-passes
        endif ! km4rack.or.kvrack.or.kv4rack
      endif ! kvrec.or.kv4rec.or.km3rec.or.km4rec
!      goto 9000

C 7. Write PCALF procedure.
C    pcalform=bbc-sb,tone,tone,...
C These procedures do not depend on the type of recorder.
C The check for recorder type is included only so that the
C same logic can be used for TRKF and RECP.
C Therefore, use index 1 for all the tests in this section.

      if (kpcal_d) then 
      if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)
     .  .or.km5prec(ir).or.km5rec(ir)) then
        if ((km4rack.or.kvrack.or.kv4rack).and.
     .      (.not.kpiggy_km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then

          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'PCALF')
          nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco) ! code
          call proc_write_define(lu_outfile,luscn,cnamep)
C PCALFORM=
          write(lu_outfile,'(a)') 'pcalform='
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
          write(lu_outfile,"('enddef')")
        endif ! km4rack.or.kvrack.or.kv4rack
      endif ! kvrec.or.kv4rec.or.km3rec.or.km4rec
      endif ! only vex knows pcal


C 8. Write ROLLFORM procedures, one per pass.
C    rollform=head,home,<list of tracks>
C These procedures do not depend on the type of recorder.
C Therefore, use the index of the recorder in use for all the tests 
C in this section.
C If barrel roll is "M" then write these procedures. Not needed for
C the canned "8" or "16" roll tables.
C    
      if (km4rack.or.kvrack.or.kv4rack.or.km4fmk4rack) then
        if (ichcm_ch(lbarrel(1,istn,icode),1,"M").eq.0) then ! manual roll
          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'ROLLFORM')
          nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco) ! code
          call proc_write_define(lu_outfile,luscn,cnamep)
C ROLLFORM=
          write(lu_outfile,'(a)') 'rollform='
C ROLLFORM commands
          DO idef = 1,nrolldefs(istn,icode) ! loop on roll defs
            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'ROLLFORM=') 
            do it=1,2+nrollsteps(istn,icode)
              nch = nch + ib2as(iroll_def(it,idef,istn,icode),ibuf,
     .              nch,Z4000+2*Z100+2) ! tracks
              if (it.ne.2+nrollsteps(istn,icode)) nch = mcoma(ibuf,nch)
            enddo
            call hol2lower(ibuf,nch)
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
          enddo ! loop on roll defs
          write(lu_outfile,"(a)") 'enddef'

        endif ! manual roll
      endif ! km4rack.or.kvrack.or.kv4rack.or.km4fmk4rack

C  End of major loop for each code
      endif ! this mode defined
!      write(luscn,'()')
      ENDDO ! loop on codes

C 9. Write out standard tape loading and unloading procedures

C UNLOADER procedure
      do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec) .and. .not.(km5prec(irec).or.km5rec(irec))) then ! not for Mk5
          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'UNLOADER')
          if (krec_append      ) nch = ichmv_ch(lnamep,nch,crec(irec)) 
          call proc_write_define(lu_outfile,luscn,cnamep)
          if (ks2rec(irec)) then
            call snap_et()
            call snap_rec('=eject')
          else if (kk41rec(irec).or.kk42rec(irec)) then
            call snap_rec('=eject')
            write(lu_outfile,"('!+10s')")

            call ifill(ibuf,1,ibuflen,oblank)
            nch = ichmv_ch(ibuf,1,'oldtape')
            if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=$')
            call writf_asc(lu_outfile,ierr,ibuf,(nch+1)/2)
            write(lu_outfile,"('!+20s')")
          else if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            write(lu_outfile,"('!+5s')")

            call snap_enable()
            call snap_tape('=off ')

            if (kvrec(irec).or.kv4rec(irec)) then
              call snap_rec('=unload')
            endif
            if (km3rec(irec).or.km4rec(irec)) then
              call snap_st('=rev,80,off ')
            endif
          endif
C       endif ! non-empty proces for single recorder
        write(lu_outfile,"('enddef')")
        endif ! procs for this recorder
      enddo ! loop on recorders
     
C LOADER procedure
      do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec)) then ! procs for this recorder
          if (.not.(km5prec(irec).or.km5rec(irec))) then ! not for Mk5
          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'LOADER')
          if (krec_append      ) nch = ichmv_ch(lnamep,nch,crec(irec))
          call proc_write_define(lu_outfile,luscn,cnamep)
          if (ks2rec(irec)) then
            call snap_rw()
            write(lu_outfile,"('!+10s')")
            call snap_et()

            write(lu_outfile,"('!+3s')")
            call snap_tape('=reset')
          endif
          if (kk41rec(irec).or.kk42rec(irec)) then
            write(lu_outfile,"('!+25s')")
            call snap_tape('=reset')
            write(lu_outfile,"('!+6s')")
          endif

          if (kvrec(irec).or.kv4rec(irec)) then
            call snap_rec('=load')
            write(lu_outfile,"('!+10s')")
            call snap_tape('=low,reset')
          endif
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call snap_st('=for,135,off ')
C jfq  loader now winds on 200ft for thin tapes !!
            if (maxtap(istn).gt.17000) then
              write(lu_outfile,"('!+22s')")
            else
              write(lu_outfile,"('!+11s')")
            endif
C jfq ends
            call snap_et()
            write(lu_outfile,"('!+3s')")
          endif
          write(lu_outfile,"(a)") 'enddef'

        endif ! not for Mk5
        endif ! procs for this recorder
      enddo ! loop on recorders

C MOUNTER procedure
      if (krec_append) then ! only for 2-rec stations
       do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec)) then ! procs for this recorder
          CALL IFILL(LNAMEP,1,12,oblank)
          nch = ichmv_ch(LNAMEP,1,'mounter')
          if (krec_append      ) nch = ichmv_ch(lnamep,nch,crec(irec))
          call proc_write_define(lu_outfile,luscn,cnamep)
          if (kvrec(irec).or.kv4rec(irec)) then
             call snap_rec('=load')
          endif ! non-empty only for VLBA/4
          write(lu_outfile,"(a)") 'enddef'
          
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
              call proc_write_define(lu_outfile,luscn,cnamep)
              CALL GTSNP(ICH,ILEN,IC1,IC2,kcomment)
              DO WHILE (IC1.NE.0) ! get and write commands
                call ifill(ibuf2,1,ibuflen,oblank)
                NCH = ICHMV(IBUF2,1,IBUF,IC1,IC2-IC1+1)
                if (.not.kcomment) call hol2lower(ibuf2,nch)
                call writf_asc(LU_OUTFILE,IERR,IBUF2,NCH/2)
                CALL GTSNP(ICH,ILEN,IC1,IC2,kcomment)
              ENDDO ! get and write commands
              write(lu_outfile,"('enddef')")

            ENDIF ! write proc file
          ENDIF ! a proc for us
          CALL READS(LU_INFILE,IERR,IBUF,ISKLEN,ILEN,2)
        ENDDO ! read $PROC section
      ENDIF ! procedures

9000  continue
      call proc_write_define(-1,luscn," ")  !this flushes a buffer.
      CLOSE(LU_OUTFILE,IOSTAT=IERR)
      call drchmod(prcname,iperm,ierr)
      write(luscn,'()')
C
      RETURN
      END

