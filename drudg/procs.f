        SUBROUTINE PROCS

C PROCS writes procedure file for the Field System.
C Version 9.0 is supported with this routine.

      include 'hardware.ftni'           !common block containing info on hardware
      include 'drcom.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'
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
C 2003Sep04 JMGipson. Added postob_mk5a for mark5a modes.
! 2004Sep13 JMGipson Following rule for formater:
!           If named mark3 mode, use form=m,....
!           Else use formatter.
! 2004Nov16 Itras changed to give Mark4 Track number. Required minor change here.
!           No longer need to add 3 to track number.
! 2006May02 HAndle case when LO1 is not defined, but LO3 is.
! 2006May30 In SETUP, moved BBC and IFD commands to after form=.
! 2006Jun16 See 2004Nov16 Note.  But now need to subtract 3 for K4 recorders.
! 2006Jun21 if freqrf is negative, don't do BBC or if commands.
!           Also got rid of some more Hollerith stuff.
! 2006Jul18 Got rid of hol2lower/writf_asc pairs. Replaced with call to lowercase_and_write.
! 2006Jul18 Handle IFDAB,IFDAC and LO in Seshan case (Some rfsky<0, indicating not there.)
! 2006Jul20 Fixed bug when changing from Mark3 recorder to Mark5.  Mode should remain Mark3.
! 2006Jul27 If bbcs are present but not used, set unused BBCs to highest recorded frequency
! 2006Sep26 changed lmode,lpmode to ascii in call to trkall.
! 2006Oct17 Changed order of IFP and TRKF command for LBA
! 2006Nov30 Use cstrec(istn,irec) instead of 2 different arrays
! 2007May28 JMG Added suport for Mark5B.
! 2007Jun19 JMG Added logical flags to test if had BBC, IFDs, VCs
! 2007Jul05 JMG. Added variable ifd(1:4). IFD(j)>0 means ifd(J) is in use.
! 2007Jul7-19.  Broke up into many subroutines.
! 2007Jul10 JMG. Added logical ktrf
! 2007Jul27 JMG. Changed itype to logical knopass, put in hardware.ftni, and moved initializaiton
!           to init_hardware_common
! 2007Nov05 JMG. Took out postob_mk5  command.
! 2008OCt20 JMG. Modified so would do TPI command for Mark5 racks

C Called by: FDRUDG
C Calls: TRKALL,IADDTR,IADDPC,IADDK4,SET_TYPE,PROCINTR

! Functions
      character upper     
      integer ib2as,mcoma,trimlen ! functions
      integer iroll_def

C LOCAL VARIABLES:
C     integer itrax(2,2,max_headstack,max_chan) ! fanned-out version of itras
      integer IC,ierr,i,nch,ipass,icode,it
      integer irecbw,ir,idef,ival
      integer npmode
      integer ibit,ichan,nprocs
      logical kpcal_d,kpcal
      logical kroll             !barrel roll on
      logical kman_roll         !manual barrel roll on

C     real speed,spd
C     integer*2 lspd(4)
C     integer nspd
      CHARACTER*128 RESPONSE
      character*12 cnamep
      character*12 cname_vc
      character*12 cname_ifd

      logical kdone
      real fvc(max_bbc)
      real fvc_lo(max_bbc),fvc_hi(max_bbc)

      real samptest
      integer Z4000,Z100
      integer il,itpid_period_use
      logical khead2active       !head2 is used?
      logical kk4vcab

      character*1 cvpass(28)
      character*28 cvpassTmp
      equivalence (cvpass,cvpassTmp)
      character*2 codtmp
      integer*2   icodtmp
      equivalence (codtmp,icodtmp)     	!cheap trick to convert form Holerith to ascii
      character*4 cpmode                !mode for procedure names  
      integer num_chans_obs         	!number of channels observer
      integer num_tracks_rec_mk5        !number we record=num obs * ifan
      character*80 ldum
      integer ifan_fact                 !identical to ifan(,) unless ifan(,)=0, in which case this is 1.
      integer num_sub_pass              !number of passes we loop on.
                                        !For mark5 mode this is 1. For other recorders is npassf
      integer NumTracks
      character*5 lform                 !Mark4 or VLBA
      logical kin2net_on                !Is in2net on?

      logical ktrkf                     !write out trf procedure?
      character*1 lwhich8               ! which8 BBCs used: F=first, L=last

