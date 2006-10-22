        SUBROUTINE PROCS

C PROCS writes procedure file for the Field System.
C Version 9.0 is supported with this routine.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/skobs.ftni'
      include '../skdrincl/data_xfer.ftni'
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

C Called by: FDRUDG
C Calls: TRKALL,IADDTR,IADDPC,IADDK4,SET_TYPE,PROCINTR

! Functions
      character upper     
      integer ir2as,ib2as,mcoma,trimlen,jchar,ichmv ! functions
      logical kCheckGrpOr
      integer itras
      integer iroll_def

C LOCAL VARIABLES:
      integer*2 IBUF2(40) ! secondary buffer for writing files
      character*80 cbuf2
      equivalence (ibuf2,cbuf2)
      LOGICAL KUS ! true if our station is listed for a procedure
      logical ku,kl,kul,kux,klx,kcomment
      integer ichanx,ibx,icx
C     integer itrax(2,2,max_headstack,max_chan) ! fanned-out version of itras
      integer IC,ICA,ierr,i,idummy,nch,ipass,icode,it,iv,nchx,
     .ilen,ich,ic1,ic2,itrk(max_track,max_headstack),
     .ig,irecbw,ir,idef,ival,
     .igotbbc(max_bbc),itrkrate,
     .npmode,itrk2(max_track,max_headstack),itype
      integer isbx,isb,ibit,ichan,ib,itrka,itrkb,nprocs
      integer ivc3_patch,ivc10_patch
      logical kok,km3mode,km3be,km3ac,km4done,kpcal_d,kpcal,kroll,kcan
      logical kinclude,klast8,kfirst8,klsblo,knolo,kmodu
      logical knorack

      integer isbx_good
      integer ib_good
      integer ibit_good
      integer it_out,ib_out,ibit_out

C     real speed,spd
      real spdips
C     integer*2 lspd(4)
C     integer nspd
      CHARACTER*128 RESPONSE
      integer*2 LNAMEP(6)
      character*12 cnamep
      equivalence (lnamep,cnamep)

      logical kdone
      double precision DRF,DLO
      character*2 cvc2k41(max_bbc)
      character*1 cvc2k42(max_bbc)
      character*1 cvchan(max_bbc)
      real fvc(max_bbc),fr,rfvc  !VC frequencies
      real fvc_lo(max_bbc),fvc_hi(max_bbc)
      real rfvc_max   !maximum frequency
      real rpc ! pc freq
      real samptest
      integer Z8000,Z4000,Z100
      integer igig,i1,i2,i3,i4,nco,ix,il,itpid_period_use
      integer ichmv_ch,iaddtr,iaddpc,iaddk4
      integer ihead              !2hd
      integer ihdtmp
      logical khead2active       !head2 is used?
      logical kpiggy_km3mode     !2hd
      logical kk4vcab

      logical kgrp0,kgrp1,kgrp2,kgrp3,kgrp4,kgrp5,kgrp6,kgrp7

      character*1 cvpass(28)
      character*28 cvpassTmp
      equivalence (cvpass,cvpassTmp)
! JMG
      character*2 codtmp
      integer*2   icodtmp
      equivalence (codtmp,icodtmp)     	!cheap trick to convert form Holerith to ascii
      character*4 cpmode                !mode for procedure names  
!      integer*2 lpmode(2)
!      equivalence (cpmode,lpmode)
      integer num_chans_obs         	!number of channels observer
      integer num_tracks_rec_mk5        !number we record=num obs * ifan
      integer im5chn_dup                !number of duplicated channels.
      character*80 ldum
      integer ifan_fact                 !identical to ifan(,) unless ifan(,)=0, in which case this is 1.
      integer itemp                     !Short lived variable.
      integer num_sub_pass              !number of passes we loop on.
                                        !For mark5 mode this is 1. For other recorders is npassf
      integer MaxTrack
      parameter (MaxTrack=35)
      integer itrackvec(MaxTrack,2)       !used to keep track of assigned tracks.
      integer NumTracks
      logical kallodd
      integer itrackoff
      integer iptr
      logical kvracks                   !=kvrack .or. kv4rack
      logical Km5Disk(2)                !non-piggyback
      character*5 lform                 !Mark4 or VLBA
      logical kin2net_on                !Is in2net on?
      integer j                         !loop index.
!
      integer itvec(130),ibvec(130),isbvec(130),ibitvec(130)  !used in piggyback mode.

C
C INITIALIZED VARIABLES:
      data Z4000/Z'4000'/,Z100/Z'100'/,Z8000/Z'8000'/
      data CvpassTmp /'abcdefghijklmnopqrstuvwxyzab'/
      data cvc2k41/'01','02','03','04','05','06','07','08',
     .             '09','10','11','12','13','14','15','16'/
      data cvc2k42/'1','2','3','4','5','6','7','8',
     .             '1','2','3','4','5','6','7','8'/
      data cvchan /8*'A',8*'B'/

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

      kvracks=kv4rack.or.kvrack

      do ir=1,2
        Km5Disk(ir)=Km5prec(ir).or.Km5Arec(ir).or.Km5ApigWire(ir)
      end do

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

      ic=trimlen(prcname)
      WRITE(LUSCN,9113) PRCNAME(1:ic), cstnna(istn)
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

      kin2net_on=.false.
      if(.not. kno_data_xfer .and.
     >  ((.not. Kin2net_2_disk2file .and. kstat_in2net(istn)) .or.
     >  (Kdisk2file_2_in2net .and. kstat_disk2file(istn)))) then
         kin2net_on=.true.
      endif

      call proc_exper_initi(lu_outfile,luscn,kin2net_on)

      if(km5a .or. km5a_piggy) call proc_postob_mk5a(lu_outfile,luscn)

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
        if(ccode(icode)(2:2) .eq. " ") nco=1
        codtmp=ccode(icode)
        call c2lower(codtmp,codtmp)

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
         if (cbarrel(istn,icode)(1:1) .eq. "M") kcan = .false.

         if(km5p .or. km5A) kroll=.false.
        endif ! a roll mode

! don't have sub-passes for mk5-mode
        num_sub_pass=npassf(istn,icode)
        if(num_sub_pass .gt. 1 .and. (km5a.or.km5p)) num_sub_pass=1

        DO IPASS=1,num_sub_pass  !loop on number of sub passes
          do irec=1,nrecst(istn) ! loop on number of recorders
            if (kuse(irec)) then ! procs for this recorder
            itype=2
            if (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec)
     .          .or. KM5Disk(irec)) itype=1

            call setup_name(itype,icode,ipass,cnamep)
            call proc_write_define(lu_outfile,luscn,cnamep)

            call trkall(ipass,istn,icode,
     >        cmode(istn,icode), itrk,cpmode,npmode,ifan(istn,icode))

            call c2lower(cpmode,cpmode)

            km3mode=cpmode(1:1).ge."a".and. cpmode(1:1).le."e"
            km3be=  cpmode(1:1).eq."b".or.  cpmode(1:1).eq."e"
            km3ac=  cpmode(1:1).eq."a".or.  cpmode(1:1).eq."c"
c-----------make sure piggy for mk3 on mk4 terminal too--2hd---
            kpiggy_km3mode =km3mode  !2hd mk3 on mk5  !------2hd---

            if(km5P_piggy)kpiggy_km3mode=.false.  !------2hd---
            if(km5A_piggy)kpiggy_km3mode=.false.
            if(km5A.or.KM5P) kpiggy_km3mode= .false.           !no piggyback for Mark5

! Previously checked here to see if 2nd head was set.
! Now this is done in drudg, and won't execute piggyback if this is the case.

C Find out if any channel is LSB, to decide what procedures are needed.
            klsblo=.false.
            DO ichan=1,nchan(istn,icode) !loop on channels
              ic=invcx(ichan,istn,icode) ! channel number
              if (abs(freqrf(ic,istn,icode)).lt.freqlo(ic,istn,icode))
     >         klsblo=.true.
            enddo

          if(km5A .or. km5p .or. km5A_piggy .or. km5P_piggy) then
             ifan_fact=max(1,ifan(istn,icode))
             call find_num_chans_rec(ipass,istn,icode,
     >            ifan_fact,num_chans_obs,num_tracks_rec_mk5)
             if(num_chans_obs*ifan_fact .gt. 32) then
               if(km5p) then
                write(luscn,'(/,a,i3)')
     >          "PROCS10 - Can only record 32 tracks in MK5P mode. "//
     >          "Tried to record: ",num_chans_obs*ifan_fact
                 return
               else if(km5A .and.Km5ApigWire(1).or.Km5APigWire(2)) then
                write(luscn,'(/,a,i3)')
     >          "PROCS10b - Can only record 32 tracks in MK5APigwire "//
     >          " mode. Tried to record: ",num_chans_obs*ifan_fact
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

          if (kvrec(irec).or.kv4rec(irec)
     >     .or.km3rec(irec).or.km4rec(irec) .or.Km5disk(irec)) then
C  PCALD=STOP
            if (kpcal_d) then
              write(lu_outfile,'(a)') 'pcald=stop'
            endif
c check if 2nd head active, i.e. hd posns are set
          khead2active=.false.
          do i=1,max_pass !2hd
            if (ihdpos(2,i,istn,icode).ne.9999)khead2active=.true.       !2hd
          enddo !2hd
C  TAPEFffm
          if (km3rec(irec).or.km4rec(irec).or.kvrec(irec)
     .           .or.kv4rec(irec)) then ! no TAPEFORM for mk5
            call snap_tapef(codtmp,cpmode)
C  PASS=$,SAME
            if ((km3rec(irec).or.km4rec(irec).or.kv4rec(irec)) .and.
     >          .not.khead2active) then
              call snap_pass('=$,same')
            else if((km4rec(irec).or.kv4rec(irec)).and.khead2active)then
              call snap_pass('=$,mk4')
            else
              call snap_pass('=$')
            endif
          endif  ! no TAPEFORM for mk5
C  TRKFffmp
C  Also write trkf for Mk3 modes if it's an 8 BBC station or LSB LO
c..2hd..if piggy make sure mk3 modes are written
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     >       KM5Disk(irec).or.
     >       km4rec(irec).or.kk41rec(irec).or.kk42rec(irec)) then

            if((km4rack.or.kvracks.or.kk41rack.or.kk42rack)
     >        .and.  (.not.kpiggy_km3mode
     >                .or. klsblo
     >                .or.((km3be.or.km3ac).and.k8bbc))
     >                .or.Km5A_piggy)then
               call name_trkf(itype,codtmp,cpmode,cvpass(ipass),cnamep)
               write(lufile,'(a)') cnamep
            endif
C  PCALFff
            if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
              call snap_pcalf(codtmp)
            endif
C  ROLLFORMff
            if (kroll.and..not.kcan) then ! non-canned roll
              if (km4rack.or.kvracks.or.km4fmk4rack) then
                call snap_rollform(codtmp)
              endif
            endif ! non-canned roll
          endif
C  TRACKS=tracks   
C  Also write tracks for Mk3 modes if it's an 8 BBC station or LSB LO
          if (km5A) then
            if(KM5APigWire(irec).and.km4form) then
              if(num_tracks_rec_mk5 .eq. 8) then   !map to 2nd headstack
                write(lu_outfile,'(a)') "tracks=v4"
              else if(num_tracks_rec_mk5 .eq. 16) then
                write(lu_outfile,'(a)') "tracks=v4,v6"
              else if(num_tracks_rec_mk5 .eq. 32) then
                write(lu_outfile,'(a)') "tracks=v4,v5,v6,v7"
              else
                writE(*,*)
     >            "Proc error: Should never get here! Tell JMGipson"
                write(*,*) " jmg@leo.gsfc.nasa.gov"
                return
              endif
            else
              if(num_tracks_rec_mk5 .eq. 8) then
                 write(lu_outfile,'(a)') "tracks=v0"
              else if(num_tracks_rec_mk5 .eq. 16) then
                 write(lu_outfile,'(a)') "tracks=v0,v2"
              else if(num_tracks_rec_mk5 .eq. 32) then
                 write(lu_outfile,'(a)') "tracks=v0,v1,v2,v3"
              else if(num_tracks_rec_mk5 .eq. 64) then
                write(lu_outfile,'(a)') "tracks=v0,v1,v2,v3,v4,v5,v6,v7"
              endif
            endif

          else if((kvrack.or. km4form).and.
     .           (.not.kpiggy_km3mode.or.klsblo.or.
     .           ((km3ac.or.km3be).and.k8bbc)) ) then
! Make temporary copy of track table to use in determining if a track is used.
            numTracks=0
            kallodd=.true.
            do i=1,max_track
              itrk2(i,1)=itrk(i,1)
              itrk2(i,2)=itrk(i,2)
              if(itrk2(i,1).ne.0) NumTracks=NumTracks+1     !calculate #tracks first headstack.
              if(itrk2(i,2).ne.0) NumTracks=NumTracks+1
! Even or oddness of tracks is used in various Mark5modes below.
              if(itrk2(i,1) .ne. 0 .and. mod(i,2) .eq. 0) then
                 kallodd=.false.        !have an active even track.
              endif
            end do

! Enable extra tracks for Mark5A modes.
            if(km5Arec(irec).or. KM5A_piggy.or. KM5APigWire(irec)) then   !For Mark5A recording, may need to remap tracks.
              if(NumTracks .le. 8) then
                NumTracks=8
              elseif(Numtracks .le. 16) then
                NumTracks=16
              elseif(NumTracks .le. 32) then
                NumTracks=32
              else
                NumTracks=64
              endif
              if(KM5A_piggy .or. KM5APigWire(irec)) then
                if(km4form) then
                  ihead=2     !tracks mapped to 2nd head for km4.
                else
                  ihead=1     !tracks mapped to first head.
                endif
!Clear appropriate headstack.
                if(KM5APigWire(irec)) then
                  itemp=0
                  call iFill4(itrk2(1,ihead),Max_track,itemp)
                endif
! And make the appropriate tracks active.
                if(NumTracks .le. 16) then
                  do i=1,NumTracks
                    itrk2(2*i,ihead)=1   !make even tracks active.
                  end do
                else if(NumTracks .eq. 32) then
                  do i=2,33             !Fill tracks 2-33
                    itrk2(i,ihead)=1
                  end do
                endif
              else if(KM5Arec(irec)) then
! clear track array.
                itemp=0
                call iFill4(itrk2(1,1),Max_track,itemp)
                call iFill4(itrk2(1,2),Max_track,itemp)
! and refill it.
                if(NumTracks .le. 16) then
                  do i=1,NumTracks
                    itrk2(2*i,1)=1
                  end do
                else if(NumTracks .eq. 32) then
                  do i=2,33
                    itrk2(i,1)=1
                  end do
                else if(NumTracks .eq. 64) then
                  do i=2,33
                    itrk2(i,1)=1
                    itrk2(i,2)=1             !this can only happen with 2 headstacks.
                  end do
                endif
              endif   !KM5Arec
! Enable extra tracks for Mark5A modes.
            else if(KM5P_piggy) then
              do i=1,max_track
                if(km4form) then
                  itrk2(i,2)=itrk(i,1)  !map to second headstack.
                else
!                 itrk2(i,1)=itrk(i,1) Taken care of above.
                endif
              end do
            endif
! For Mark4P or Mark5P Piggyback, may want to dupicate tracks.
! This is done because we always record 32 tracks and this adds some redundancy.
! Also, need to have one of the 8 bytes completely full for disck check to work.
           if(KM5P_Piggy .or. KM5Prec(irec)) then
             if(KM5P_piggy.and.km4form) then
               ihead=2
             else
               ihead=1
             endif
             do i=2,32,2         !double up tracks if we need to.
               if(itrk2(i,ihead) .eq. 1) then
                 itrk2(i+1,ihead)=1            !set it if it is not set.
               else if(itrk2(i+1,1) .eq. 1) then
                 itrk2(i, ihead)=1
               endif
             end do
             kgrp0=.true.     !See if any byte of the 32 is full.
             kgrp1=.true.     !This is required for Mark5P disck_check to work.
             kgrp2=.true.
             kgrp3=.true.
             do i=2,9
               if(itrk2(i,   ihead) .ne. 1) kgrp0=.false.
               if(itrk2(i+ 8,ihead) .ne. 1) kgrp1=.false.
               if(itrk2(i+16,ihead) .ne. 1) kgrp2=.false.
               if(itrk2(i+24,ihead) .ne. 1) kgrp3=.false.
             end do
             if(.not.(kgrp0.or.kgrp1.or.kgrp2.or.kgrp3)) then
                write(luscn,'(1x,a)')  "**** Warning! PROCS: Mark5P."//
     >              "No full byte after duplicating"
                write(luscn,'("Set: ",4(8i1,1x))')(itrk2(i,1),i=2,33)
             endif
            endif

C           use second headstack for Mk5
! head1
! ...find marked groups and zero them in 2nd copy of track table, put "V0" etc as appropriate.
            cbuf="TRACKS="
            nch=8
! first try to pick up VLBA groups.
            call ChkGrpAndWrite(itrk2, 2,16,1,'V0',kgrp0,ibuf,nch)
            call ChkGrpAndWrite(itrk2, 3,17,1,'V1',kgrp1,ibuf,nch)
            call ChkGrpAndWrite(itrk2,18,32,1,'V2',kgrp2,ibuf,nch)
            call ChkGrpAndWrite(itrk2,19,33,1,'V3',kgrp3,ibuf,nch)

! if this doesn't work, pick up Mark4 groups.
            if(.not. kgrp0)
     >          call ChkGrpAndWrite(itrk2, 4,16,1,'M0',kgrp0,ibuf,nch)
            if(.not.kgrp1)
     >          call ChkGrpAndWrite(itrk2, 5,17,1,'M1',kgrp1,ibuf,nch)
            if(.not.kgrp2)
     >          call ChkGrpAndWrite(itrk2,18,30,1,'M2',kgrp2,ibuf,nch)
            if(.not.kgrp3)
     >          call ChkGrpAndWrite(itrk2,19,31,1,'M3',kgrp3,ibuf,nch)