C
C INITIALIZED VARIABLES:
      data Z4000/Z'4000'/,Z100/Z'100'/
      data CvpassTmp /'abcdefghijklmnopqrstuvwxyzab'/

      if (kmissing) then
        write(luscn,9101)
9101    format(/' PROCS00 - Missing or inconsistent head/track/pass',
     .  ' information.'/' Your procedures may be incorrect, or ',
     .  ' may cause a program abort.')
      endif

      if(cstrack(istn).eq. "unknown" .or.
     >   cstrec(istn,1) .eq. "unknown") then
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

      ic=trimlen(prcname)
      WRITE(LUSCN,"(' PROCEDURE LIBRARY FILE ',A,' FOR ',a8)")
     >   PRCNAME(1:ic), cstnna(istn)

      write(luscn,'(a)')
     >      ' NOTE: These procedures are for the following equipment:'
      write(luscn,'(3x,"Rack:       ",a8)')  cstrack(istn)
      write(luscn,     '(3x,"Recorder 1: ",a8)')  cstrec(istn,1)
      if(nrecst(istn) .eq. 2)
     >     write(luscn,'(3x,"Recorder 2: ",a8)')  cstrec(istn,2)

      open(unit=LU_OUTFILE,file=PRCNAME,iostat=IERR)
      IF (IERR.ne.0) THEN
        WRITE(LUSCN,9131) IERR,PRCNAME(1:IC)
9131    FORMAT(' PROCS02 - Error ',I6,' creating file ',A)
        return
      END IF
      call procintr
! write short exper_init
      call proc_write_define(lu_outfile,luscn," ")  !this initializes this routine

      kin2net_on=.false.
      if(.not. kno_data_xfer .and.
     >  ((.not. Kin2net_2_disk2file .and. kstat_in2net(istn)) .or.
     >  (Kdisk2file_2_in2net .and. kstat_disk2file(istn)))) then
         kin2net_on=.true.
      endif

      call proc_exper_initi(lu_outfile,luscn,kin2net_on)

!      if(km5disk) call proc_postob_mk5(lu_outfile,luscn)
C
C 2. Set up the loop over all frequency codes, and the
C    inner loop over the number of passes.
C    Generate the procedure name, then write into proc file.
C    Get the track assignments first, and the mode name to use
C    for procedure names.

      DO ICODE=1,NCODES !loop on codes
      if (nchan(istn,icode).gt.0) then ! this mode defined
        nprocs=0
        codtmp=ccode(icode)
        call c2lower(codtmp,codtmp)

        kpcal = .true.    ! on/off switch, default is on for non-VEX files
        kpcal_d = .false. ! detection or not
        if (kvex) then ! check for on/off
          kpcal = .false.
          do ic=1,nchan(istn,icode)
            if(freqpcal(ic,istn,icode) .gt.0) kpcal = .true.
            if(npctone(ic,istn,icode)  .ne.0) kpcal_d =.true.
          end do
        endif ! check for on/off

        kroll = .false.
        kman_roll = .false.   !default is canned roll.
        if(km5disk) then
           continue
        else if (.not.(cbarrel(istn,icode) .eq. " " .or.
     >            cbarrel(istn,icode) .eq. "off " .or.
     >            cbarrel(istn,icode) .eq. "NONE")) then
          kroll = .true.
          kman_roll=cbarrel(istn,icode)(1:1) .eq. "M"
        endif ! a roll mode

! don't have sub-passes for mk5-mode
        num_sub_pass=npassf(istn,icode)
        if(num_sub_pass.gt.1.and.km5disk) num_sub_pass=1

        DO IPASS=1,num_sub_pass  !loop on number of sub passes
        do irec=1,nrecst(istn) ! loop on number of recorders
          if (.not.kuse(irec)) goto 300   !Go to end of loop.

          call setup_name(icode,ipass,cnamep)
          call proc_write_define(lu_outfile,luscn,cnamep)

          if((ks2rec(irec) .and. klrack) .or. .not. ks2rec(irec)) then
            call trkall(ipass,istn,icode,
     >          cmode(istn,icode), itrk,cpmode,npmode,ifan(istn,icode))
          else
                cmode(istn,icode)="S2"
          endif

          call c2lower(cpmode,cpmode)

          km3mode=cpmode(1:1).ge."a".and. cpmode(1:1).le."e"
          km3be=  cpmode(1:1).eq."b".or.  cpmode(1:1).eq."e"
          km3ac=  cpmode(1:1).eq."a".or.  cpmode(1:1).eq."c"