! head2
            if(km4form) then
               call ChkGrpAndWrite(itrk2, 2,16,2,'V4', kgrp4,ibuf,nch)
               call ChkGrpAndWrite(itrk2, 3,17,2,'V5', kgrp5,ibuf,nch)
               call ChkGrpAndWrite(itrk2,18,32,2,'V6', kgrp6,ibuf,nch)
               call ChkGrpAndWrite(itrk2,19,33,2,'V7', kgrp7,ibuf,nch)
               if(.not.kgrp4)
     >           call ChkGrpAndWrite(itrk2, 4,16,2,'M4',kgrp4,ibuf,nch)
               if(.not.kgrp5)
     >           call ChkGrpAndWrite(itrk2,5,17,2,'M5',kgrp5,ibuf,nch)
               if(.not.kgrp6)
     >           call ChkGrpAndWrite(itrk2,18,30,2,'M6',kgrp6,ibuf,nch)
               if(.not.kgrp7)
     >           call ChkGrpAndWrite(itrk2,19,31,2,'M7',kgrp7,ibuf,nch)
            endif

C  Now pick up leftover tracks that didn't appear in a whole group
C  and list each one separately.
            do ihead=1,Max_headstack
              if(ihead .eq. 1 .or. km4form) then
                do i=2,33
                  if(nch .eq. 0) then
                    cbuf="TRACKS=*,"
                    nch=10
                  endif

                  if(itrk2(i,ihead) .eq. 1) then
                    nch = nch + ib2as(i+(ihead-1)*100,ibuf,nch,Z8000+3)
                    nch = MCOMA(IBUF,nch)
                  endif

                  if(nch .ge. 60) then
                    call delete_comma_and_write(lu_outfile,ibuf,nch)
                  endif
                end do
              endif
              if(nch .gt. 10 .and. nch .ne. 0) then    !write out everything on first headstack.
                 call delete_comma_and_write(lu_outfile,ibuf,nch)
              endif
            end do

            if(nch .gt. 10 .and .nch .ne. 0) then
               call delete_comma_and_write(lu_outfile,ibuf,nch)
            endif
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
            cbuf="REC_MODE"
            nch=9

            if (krec_append) nch = ichmv_ch(ibuf,nch,crec(irec))
            cbuf(nch:nch+8)="="//cs2mode(istn,icode)
            nch=nch+1+trimlen(cs2mode(istn,icode))
            nch = ichmv_ch(ibuf,nch,',$')
C           If roll is NOT blank and NOT NONE then use it.
            if (cbarrel(istn,icode) .ne. "NONE" .and.
     >          cbarrel(istn,icode) .ne. " ") then
              nch = MCOMA(IBUF,nch)
              nch = ichmv(ibuf,nch,lbarrel(1,istn,icode),1,4)
            endif
            call lowercase_and_write(lu_outfile,cbuf)

            cbuf="user_info"
            if(krec_append) then
              nchx=10
              cbuf(10:10)=crec(irec)
            else
              nchx=9
            endif

            write(lu_outfile,'(a,a)') cbuf(1:nchx),'=1,label,station'
            write(lu_outfile,'(a,a)') cbuf(1:nchx),'=2,label,source'
            write(lu_outfile,'(a,a)') cbuf(1:nchx),'=3,label,experiment')
            write(lu_outfile,'(a,a,a)') cbuf(1:nchx),'=3,field,',cexper
            write(lu_outfile,'(a,a,a)') cbuf(1:nchx),'=1,field,,auto '
            write(lu_outfile,'(a,a,a)') cbuf(1:nchx),'=2,field,,auto '
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
            if ((km4rack.or.kvracks.or.kk41rack.or.kk42rack)
     .       .and. (.not.kpiggy_km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then
              call snap_recp(codtmp)
            endif
          endif ! K4 recorder
C  NONE rack gets comments
          if (knorack) then ! none rack comments
            write(lu_outfile,'(a)')'"channel  sky freq  lo freq  video'
            DO ichan=1,nchan(istn,icode) !loop on channels
              cbuf='"'
              nch=6
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
              fr = abs(FREQLO(ic,istn,ICODE)) ! sky freq
              if (abs(freqLO(ic,istn,icode)).gt.100000.d0) then
                igig=abs(freqLO(ic,istn,icode))/100000.d0
                nch=nch+ib2as(igig,ibuf,nch,1)
                fr=abs(freqLO(ic,istn,icode))-igig*100000.d0
              endif
              NCH = nch + IR2AS(fr,IBUF,nch,8,2)
              nch = nch + 3
              DLO = freqlo(ic,istn,icode) ! lo freq
              DRF = abs(FREQRF(ic,istn,ICODE)) ! sky freq
              rFVC = abs(DRF-DLO)   ! BBCfreq = RFfreq - LOfreq
              NCH = nch + IR2AS(rFVC,IBUF,nch,8,2)
              if (DRF-DLO .lt. 0.d0) nch = ichmv_ch(ibuf,nch+1,"LSB")
              call lowercase_and_write(lu_outfile,cbuf)
            enddo ! loop on channels
          endif ! none rack comments

C  PCALD=
          if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
            write(lu_outfile,'(a)') 'pcald='
          endif

C  FORM=m,r,fan,barrel,modu   (m=mode,r=rate=2*b)
C  For S2, leave out command entirely
C  For 8-BBC stations, use "M" for Mk3 modes
          if (kvracks.or.km3rack.or.km4rack
     .          .or.km4fmk4rack.or.kk3fmk4rack) then
            if(ks2rec(irec) .or. kk41rec(irec) .or. kk42rec(irec)) then
               continue                 !leave out command
            else
              cbuf="form=m"             !This is default form command. Modified below if necessary.
              nch=7
              lform="mark4"
              if((km5A .or. km5A_piggy.or. KM5P .or. KM5P_Piggy).and.
     >                  .not.km3rack) then
                if(km3mode .or. km4form
     >                     .or. cmfmt(istn,icode)(1:1) .eq. "m"
     >                     .or. cmfmt(istn,icode)(1:1) .eq. "M") then
!                   lform="mark4"
                else
                  cbuf(6:6)=cmode(istn,icode)(1:1)      !replace mode letter.
                  lform="vlba"
!                  nch = ichmv_ch(ibuf,nch,'v')
                endif
              else if (km3mode) then
 !               lform="mark4"
                if(klsblo.and.(kvrack .or. km4form)
     .            .or.k8bbc.and.(km3be.or.km3ac)) then
!                  cbuf="form=m"     !not needed.
                elseif ((kvrack.or.km3rack.or.kk3fmk4rack).and.
     .                  cmode(istn,icode)(1:1) .eq. 'E') THEN
C                   MODE E = B ON ODD, C ON EVEN PASSES
                  IF (MOD(IPASS,2).EQ.0) THEN
                    cbuf="form=c"
                  ELSE
                    cbuf="form=b"
                  ENDIF
                else ! not mode E or else Mk4 formatter
                   cbuf(6:6)=cmode(istn,icode)(1:1)
                endif
              else ! not Mk3 mode
C             Use format from schedule, 'v' or 'm'
!                nch = ICHMV(IBUF,nch,lmFMT(1,istn,icode),1,1)
                if (kvrack) then ! add format to FORM command
                  cbuf(6:6)="v"
                else if (km4form) then
!                   nch = ICHMV_ch(IBUF,nch,'m')  not needed
                else
!write warning if not not vlba formatter or km4form
                  write(luscn,'(/,a)') "PROCS08 - WARNING! Non-Mk3 "//
     >              "modes are not supported by your station equipment."
                endif ! add format to FORM command
              endif

C           Add group index for Mk4 formatter
C           ... but not for LSB case
              if (km4form .and.kpiggy_km3mode.and..not.klsblo.and.
     >            cmode(istn,icode) .ne. "A") then
                if (cmode(istn,icode).eq. "E") THEN ! add group
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
     .           kroll.or.kmodu) then ! barrel or fan or modulation
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
                    if (kvrack.and.cbarrel(istn,icode) .ne. "M") then
                      if (cbarrel(istn,icode) .eq. "8:1" .or.
     .                    cbarrel(istn,icode) .eq. "16:1") then
                         continue
                       else ! add the :1 for VLBA racks
                         nchx=trimlen(cbuf)
                         if(.not.km4form) nch=ichmv_ch(ibuf,nchx+1,":1")
                       endif ! already there/add
                     else if(km4form) then
                       nch=trimlen(cbuf)
                       if(cbuf(nch-1:nch) .eq. ":1") then
                         cbuf(nch-1:nch)=" "
                         nch=nch-2
                       endif
                       nch=nch+1
                     endif
C                else if (kv4rack.or.km4rack.or.km4fmk4rack) then
C                  write(luscn,9137) 
C9137              format(/'PROCS05 - WARNING! Barrel roll is not',
C     .            ' supported for Mark IV formatters.')
                  endif
                endif ! roll
                if (kmodu) then ! modulation
                  nch=trimlen(cbuf)+1
                  if (.not.kroll) then ! insert comma
                    nch = MCOMA(IBUF,nch)
                  endif ! insert comma
                  nch = ichmv_ch(ibuf,nch,',on')
                endif ! modulation
              endif ! barrel or fan or modulation
            endif ! non-S2 only
            call lowercase_and_write(lu_outfile,cbuf)

          endif
          endif ! kvracks or km3rac.or.km4rack but not S2 or K4
C  BBCffb, IFPffb  or VCffb
          if (km3rack.or.km4rack.or.kvracks.or.
     >         kk41rack.or.kk42rack.or.klrack) then
              nch=4
              if(kvracks) then
                cbuf="BBC"
              else if(klrack) then
                cbuf="IFP"
              elseif (km3rack.or.km4rack.or. kk41rack.or.kk42rack) then
                cbuf="VC"
                nch=3
              endif
              nch = ichmv(ibuf,nch,lcode(icode),1,nco)
              CALL M3INF(ICODE,SPDIPS,IB)
              NCH=ICHMV(ibuf,NCH,LBNAME,IB,1)
              if (kk4vcab.and.krec_append)
     .            nch=ichmv_ch(ibuf,nch,crec(irec))
              call lowercase_and_write(lu_outfile,cbuf)

          endif ! kvrack or km3rac.or.km4rackk .or. any k4rack

!  TRKFffmp for LBA rack +s2 recorder.  Must come after IFPffb commmand.
          if (klrack.and.ks2rec(irec)) then
            call name_trkf(itype,codtmp,cpmode,cvpass(ipass),cnamep)
            write(lufile,'(a)') cnamep
          endif ! klrack.and.ks2rec


C  IFDff
          if (km3rack.or.km4rack.or.kvracks.or.
     .        kk41rack.or.kk42rack.or.klrack) then
            call snap_ifd(codtmp)
          endif ! kvrack or km3rac.or.km4rackk


C  FORM=RESET
          if (km3rack.and..not.(ks2rec(irec).or. km5Disk(irec)))then
            write(lu_outfile,'(a)') 'form=reset'
          endif
C  !*
          if (kvrack.and..not.
     >       (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec))) then
             write(lu_outfile,'(a)') '!*'
          endif

C  TPICD=no,period
          if (km3rack.or.km4rack.or.kvracks) then
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
            cbuf='ENABLE'
            nch=7
            if (krec_append) nch = ichmv_ch(ibuf,nch,crec(irec))
            NCH = ichmv_ch(IBUF,nch,'=')
            if (kvrec(irec).or.kv4rec(irec)) then ! group-only enables for VLBA recorders
              if(kCheckGrpOr(itrk,2,16,1)) then   !see if any even tracks in this range.
                itrka=6
                itrkb=8
                nch = ichmv_ch(ibuf,nch,'G0,')
              endif
              if(kCheckGrpOr(itrk,3,17,1)) then
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=7
                endif
                itrkb=9
                nch = ichmv_ch(ibuf,nch,'G1,')
              endif
              if(kCheckGrpOr(itrk,18,32,1)) then
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=20
                endif
                itrkb=22
                nch = ichmv_ch(ibuf,nch,'G2,')
              endif
              if(kCheckGrpOr(itrk,19,33,1)) then
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=21
                endif
                itrkb=23
                nch = ichmv_ch(ibuf,nch,'G3,')
              endif
            else if (km3rec(irec)) then ! group enables plus leftovers
              do i=1,max_track          ! Make a copy of the track table.
                itrk2(i,1)=itrk(i,1)
              enddo
! check if group g1 is present. If so, write it out.
              call ChkGrpAndWrite(itrk2,4,16,1,'G1',kgrp1,ibuf,nch)
              if(kgrp1) then
                 if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=3 ! Mk3 track number
                  itrkb=5
                 endif
              endif
! ditto fo g2
              call ChkGrpAndWrite(itrk2, 5,17,1,'G2',kgrp2,ibuf,nch)
              if(kgrp2) then
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=4
                endif
                itrkb=6
              endif
! ... for g3
              call ChkGrpAndWrite(itrk2, 18,30,1,'G3',kgrp3,ibuf,nch)
              if(kgrp3) then
                if (itrka.eq.0.and.itrkb.eq.0) then
                  itrka=17
                endif
                itrkb=19
              endif

              call ChkGrpAndWrite(itrk2, 19,31,1,'G4',kgrp4,ibuf,nch)
              if(kgrp4) then
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
            else if (KM4rec(irec) .or. KM5disk(irec)) then
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
            call delete_comma_and_write(lu_outfile,ibuf,nch)

          endif
C REPRO=byp,itrka,itrkb,equalizer,bitrate   Mk3/4
C REPRO=byp,itrka,itrkb,equalizer,,,bitrate   VLBA,VLBA4
          if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .      km4rec(irec).and..not.ks2rec(irec)) then
            cbuf="repro"
            nch=6
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
            call lowercase_and_write(lu_outfile,cbuf)

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

          if(km5A .or. km5A_piggy) then
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
          if (kvracks.or.km3rack.or.km4rack.or.
     .        kk41rack.or.kk42rack.or.klrack) then
            
          nch=4
          if(kvracks) then
             cnamep="BBC"
          else if(klrack) then
             cnamep="IFP"
          elseif (km3rack.or.km4rack.or. kk41rack.or.kk42rack) then
            cnamep="VC"
            nch=3
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
          rfvc_max=-1.
          DO ichan=1,nchan(istn,icode) !loop on channels
            ic=invcx(ichan,istn,icode) ! channel number
            ib=ibbcx(ic,istn,icode) ! BBC number
C           If we already did this BBC, skip it.
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
! Skip if the LO frequency is negative.
              if(freqrf(ic,istn,icode) .lt. 0) kinclude=.false.
              if (kinclude) then ! include this channel
                cbuf=" "
                DRF = FREQRF(ic,istn,ICODE)
                if (klrack) then
                  if (ic.eq.ica) then
C                     use centreband filters where possible
                    if (cnetsb(ic,istn,ICODE).eq."L") then
                      DRF = FREQRF(ic,istn,ICODE)
     .                      - VCBAND(ic,istn,ICODE) / 2.0
                    else
                      DRF = FREQRF(ic,istn,ICODE)
     .                      + VCBAND(ic,istn,ICODE) / 2.0
                    endif
                  else if (FREQRF(ic,istn,ICODE).eq.
     .                           FREQRF(ica,istn,ICODE)) then
C                     must be simple double sideband ie. L+U
                    if (cnetsb(ic,istn,ICODE).ne.cnetsb(ica,istn,ICODE))
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
                    if (cnetsb(ic,istn,ICODE).ne.cnetsb(ica,istn,ICODE))
     .                write(luscn,9900) ic,ica
                    if (cnetsb(ic,istn,icode) .eq. 'L') then
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

                rFVC = abs(DRF-DLO)   ! BBCfreq = RFfreq - LOfreq
                if (knolo) rFVC=-1.0 ! set to invalid value
                fvc(ib) = rfvc
                fvc_lo(ib)=0.
                fvc_hi(ib)=0.
                if (km3rack.or.km4rack.or.kvracks.or.klrack) then
                  if (kvracks) nch = ichmv_ch(ibuf,1,'BBC')
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
                if (kvracks) then
                   kok=cifinp(ic,istn,icode)(1:1) .ge. "A" .and.
     >                 cifinp(ic,istn,icode)(1:1) .le. "D"
                endif
                if (klrack) then
                   kok=cifinp(ic,istn,icode)(1:1) .ge. "1" .and.
     >                 cifinp(ic,istn,icode)(1:1) .le. "4"
                endif
C  The warning messages.
                if ((km3rack.or.km4rack).and..not.kok) write(luscn,9919) 
     .            cifinp(ic,istn,icode)
9919                format(/'PROCS04 - WARNING! IF input ',a,' not',
     .            ' consistent with Mark III/IV rack.')
                if ((kvrack).and..not.kok) write(luscn,9909)
     .            cifinp(ic,istn,icode)
9909              format(/'PROCS04 - WARNING! IF input ',a,' not',
     .            ' consistent with VLBA rack.')
                if ((klrack).and..not.kok) write(luscn,9929)
     .            cifinp(ic,istn,icode)