c-----------make sure piggy for mk3 on mk4 terminal too--2hd---
          kpiggy_km3mode =km3mode               !2hd mk3 on mk5  !------2hd---

          if(km5p_piggy .or. km5A_piggy .or. km5disk)
     >       kpiggy_km3mode=.false.

          if(k8bbc.and.(cpmode(1:1).eq."a".or.cpmode(1:1).eq."c"))then
            write(luscn,"(/,a)")
     >        " This is a Mode A or C experiment at an 8-BBC station."
            lwhich8=" "
            do while (lwhich8 .ne. "F" .or. lwhich8 .ne. "L")
              write(luscn,'(a)')
     >          " Do you want the first or last 8 channels(F/L) ? "
              read(luusr,'(A)') lwhich8
              lwhich8 = upper(lwhich8)
            end do
          endif

C Find out if any channel is LSB, to decide what procedures are needed.
          klsblo=.false.
          DO ichan=1,nchan(istn,icode) !loop on channels
            ic=invcx(ichan,istn,icode) ! channel number
            if (abs(freqrf(ic,istn,icode)).lt.freqlo(ic,istn,icode))
     >         klsblo=.true.
          enddo

          ktrkf =
     >    ((kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)      ! Valid recorders
     >      .or. Km5Disk.or.kk41rec(ir).or.kk42rec(ir)))
     >     .and.
     >     ((km4rack.or.kvracks.or.kk41rack.or.kk42rack).and.        ! Valid rack types.
     >       (.not.kpiggy_km3mode  .or.Km5A_piggy .or.klsblo         ! valid "modes"
     >       .or.((km3be.or.km3ac).and.k8bbc)))
     >      .or. (ks2rec(ir) .and. klrack)


          if(km5disk .or. km5A_piggy .or. km5P_piggy) then
            ifan_fact=max(1,ifan(istn,icode))
            call find_num_chans_rec(ipass,istn,icode,
     >            ifan_fact,num_chans_obs,num_tracks_rec_mk5)
            NumTracks=num_chans_obs*ifan_fact
            if(NumTracks .gt. 32) then
              if(km5p) then
                write(luscn,'(/,a,i3)')
     >           "PROCS10 - Can only record 32 tracks in MK5P mode. "//
     >           "Tried to record: ",numTracks
                return
              else if(Km5ApigWire(1).or.Km5APigWire(2)) then
                write(luscn,'(/,a,i3)')
     >          "PROCS11 - Can only record 32 tracks in MK5APigwire "//
     >          " mode. Tried to record: ",numTracks
                return
              endif
            endif
            call proc_mk5_init1(num_chans_obs,num_tracks_rec_mk5,
     >            luscn,ierr)
            if(ierr .ne. 0) return
          endif
C
C 3. Write out the following lines in the setup procedure:
C
C Setup name for IFADJUST data base reference.
C SETUP_NAME=experiment

C SELECT=A/B
C DRIVEA/B
          if(nrecst(istn).gt.1.and.krec_append) then ! dual drives
            if (kvrec(irec).or.km3rec(irec).or.km4rec(irec).or.
     .          kv4rec(irec).or.ks2rec(irec).or.kk41rec(irec).or.
     .          kk42rec(irec)) then
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

          if (kvrec(irec).or.kv4rec(irec)
     >       .or.km3rec(irec).or.km4rec(irec) .or.Km5disk) then
C  PCALD=STOP
            if (kpcal_d)  write(lu_outfile,'(a)') 'pcald=stop'
c check if 2nd head active, i.e. hd posns are set
            khead2active=.false.
            do i=1,max_pass !2hd
              if (ihdpos(2,i,istn,icode).ne.9999)khead2active=.true.       !2hd
            enddo !2hd
C  TAPEFffm
            if(.not.km5disk) then ! no TAPEFORM for mk5
              call proc_tapef_name(codtmp,cpmode,cnamep)
              write(lu_outfile,'(a)') cnamep