9929              format(/'PROCS04 - WARNING! IF input ',a,' not',
     .            ' consistent with LBA rack.')
                if (kvracks.and.
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
                  NCH = nch + IR2AS(rFVC,IBUF,nch,7,2) ! converter freq
C               else
C                 nch = ichmv_ch(ibuf,nch,'invalid')
C               endif
                if (kvracks) then
                  NCH = MCOMA(IBUF,NCH)
C                 Write out actual IF input from schedule file.
C                 This effectively disables the translation to VLBA IFs.
                  nch = ichmv(ibuf,nch,lifinp(ic,istn,icode),1,1)
                endif
C               Converter bandwidth
                km4done = .false.
                if (km4rack.and.(vcband(ic,istn,icode).eq.1.0.or.
     .                           vcband(ic,istn,icode).eq.0.25)) then ! external
                  NCH = ichmv_ch(ibuf,nch,',0.0(')
                  NCH = NCH + IR2AS(VCBAND(ic,istn,ICODE),IBUF,NCH,6,3)
                  NCH = ichmv_ch(ibuf,nch,')')
                  km4done = .true.
                else if (kvracks.or.km3rack.or.(km4rack.and.
     .                 .not.km4done)) then
                  NCH = MCOMA(IBUF,NCH)
                  if (kk42rec(irec).and.(km4rack.or.kvracks)) then
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
                  if(kul) then
                     fvc_lo(ib)=fvc(ib)-VCBAND(ic,istn,ICODE)
                     fvc_hi(ib)=fvc(ib)+vcband(ic,istn,icode)
                     nch=ichmv_ch(ibuf,nch,'ul')
                  else if(ku) then
                     nch=ichmv_ch(ibuf,nch,'u')
                     fvc_lo(ib)=fvc(ib)
                     fvc_hi(ib)=fvc(ib)+vcband(ic,istn,icode)
                  else if(kl) then
                     fvc_lo(ib)=fvc(ib)-VCBAND(ic,istn,ICODE)
                     fvc_hi(ib)=fvc(ib)
                     nch=ichmv_ch(ibuf,nch,'l')
                  endif
                endif
                if (kvracks.or.klrack) then
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
                    nch = ichmv_ch(ibuf,nch,'SCB,') ! for single centreband filter
                  else
                    nch = ichmv_ch(ibuf,nch,'DSB,') ! for double sideband filter
                  endif
                  if(cnetsb(ica,istn,ICODE).ne.'L'.and..not.klsblo.or.
     >               cnetsb(ica,istn,ICODE).eq.'L'.and.klsblo) then
                    nch = ichmv_ch(ibuf,nch,'NAT,')
                  else
                    nch = ichmv_ch(ibuf,nch,'FLIP,')
                  endif
                  if (ic.ne.ica) then
C                     Normally LSB so login inverts
                    if(cnetsb(ic,istn,ICODE).eq.'L'.and..not.klsblo .or.
     >                  cnetsb(ic,istn,ICODE).eq.'L'.and.klsblo) then
                      nch = ichmv_ch(ibuf,nch,'NAT')
                    else
                      nch = ichmv_ch(ibuf,nch,'FLIP')
                    endif
                  endif
                  NCH = MCOMA(IBUF,NCH)
                  cbuf(nch:nch+7)=cs2data(istn,icode)
                endif
                call lowercase_and_write(lu_outfile,cbuf)

                if (kk41rack.or.kk42rack) then ! k4
                  cbuf="V"
                  nch=2
                  if (kk41rack) then ! k4-1
                    nch=ichmv_ch(ibuf,nch,'C=')
                    nch = ichmv_ch(ibuf,nch,cvc2k41(ib))
                  else ! k4-2
                    nch=ichmv_ch(ibuf,nch,cvchan(ib)) ! 'A' or 'B'
                    nch = ichmv_ch(ibuf,nch,'=')
                    nch = ichmv_ch(ibuf,nch,cvc2k42(ib))
                  endif ! k4-1/2
                  call lowercase_and_write(lu_outfile,cbuf)
                endif ! k4
              endif ! include this channel
            endif ! do this BBC command
            if(rfvc_max .lt. rfvc) then
               cbuf2=cbuf
               rfvc_max=rfvc
            endif

          ENDDO !loop on channels
! Here we pick up the BBCs that are present, but not used.
! This is for the RDVs.

          nch=4
          if (km3rack.or.km4rack.or. kk41rack.or.kk42rack) nch=3
          do ib=1,max_bbc
            if(ibbc_present(ib,istn,icode) .eq. -1) then  !present but not used.
              write(cbuf2(nch:nch+1),'(i2.2)') ib
              if(.false.) then
                 if(km3rack .or. km4rack) then
                   write(cbuf,'("vc",i2.2,"=",f6.2,",",f6.3,",u")')
     >             ib,rfvc,vcband(ic,istn,icode)
                 else if(kvracks) then
                   write(cbuf,
     >              '("bbc",i2.2,"=",f6.2,",b",2(",",f6.3)))')
     >               ib,rfvc,vcband(ic,istn,icode),vcband(ic,istn,icode)
                 endif
               endif
              call squeezewrite(lu_outfile,cbuf2)
            endif
          end do

          if (km3rack.or.km4rack) then
            write(lu_outfile,"('!+1s')")
            write(lu_outfile,'(a)') 'valarm'
          endif

C         For K4, use bandwidth of channel 1
          if (kk41rack) then ! k4-1
            cbuf="vcbw="
            nch=6
            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'4.0')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            write(lu_outfile,'(a)') cbuf(1:nch)
          endif ! k4-1
          if (kk42rack) then ! k4-2
            cbuf="vabw="
            nch=6

            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'wide')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            write(lu_outfile,'(a)') cbuf(1:nch)

            cbuf="vbbw="
            nch=6
            if (kk42rec(irec)) then
              nch = ichmv_ch(ibuf,nch,'wide')
            else
              NCH = NCH + IR2AS(VCBAND(1,istn,ICODE),IBUF,NCH,6,3)
            endif
            write(lu_outfile,'(a)') cbuf(1:nch)

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

        if (km3rack.or.km4rack.or.kvracks.or.
     .     kk41rack.or.kk42rack.or.klrack) then !
          cnamep="IFD"//ccode(icode)(1:nco)
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
              if(freqrf(ic,istn,icode) .gt. 0) then
                if (i1.eq.0.and.cifinp(ic,istn,icode)(1:1).eq.'1') i1=ic
                if (i2.eq.0.and.cifinp(ic,istn,icode)(1:1).eq.'2') i2=ic
                if (i3.eq.0.and.cifinp(ic,istn,icode)(1:1).eq.'3') i3=ic
                if (i4.eq.0.and.cifinp(ic,istn,icode)(1:1).eq.'4') i4=ic
              endif
            enddo ! which IFs are in use
C IFD command
            if (km3rack.or.km4rack ) then ! mk3/4 IFD
!              NCH = ichmv_ch(IBUF,1,'ifd=')
C             NCH = ichmv_ch(IBUF,NCH,'atn1,atn2,')
!              NCH = ichmv_ch(IBUF,NCH,',,') ! default atn is now null
              cbuf="ifd=,,"
              nch=7
              if (i1.ne.0) then ! IF1 is in use
                IF (cifinp(i1,istn,ICODE)(2:2).eq. 'N') then
                  NCH = ichmv_ch(IBUF,NCH,'NOR,')
                ELSE ! must be 'A'
                  NCH = ichmv_ch(IBUF,NCH,'ALT,')
                ENDIF
              else
                nch = ichmv_ch(ibuf,nch,',')
              endif
              if (i2.ne.0) then ! IF2 is in use
                IF (cifinp(i2,istn,ICODE)(2:2) .eq.'N') THEN
                  NCH = ichmv_ch(IBUF,NCH,'NOR')
                ELSE ! must be 'A'
                  NCH = ichmv_ch(IBUF,NCH,'ALT')
                ENDIF
              else
                nch = ichmv_ch(ibuf,nch,',')
              endif
              call lowercase_and_write(lu_outfile,cbuf)
              cbuf=" "
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
!                    itemp=1
                    else if(fvc_lo(ib) .gt. 210.0) then
                      itemp=2
                    else if((fvc_lo(ib)+fvc_hi(ib))/2. .lt. 220.0) then
!                      itemp=1
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
              if (kvex) then ! we know about IF3
                if (i3.ne.0) then ! IF3 exists, write the command
C   I'm not sure that "i3.ne.0" means that IF3 exists, just that
C   it's in use. The VEX file is supposed to indicate whether a
C   station has IF3 regardless of whether it's being used.
C                 NCH = ichmv_ch(IBUF,1,'IF3=atn3,')
!                  NCH = ichmv_ch(IBUF,1,'if3=,') ! default atn is now null
                  IF (cifinp(i3,istn,ICODE)(2:2).eq. 'O') THEN
                    cbuf="if3=,out,"
                    nch=10
!                    NCH = ichmv_ch(IBUF,NCH,'out,')
                  ELSE ! must be 'I' or 'N'
!                    NCH = ichmv_ch(IBUF,NCH,'in,')
                    cbuf="if3=,in,"
                    nch=9
                  endif
                  nch = nch+ib2as(ivc3_patch,ibuf,nch,1)
                  NCH = MCOMA(IBUF,NCH)
                  nch = nch+ib2as(ivc10_patch,ibuf,nch,1)
C                 Add phase cal on/off info as 7th parameter. 
                  NCH = MCOMA(IBUF,NCH)
                  NCH = MCOMA(IBUF,NCH)
                  NCH = MCOMA(IBUF,NCH)
                  if (kpcal) then ! on
                    nch=ichmv_ch(ibuf,nch,'on')
                  else ! off
                    nch=ichmv_ch(ibuf,nch,'off')
                  endif ! value/off
                  write(lu_outfile,'(a)') cbuf(1:nch)

                ENDIF ! IF3 exists, write the command
              else ! always write it
C               NCH = ichmv_ch(IBUF,1,'IF3=atn3,')
                if(i3.ne.0) then ! IF3 is in use, add "in"
! Default case.
                  cbuf='if3=,in,'
                  nch=9
                  if(i1 .ne. 0) then   !
                    if(freqlo(i3,istn,icode) .eq.
     >                  freqlo(i1,istn,icode)) then           !if lo3=lo1, then out, else in.
                     cbuf='if3=,out,'
                     nch=10
                    endif
                  endif
                  nch = nch+ib2as(ivc3_patch,ibuf,nch,1)
                  NCH = MCOMA(IBUF,NCH)
                  nch = nch+ib2as(ivc10_patch,ibuf,nch,1)
C               Add phase cal on/off info next. 
                  if (kpcal) then ! on
                    nch=ichmv_ch(ibuf,nch,',,,on')
                  else ! off
                    nch=ichmv_ch(ibuf,nch,',,,off')
                  endif ! value/off
                  write(lu_outfile,'(a)') cbuf(1:nch)

                endif ! IF3 is in use
! JMG End.
              endif ! we know/don't know about IF3
            endif ! mk3/4 IFD
C
C LO command for Mk3/4 and K4 and LBA
C           First reset all
            if(klrack .or. kk41rack.or.kk42rack .or.
     >         km3rack .or.km4rack) write(lu_outfile,'(a)') "lo="

            do i=1,4 ! up to 4 LOs
              cbuf="lo=lo"
              nch=6
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
                klsblo=abs(freqrf(ix,istn,icode)).lt.
     >              freqlo(ix,istn,icode)
!                if (.not.klsblo) then ! upper
                  nch=ichmv(ibuf,nch,losb(ix,istn,icode),1,1)
!                else ! lower, so reverse
!                  if (ichcm_ch(losb(ix,istn,icode),1,'U').eq.0) then
!                    nch=ichmv_ch(ibuf,nch,'L')
!                  else
!                    nch=ichmv_ch(ibuf,nch,'U')
!                  endif
!                endif ! lower, so reverse
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
          if (km3rack.or.km4rack .or. kk41rack.or.kk42rack) then
            write(lu_outfile,'(a)') "patch="

            DO I=1,3 ! up to three Mk3/4, K4 IFs need a patch command
              if (i.eq.1.and.i1.gt.0.or.i.eq.2.and.i2.gt.0.or.
     .            i.eq.3.and.i3.gt.0) then ! this LO in use
                cbuf="PATCH=LO"
                nch=9
                NCH = NCH + IB2AS(I,IBUF,NCH,1)
                DO ic = 1,nchan(istn,icode)
                  iv=invcx(ic,istn,icode) ! channel number
                  ib=ibbcx(iv,istn,icode) ! VC number
                  if (igotbbc(ib).eq.0) then! do this BBC 
                    if ((cifinp(iv,istn,icode)(1:1).eq.'1'.and.i.eq.1)
     >             .or. (cifinp(iv,istn,icode)(1:1).eq.'2'.and.i.eq.2)
     >             .or. (cifinp(iv,istn,icode)(1:1).eq.'3'.and.i.eq.3)
     >                            ) then ! correct LO
                      igotbbc(ib)=1
                      NCH = MCOMA(IBUF,NCH)
                      if (km3rack.or.km4rack) then ! mk3/4
                        NCH = nch+IB2AS(ib,IBUF,NCH,2+z8000) ! VC number
                        if (i.eq.3) then !IF3 always high
                          nch=ichmv_ch(ibuf,nch,'H')
                        else  ! IF1 and IF2 may be high or low
! START 2004Sep17  JMGipson
! For non-geodetic, use old algorthim.
! For geodetic, new algorithm.
!  1. If the upper edge of the recorded BandPass (which can possibly be!
!   double sideband and is BW dependent) is below 230 MHz, pick low.
!
!  2. If the lower edge of the recorded BP is above 210, pick high.
!
!  3. For others if the center is of the recorded BP is below 220, pick
!    low, otherwise high.
!
!  For VC1, 2,3, and 9,10 apply these tests in order 1,2,3.
!  For VC4, 11, 12, 13, 14 apply them 2,1,3.
!

                        if(kgeo) then
                          if(ib.eq.1 .or. ib.eq.2 .or. ib.eq.3 .or.
     >                       ib.eq.9 .or. ib.eq. 10) then
                             if(fvc_hi(ib) .lt. 230.0) then
                               nch=ichmv_ch(ibuf,nch,'L')
                             else if(fvc_lo(ib) .gt. 210.0) then
                               nch=ichmv_ch(ibuf,nch,'H')
                             else if((fvc_lo(ib)+fvc_hi(ib))/2.
     >                                           .lt. 220.0) then
                               nch=ichmv_ch(ibuf,nch,'L')
                             else
                               nch=ichmv_ch(ibuf,nch,'H')
                             endif
                           else if(ib .eq. 4 .or. ib .ge. 11) then
                             if(fvc_lo(ib) .gt. 210.0) then
                               nch=ichmv_ch(ibuf,nch,'H')
                             else if(fvc_hi(ib) .lt. 230.0) then
                               nch=ichmv_ch(ibuf,nch,'L')
                             else if((fvc_lo(ib)+fvc_hi(ib))/2.
     >                                       .lt. 220.0) then
                               nch=ichmv_ch(ibuf,nch,'L')
                             else
                               nch=ichmv_ch(ibuf,nch,'H')
                             endif
                           else if(ib .ge. 4 .and. ib .le. 8) then
                             if (fvc(ib).gt.210.0) then ! high
                               nch=ichmv_ch(ibuf,nch,'H')
                             else ! low
                               nch=ichmv_ch(ibuf,nch,'L')
                             endif
                           endif
                         else
                           if (fvc(ib).gt.210.0) then ! high
                             nch=ichmv_ch(ibuf,nch,'H')
                           else ! low
                             nch=ichmv_ch(ibuf,nch,'L')
                           endif
                         endif
! END 2004Sep17  JMGipson


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
                call lowercase_and_write(lu_outfile,cbuf)
              endif ! this LO in use
            ENDDO ! three Mk3/4 IFs need a patch command
          endif ! m3rack IFD, LO, PATCH commands

C IFDAB, IFDCD commands
          if (kvracks) then ! vlba IFD, LO commands
            i1=0
            i2=0
            i3=0
            i4=0
C           Find out which IFs are in use for this mode
            do i=1,nchan(istn,icode)
              ic=invcx(i,istn,icode) ! channel number
              if(freqrf(ic,istn,icode) .gt. 0) then
                if (i1.eq.0.and.cifinp(ic,istn,icode)(1:1).eq.'A') i1=ic
                if (i2.eq.0.and.cifinp(ic,istn,icode)(1:1).eq.'B') i2=ic
                if (i3.eq.0.and.cifinp(ic,istn,icode)(1:1).eq.'C') i3=ic
                if (i4.eq.0.and.cifinp(ic,istn,icode)(1:1).eq.'D') i4=ic
              endif
            enddo
            if(i1+i2 .ne. 0) write(lu_outfile,'(a)') 'ifdab=0,0,nor,nor'
            if(i3+i4 .ne. 0) write(lu_outfile,'(a)') 'ifdcd=0,0,nor,nor'

C LO command for VLBA
            write(lu_outfile,'(a)') 'lo='

            do i=1,4
              cbuf="lo=lo"
              nch=6
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
!                klsblo=freqrf(ix,istn,icode).lt.freqlo(ix,istn,icode)
!                if (.not.klsblo) then ! upper
                  nch=ichmv(ibuf,nch,losb(ix,istn,icode),1,1)
!                else ! lower, so reverse
!                  if (ichcm_ch(losb(ix,istn,icode),1,'U').eq.0) then
!                    nch=ichmv_ch(ibuf,nch,'L')
!                  else
!                    nch=ichmv_ch(ibuf,nch,'U')
!                  endif
!                endif ! lower, so reverse
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

      endif ! km3rack .or.km4rack or kvrac.or.kv4rackk
!      goto 9000
C
C 5. Write TAPEFffm procedure.
C    command format: TAPEFORM=index,offset lists

      do irec=1,nrecst(istn) ! loop on recorders
        if (ks2rec(irec).or.kk41rec(irec).or.kk42rec(irec)
     .          .or. KM5Disk(irec)) itype=1

        if (kuse(irec)) then ! procs for this recorder
        if (kvrec(irec).or.kv4rec(irec).or.km3rec(irec).or.
     .    km4rec(irec)) then
          cnamep="TAPEF"//ccode(icode)(1:nco)//cpmode(1:npmode)
          nch=6+nco+npmode
!          cnamep="TAPEF"
!         nch=6
!          nch = ICHMV(lnamep,nch,LCODE(ICODE),1,nco)
!          nch = ICHMV(LNAMEP,nch,lpmode,1,npmode)
          if (krec_append      ) nch = ichmv_ch(lnamep,nch,crec(irec))
          call proc_write_define(lu_outfile,luscn,cnamep)

          cbuf="TAPEFORM"
          nch=9
          if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
          nch = ichmv_ch(ibuf,nch,'=')
         do ihead=1,max_headstack               !2hd
          do i=1,max_pass
cdg            if (ihdpos(1,i,istn,icode).ne.9999) then    
            if (ihdpos(ihead,i,istn,icode).ne.9999) then       !2hd
cdg              nch = nch + ib2as(i,ibuf,nch,3) ! pass number
              nch = nch + ib2as((i+100*(ihead-1)),ibuf,nch,3) ! pass number hd
              nch = mcoma(ibuf,nch)