C  PASS=$,SAME
              if((km3rec(irec).or.km4rec(irec).or.kv4rec(irec)) .and.
     >           .not.khead2active) then
                 call snap_pass('=$,same')
              else if((km4rec(irec).or.kv4rec(irec))
     >                 .and.khead2active)then
                 call snap_pass('=$,mk4')
               else
                 call snap_pass('=$')
               endif
            endif  ! no TAPEFORM for mk5
C  TRKFffmp
C  Also write trkf for Mk3 modes if it's an 8 BBC station or LSB LO
c..2hd..if piggy make sure mk3 modes are written
            if(ktrkf .and. .not. klrack) then !For LBA, write trkf latter
              call name_trkf(codtmp,cpmode,cvpass(ipass),cnamep)
              write(lufile,'(a)') cnamep
            endif
C  PCALFff
             if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
               call snap_pcalf(codtmp)
             endif
C  ROLLFORMff
            if(ktrkf .and. kman_roll .and.
     >         (km4rack.or.kvracks.or.km4fmk4rack)) then
                call snap_rollform(codtmp)
            endif ! non-canned roll
C  TRACKS=tracks
C  Also write tracks for Mk3 modes if it's an 8 BBC station or LSB LO
            call proc_tracks(icode,num_tracks_rec_mk5)
          endif ! all these for only km3rec km4rec kvrec kv4rec km5prec