cdg              nch = nch + ib2as(ihdpos(1,i,istn,icode),ibuf,nch,4) ! offset
              nch = nch + ib2as(ihdpos(ihead,i,istn,icode),ibuf,nch,4) ! offset hd
              nch = mcoma(ibuf,nch)
              ib=1
            endif
            if (ib.gt.0.and.nch.gt.60) then ! write a line
              call delete_comma_and_write(lu_outfile,ibuf,nch)

              cbuf="TAPEFORM"
              nch=9
              if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
              nch = ichmv_ch(ibuf,nch,'=')
              ib=0
            endif
          enddo
        enddo  !2hd end headstack loop
          if (ib.gt.0) then ! finish last line
            call delete_comma_and_write(lu_outfile,ibuf,nch)
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
      if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)
     >        .or.ks2rec(ir).or. Km5Disk(ir)
     >        .or.kk41rec(ir).or.kk42rec(ir)) then
        if((klrack.and.ks2rec(ir)).or.
     >     ((km4rack.or.kvracks.or.kk41rack.or.kk42rack).and.
     >       (.not.kpiggy_km3mode
     >          .or.klsblo
     >          .or.((km3be.or.km3ac).and.k8bbc)
     >          .or.Km5A_piggy)))then

          num_sub_pass=npassf(istn,icode)
          if(num_sub_pass .gt. 1 .and. (km5A.or.km5p)) num_sub_pass=1

          DO IPASS=1,num_sub_pass !loop on subpasses
            call trkall(ipass,istn,icode,
     >        cmode(istn,icode), itrk,cpmode,npmode,ifan(istn,icode))

            if(KM5APigWire(ir) .or. KM5A_Piggy .or.KM5Arec(ir)) then
              ifan_fact=max(1,ifan(istn,icode))
              call find_num_chans_rec(ipass,istn,icode,
     >                ifan_fact, num_chans_obs,num_tracks_rec_mk5)
               call CheckMk5xlat(itrk,ifan_fact,num_chans_obs,
     >            itrackoff,ierr)
               if(ierr .ne. 0) then
                  write(luscn,'(/a)')
     >             "***** PROCS error: Can't do Mk5 track assignments."
                  write(luscn,'(a)')
     >             "***** Tracks don't all fit within one pass."
                  return
               endif
              im5chn_dup=num_tracks_rec_mk5/ifan_fact-num_chans_obs       !This is the number of channels to duplicate
            endif

            if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)
     .        .or.km5disk(ir).or.ks2rec(ir)) then

              call name_trkf(itype,codtmp,cpmode,cvpass(ipass),cnamep)
            else if (kk41rec(ir).or.kk42rec(ir)) then
              cnamep="recp"//ccode(icode)
            endif
            call proc_write_define(lu_outfile,luscn,cnamep)

            if (kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.km4rec(ir)
     >         .or.ks2rec(ir).or.km5Disk(ir)) then
              cbuf="trackform="
              nch=11
            endif
            if (kk41rec(ir).or.kk42rec(ir)) then
              cbuf="recpatch"
              nch=9
              if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(ir))
              nch = ichmv_ch(ibuf,nch,'=')
            endif
            write(lu_outfile,'(a)') cbuf(1:nch)

! This is used below for handling Mark5A and Mark5P
            numtracks=0
            itemp=0
            call ifill4(ItrackVec,MaxTrack,itemp)
            call ifill4(itrackvec(1,2),MaxTrack,itemp)
! Assign tracks for all non-piggyback modes. Piggyback handled separately.
            ib=0
            ib_good=0
            DO ichan=1,nchan(istn,icode) !loop on channels
              ic=invcx(ichan,istn,icode) !channel number
              do ihead =1,max_headstack  !2hd hedzz
                do isb=1,2 ! sidebands
                  do ibit=1,2 ! bits
                    if(nch .eq. 0) then    !initialize front of line.
                      if(kvrec(ir).or.kv4rec(ir).or.km3rec(ir).or.
     >                  km4rec(ir).or.ks2rec(ir).or.Km5disk(ir)) then
                        cbuf="trackform="
                        nch=11
                      else if(kk41rec(ir).or.kk42rec(ir)) then
                        cbuf="recpatch"
                        nch=9
                        if(krec_append)nch=ichmv_ch(ibuf,nch,crec(ir))
                        nch = ichmv_ch(ibuf,nch,'=')
                      endif
                      ib=0
                    endif
                    it=itras(isb,ibit,ihead,ic,ipass,istn,icode)

                    kinclude=.false.
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
C                             Write out a max of 8 channels for 8-BBC stations
                            else if (klast8) then
                             ib=ichan-6
                             if (ib.le.0) kinclude=.false.
                            endif
                          endif
                        endif
                      endif
! track is assigned, and we want to include in track assigntments. do so.
                    if(kinclude) then
                      isbx=isb
                      klsblo=abs(freqrf(ic,istn,icode)).lt.
     >                           freqlo(ic,istn,icode)
                      if (klsblo) then ! reverse sidebands
                        if (isb.eq.1) isbx=2
                        if (isb.eq.2) isbx=1
                      endif ! reverse sidebands
                      if(kvrec(ir) .or.kv4rec(ir) .or.km3rec(ir).or.
     >                    km4rec(ir).or.Km5Disk(ir)) then

! Don't need the 3 anymore since changed itras to give Mark4 numbers
!                        it=it+3
                        if(km5APigWire(ir)) then
                          if(km4form) then
                            ihdtmp=2    !put out on 2nd headstack.
                          else
                            ihdtmp=1
                          endif
                        else
                          ihdtmp=ihead
                        endif

                        if(KM5APigWire(ir).or.KM5Arec(ir))
     >                      it=it+itrackoff

                        if(freqrf(ic,istn,icode) .lt.0) then  !Bad sky frequency.
                           ib_out    =ib_good           !replace bbc, sideband and bit with last good value.
                           isbx      =isbx_good
                           ibit_out  =ibit_good
                        else
                           if(ib_good .eq. 0) then !first time we have a good value.
!                            Use these values for the previous NumTracks times (which were bad.)
                             cbuf="trackform="
                             nch=11
                             do j=1,NumTracks
                               it_out=itvec(j)
                               if(ihdtmp .eq. 2) it_out=it_out+100
                               nch=iaddtr(ibuf,nch,it_out,ib,isbx,ibit)      !first headstack
                               ibvec(j)=ib
                               isbvec(j)=isbx
                               ibitvec(j)=ibit
                             end do
                           endif
                           ib_good=ib
                           isbx_good=isbx
                           ibit_good=ibit
                        endif

                        it_out=it
                        ib_out=ib_good
                        ibit_out=ibit_good

                        if(ihdtmp .eq. 2) it_out=it_out+100
                        if(ib_out.gt. 0) then                 !write out only if have good BBC
                          nch=iaddtr(ibuf,nch,it_out,ib_out,isbx,ibit)
                        endif

                        NumTracks=NumTracks+1      !used latter in piggyback mode.
                        itrackvec(it,ihdtmp)=1
                        itvec(Numtracks)=it
                        ibvec(Numtracks)=ib
                        isbvec(Numtracks)=isbx
                        ibitvec(NumTracks)=ibit

                      else if (ks2rec(ir)) then
                        nch = iaddtr(ibuf,nch,it-1,ib,isbx,ibit)
                      else if (kk41rec(ir).or.kk42rec(ir)) then
! Need to subtract 3 because not Mark4   
                        nch = iaddk4(ibuf,nch,it-3,ib,isbx,
     >                        kk41rack,kk42rack,
     >                        km3rack,km4rack,kvrack,kv4rack)
                      endif
                      ib=1
                    endif  !include
                    if (kinclude.and.ib.ne.0.and.nch.gt.60) then ! write a line
                      call delete_comma_and_write(lu_outfile,ibuf,nch)
                    endif
                  enddo ! bits
                enddo ! sidebands
              enddo !2hd loop on hedzz
            enddo ! loop on channels
            if (nch.ne.11.and.nch .ne. 0) then ! final line
              call delete_comma_and_write(lu_outfile,ibuf,nch)
            endif
! **** Start of Special Mark5 stuff

! Take care of easy part of piggy back.
            if(KM5P_piggy .and. km4form) then  !mapped to 2nd headstack for Mark4form
              do i=1,Numtracks                 !don't need to do anything for VLBAform
                if(nch .eq.0) then
                   cbuf="TRACKFORM="
                   nch=11
                endif
                nch = iaddtr(ibuf,nch,itvec(i)+100,
     >                   ibvec(i),isbvec(i),ibitvec(i))
                if (nch.gt.60) then ! write a line
                  call delete_comma_and_write(lu_outfile,ibuf,nch)
                endif
              end do
            else if(KM5A_piggy) then
              do i=1,Numtracks
                if(nch .eq.0) then
                  cbuf="TRACKFORM="
                  nch=11
                endif
                it=itvec(i)+itrackoff        !itrackoff moves tracks to the beginning.

                if(km4form) then
                  ihdtmp=2
                else
                  ihdtmp=1
                endif

                if(itrackvec(it,ihdtmp) .eq. 0) then     !make sure not used
                  itrackvec(it,ihdtmp)=1
                  it=it+(ihdtmp-1)*100
                  nch = iaddtr(ibuf,nch,it,ibvec(i),isbvec(i),
     >                       ibitvec(i))
                endif

                if (nch.gt.60) then ! write a line
                  call delete_comma_and_write(lu_outfile,ibuf,nch)
                endif
              end do
            endif
            if (nch.ne.11.and.nch .ne. 0) then ! final line
              call delete_comma_and_write(lu_outfile,ibuf,nch)
            endif

            if(KM5Prec(ir).or. KM5P_Piggy) then      !we may need to duplicate some tracks.
              if(Km5P_piggy.and.km4form) then
                ihead=2
              else
                ihead=1
              endif
              do i=1,NumTracks
                if(nch .eq.0) then
                  cbuf="TRACKFORM="
                  nch=11

                endif
                it=itvec(i)
                if(mod(it,2) .eq. 0) then               !even
                  if(itrackvec(it+1,ihead) .eq. 0) then     !next odd is free. Duplicate track
                    it=it+1
                  else
                    it=0
                  endif
                else       !below is for odd tracks. Start at 3.
                  if(itrackvec(it-1,ihead) .eq. 0) then    !previous even is free. Duplicate track.
                    it=it-1
                  else
                    it=0
                  endif
                endif
                if(it .ne. 0) then
                  nch = iaddtr(ibuf,nch,it+(ihead-1)*100,ibvec(i),
     >                       isbvec(i), ibitvec(i))
                  itrackvec(it,ihead)=1
                endif
                if(nch .gt. 60) then  !write last line.
                  call delete_comma_and_write(lu_outfile,ibuf,nch)
                endif
              end do
            endif   !KM5Prec


! For Mark5A, Mark5A_Piggy, and Mark5A_PigWire, we need to fill up to 8, 16, or 32.
! now need to make sure we do number of duplicates, starting with even.
            if(KM5Arec(ir) .or. KM5A_piggy .or. KM5APigWire(ir)) then
              iptr=2   !point to first possible free spot.
              i=1
              ihead=1
              if((KM5A_piggy.or.KM5APigWire(ir)).and.km4form) ihead=2
              do while(im5chn_dup .gt. 0)
                if(nch .eq.0) then
                  cbuf="TRACKFORM="
                  nch=11

                endif
                im5chn_dup =im5chn_dup-1
! find a free spot in the track assignment table.
! Start with 2 on head 1. If can't find even, go to odds. If can't find odds, go to head 2.
!
                do while(ihead .le. 2 .and. iptr .le. 32 .and.
     >            itrackvec(iptr,ihead) .eq. 1)
                  do while(iptr.le.32.and.itrackvec(iptr,ihead).eq.1)
                   iptr=iptr+2*ifan_fact
                  end do
                  if(iptr.gt.32 .and. mod(iptr,2).eq.0) then !didn't find a free even spot.
                    iptr=3                                   !try odd
                    do while(iptr.le.33.and.itrackvec(iptr,ihead).eq.1)
                      iptr=iptr+2*ifan_fact
                    end do
                  endif
                  if(iptr .gt.33) then  !Didn't find a free slot. Try second head.
                    ihead=ihead+1
                    iptr=2
                    i=NumTracks/2+1
                  endif
                end do
                if(iptr .le. 33 .and. ihead .le. 2 .and.   !found unused track!
     >             itrackvec(iptr,ihead) .eq. 0) then
                   itrackvec(iptr,ihead)=1
                   it=iptr
                   if(km4form.and.
     >               (KM5A_piggy.or.KM5APigWire(ir).or.ihead.eq.2)) then
                     it=it+100   !for Mark4 formatters, write out on 2nd headstack.
                   endif
                   nch = iaddtr(ibuf,nch,it,ibvec(i),isbvec(i),
     >                           ibitvec(i))
                endif
                i=i+1                   !point to next one to output.
! write out line if necessary.
                if (nch.gt.60) then ! write a line
                  call delete_comma_and_write(lu_outfile,ibuf,nch)
                endif
              end do
            endif
            if(nch .ne. 11 .and. nch .ne. 0) then  !write last line.
              call delete_comma_and_write(lu_outfile,ibuf,nch)
            endif
! ***** End of special Mark5 Stuff.

            write(lu_outfile,"(a)") 'enddef'
          enddo ! loop on sub-passes
        endif ! km4rack.or.kvracks
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
     >   .or.Km5Disk(ir)) then
        if ((km4rack.or.kvracks).and.
     .      (.not.kpiggy_km3mode.or.klsblo
     .      .or.((km3be.or.km3ac).and.k8bbc))) then

          cnamep="pcalf"//ccode(icode)
          call proc_write_define(lu_outfile,luscn,cnamep)
C PCALFORM=
          write(lu_outfile,'(a)') 'pcalform='
C PCALFORM commands
          DO ichan=1,nchan(istn,icode) !loop on channels
            cbuf="PCALFORM="
            nch=10

            ic=invcx(ichan,istn,icode) ! channel number
C           Use BBC number, not channel number
            ib=ibbcx(ic,istn,icode) ! BBC number
            if (cnetsb(ic,istn,icode).eq.'U') isb=1
            if (cnetsb(ic,istn,icode).eq.'L') isb=2
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
              klsblo=abs(freqrf(ic,istn,icode)).lt.
     .            freqlo(ic,istn,icode)
              if (klsblo) then ! reverse sidebands
                if (isb.eq.1) isbx=2
                if (isb.eq.2) isbx=1
              endif ! reverse sidebands
            endif
            nch = iaddpc(ibuf,nch,ib,isbx,ipctone(1,ic,istn,icode),
     .           npctone(ic,istn,icode))
            call lowercase_and_write(lu_outfile,cbuf)
          enddo ! loop on channels
          write(lu_outfile,"('enddef')")
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
        if (cbarrel(istn,icode)(1:1) .eq."M") then ! manual roll
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
              if (it.ne.2+nrollsteps(istn,icode)) nch = mcoma(ibuf,nch)
            enddo
            call lowercase_and_write(lu_outfile,cbuf)

          enddo ! loop on roll defs
          write(lu_outfile,"(a)") 'enddef'

        endif ! manual roll
      endif ! km4rack.or.kvracks.or.km4fmk4rack

C  End of major loop for each code
      endif ! this mode defined
!      write(luscn,'()')
      ENDDO ! loop on codes

C 9. Write out standard tape loading and unloading procedures

C UNLOADER procedure
      do irec=1,nrecst(istn) ! loop on recorders
        if(ks2rec(irec)) then
          itime2stop=0   !time to stop the tape in seconds.
        else
          itime2stop=3
        endif
        if (kuse(irec) .and. .not.Km5disk(irec)) then
          cnamep="unloader"
          nch=9
          if (krec_append      ) nch = ichmv_ch(lnamep,nch,crec(irec))
          call proc_write_define(lu_outfile,luscn,cnamep)
          if (ks2rec(irec)) then
            call snap_et()
            call snap_rec('=eject')
          else if (kk41rec(irec).or.kk42rec(irec)) then
            call snap_rec('=eject')
            write(lu_outfile,"('!+10s')")
            cbuf="oldtape"
            nch=8
            if (krec_append      ) nch = ichmv_ch(ibuf,nch,crec(irec))
            nch = ichmv_ch(ibuf,nch,'=$')
            write(lu_outfile,'(a)') cbuf(1:nch)

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
        if(ks2rec(irec)) then
          itime2stop=0   !time to stop the tape in seconds.
        else
          itime2stop=3
        endif
        if (kuse(irec).and..not.Km5Disk(irec)) then
            cnamep="loader"
            nch=7
            if (krec_append      ) nch = ichmv_ch(lnamep,nch,crec(irec))
            call proc_write_define(lu_outfile,luscn,cnamep)
            if (ks2rec(irec)) then
              call snap_rw()
              write(lu_outfile,"('!+10s')")
              call snap_et()
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
          endif
          write(lu_outfile,"(a)") 'enddef'

        endif ! procs for this recorder
      enddo ! loop on recorders

C MOUNTER procedure
      if (krec_append) then ! only for 2-rec stations
       do irec=1,nrecst(istn) ! loop on recorders
        if (kuse(irec)) then ! procs for this recorder
          cnamep="mounter"
          nch=8
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
        DO WHILE (IERR.GE.0.AND.ILEN.NE.-1.AND.cbuf(1:1) .ne. "$")
C         read $PROC section
          ICH = 1
          KUS=.FALSE.
          CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
          DO I=IC1,IC2
            IF (JCHAR(IBUF,I).EQ.JCHAR(LSTCOD(ISTN),1)) KUS=.TRUE.
          ENDDO
          if(ic1 .lt. ic2 .and. ic1 .ne. 0) then
             kus=index(cbuf(ic1:ic2),cstcod(istn)(1:1)) .ne. 0
          endif
C
          IF (KUS) THEN ! a proc for us
            CALL GTFLD(IBUF,ICH,ILEN,IC1,IC2)
            IF (IC1.NE.0) THEN ! write proc file
              cnamep=" "
              IDUMMY = ICHMV(LNAMEP,1,IBUF,IC1,MIN0(IC2-IC1+1,12))
              call proc_write_define(lu_outfile,luscn,cnamep)
              CALL GTSNP(ICH,ILEN,IC1,IC2,kcomment)
              DO WHILE (IC1.NE.0) ! get and write commands
                cbuf2=" "
                NCH = ICHMV(IBUF2,1,IBUF,IC1,IC2-IC1+1)
                if (.not.kcomment) call lowercase(cbuf2(1:nch))
                write(lu_outfile,'(a)') cbuf2(1:nch)
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