! Output S2 Mode stuff.
          if (ks2rec(irec)) then ! S2 mode
            call proc_s2_comments(icode,kroll)
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
            if ((km4rack.or.kvracks.or.kk41rack.or.kk42rack)
     .       .and. (.not.kpiggy_km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then
              call snap_recp(codtmp)
            endif
          endif ! K4 recorder
C  NONE rack gets comments
          if(cstrack(istn).eq."none" .or.cstrack(istn).eq."NONE") then
            call proc_norack(icode)
          endif ! none rack comments
C  PCALD=
          if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
            write(lu_outfile,'(a)') 'pcald='
          endif

C  FORM=m,r,fan,barrel,modu   (m=mode,r=rate=2*b)
C  For S2, leave out command entirely
C  For 8-BBC stations, use "M" for Mk3 modes
          if((kvracks.or.km3rack.or.km4rack
     >          .or.km4fmk4rack.or.kk3fmk4rack) .and. .not.
     >        (ks2rec(irec) .or. kk41rec(irec) .or. kk42rec(irec))) then
              call proc_form(icode,ipass,kroll,kman_roll,lform)
          endif ! kvracks or km3rac.or.km4rack but not S2 or K4

C  BBCffb, IFPffb  or VCffb
          if (kbbc .or. kifp .or. kvc) then
            call proc_vcname(kk4vcab,      !Make the VC procedure name.
     >        ccode(icode),vcband(1,istn,icode),cname_vc)

            write(lu_outfile,'(a)') cname_vc
!  TRKFffmp for LBA rack +s2 recorder.  Must come after IFPffb commmand.
            if (ks2rec(irec)) then
              call name_trkf(codtmp,cpmode,cvpass(ipass),cnamep)
              write(lufile,'(a)') cnamep
            endif ! klrack.and.ks2rec
            cname_ifd="ifd"//codtmp
            writE(lu_outfile,'(a)') cname_ifd
          endif ! kbbc kvc kfid

C  FORM=RESET
          if (km3rack.and..not.(ks2rec(irec).or. km5Disk))then
            write(lu_outfile,'(a)') 'form=reset'
          endif
C  !*
          if (kvrack.and..not.
     >       (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then
             write(lu_outfile,'(a)') '!*'
          endif

C  TPICD=no,period
          if (km3rack.or.km4rack.or.kvracks.or.km5rack.or.kv5rack) then
            call snap_tpicd("no",itpid_period_use)
          endif

C  BIT_DENSITY=
C  SYSTRACKS=
          if (kv4rec(irec).or.kvrec(irec)) then ! bit_density & SYSTRACK
            ibit=bitdens(istn,icode)
            call snap_bit_density(ibit)
            call snap_systracks(" ")
          endif
C  TAPE=LOW
C  ENABLE=tracks
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec)) then
            call snap_tape("=low")
            call proc_enable_repro(icode,khead2active)
          endif
C DECODE=a,crc
C replaced with CHECKCRC station-specific procedure
          if ((kv4rack.or.km3rack.or.km4rack).and..not.
     .       (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then ! decode commands
            samptest = samprate(icode)
            if (ifan(istn,icode).gt.0)
     .        samptest=samptest/ifan(istn,icode)
            if (samptest.lt.7.5) then ! no double speed decoding
              write(lu_outfile,'(a)') 'checkcrc'
            endif
          endif ! decode commands
C !*+8s for VLBA formatter
          if (kvrack.and..not.
     >      (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then ! formatter wait
            write(lu_outfile,"('!*+8s')")
          endif

          if(km5disk .or. km5A_piggy) then
            call proc_mk5_init2(lform,ifan(istn,icode),
     >             samprate(icode),num_tracks_rec_mk5,luscn,ierr)
            if(ierr .ne. 0) return
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
          write(lu_outfile,'(a)') "tpicd"
          if(km5a .or. km5a_piggy) write(lu_outfile,'(a)') "mk5=mode?"
          write(lu_outfile,'(a)') "enddef"
300     continue
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

      if(kbbc .or. kifp .or. kvc) then
         call proc_vc(cname_vc,cpmode,icode,
     >    kk4vcab, fvc,fvc_lo,fvc_hi,lwhich8)
      endif

!      goto 9000
C
C 4. Write out the IF distributor setup procedure.
      if (KVC .or. kbbc .or. kifp) then
        call proc_ifd(cname_ifd,icode,kpcal, fvc,fvc_lo,fvc_hi)
      endif

!      goto 9000
C
C 5. Write TAPEFffm procedure.
C    command format: TAPEFORM=index,offset lists
      call proc_tape(icode,codtmp,cpmode)

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
      if(ktrkf) then
        call proc_trkf(icode,num_sub_pass,lwhich8,ierr)
        if(ierr .ne. 0) return
      endif ! kvrec.or.kv4rec.or.km3rec.or.km4rec
!     goto 9000

C 7. Write PCALF procedure.
C    pcalform=bbc-sb,tone,tone,...
C These procedures do not depend on the type of recorder.
C The check for recorder type is included only so that the
C same logic can be used for TRKF and RECP.
C Therefore, use index 1 for all the tests in this section.

      if (kpcal_d) then 
      if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)
     >   .or.Km5Disk) then
        if ((km4rack.or.kvracks).and.
     .      (.not.kpiggy_km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then
          call proc_pcalf(icode,lwhich8)
        endif ! km4rack.or.kvracks
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
      if (km4rack.or.kvracks.or.km4fmk4rack) then
        if (kman_roll) then
          cnamep="rollform"//ccode(icode)
          call proc_write_define(lu_outfile,luscn,cnamep)
C ROLLFORM=
          write(lu_outfile,'(a)') 'rollform='
C ROLLFORM commands
          DO idef = 1,nrolldefs(istn,icode) ! loop on roll defs
            cbuf="rollform="
            nch=10
            do it=1,2+nrollsteps(istn,icode)
              nch = nch + ib2as(iroll_def(it,idef,istn,icode),ibuf,
     .              nch,Z4000+2*Z100+2) ! tracks
              nch = mcoma(ibuf,nch)
            enddo
            write(lu_outfile,'(a)') cbuf(1:nch-2)  ! get rid of last comma
          enddo ! loop on roll defs
          write(lu_outfile,"(a)") 'enddef'
        endif ! manual roll
      endif ! km4rack.or.kvracks.or.km4fmk4rack

C  End of major loop for each code
      endif ! this mode defined
!      write(luscn,'()')
      ENDDO ! loop on codes

C 9. Write out standard tape loading and unloading procedures
      call proc_load_unload()

C 10. Finally, write out the procedures in the $PROC section of the sked file.
C Read each line and if our station is mentioned, write out the proc.
      if(ksked_proc) then
        call proc_sked_proc(ierr)
        if(ierr .ne. 0) then
          write(*,*) "Error writing sked_proc section"
        endif
      endif

9000  continue
      call proc_write_define(-1,luscn," ")  !this flushes a buffer.
      CLOSE(LU_OUTFILE,IOSTAT=IERR)
      call drchmod(prcname,iperm,ierr)
C
      RETURN
      END

