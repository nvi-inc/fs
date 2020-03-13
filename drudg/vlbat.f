*
* Copyright (c) 2020 NVI, Inc.
*
* This file is part of VLBI Field System
* (see http://github.com/nvi-inc/fs).
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
      SUBROUTINE VLBAT(ksw,cSNAME,ICAL,LFREQ,IPAS,LDIR,IFT,LPRE,
     .            IYR,IDAYR,IHR,iMIN,ISC,IDUR,LMID,LPST,NSTNSK,LSTN,
     .            MJD,UT,GST,MON,IDA,LMON,LDAY,ISTNSK,ISOR,ICOD,
     .            IPASP,IBLK,IDIRP,IFTOLD,NCHAR,
     .            IRAH2,IRAM2,RAS2,LDSIGN2,IDECD2,IDECM2,DECS2,
     .            IYR2,IDAYR2,IHR2,MIN2,ISC2,LU,IDAYP,
     .            idayrp,ihrp,minp,iscp,iobs,irecp,
     .            idayr_save,ihr_save,min_save,isc_save)
C
C     VLBAT makes an observing file for VLBA DAR/REC systemsf
C
      include '../skdrincl/skparm.ftni'
      include 'drcom.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/skobs.ftni'
C
C  INPUT:
      logical ksw ! true if switching
      character cSNAME(max_sorlen)
      integer*2 LSTN(MAX_STN),LMON(2),
     .LDAY(2),LPRE(3),LMID(3),LPST(3),ldir(max_stn),lfreq,
     .ldsign2
      integer IPAS(MAX_STN),
     .IFT(MAX_STN),IDUR(MAX_STN),ical,
     .iyr,idayr,ihr,imin,isc,nstnsk,mjd,mon,ida,istnsk,isor,icod,
     .ipasp,iblk,idirp,iftold,nchar,irah2,iram2,idecd2,
     .idecm2,iyr2,idayr2,ihr2,min2,isc2,lu,idayp,idayrp,ihrp,minp,
     .iscp,iobs,irecp,idayr_save,ihr_save,min_save,isc_save
      double precision gst,ut
      real ras2,decs2
C
C  LOCAL
      integer itemp
      character*1 cspdir ! tape direction
      integer irec,idir,ispinoff,ihead,idx
     
      integer iwr
      integer isp,ispm,itu
      real sps
      logical ktape,ktrack,kcont,kauto
     
      logical kspinoff ! true if we need to spin the tape down
C                          to the end before changing it
     
   
      integer*2 ldirr
      LOGICAL KNEWTP,KNEWT !true for a new tape; new tape routine
      real tspin ! functions
      integer iSpinDelay

      Data iSpinDelay/0/

C  INITIALIZED:
      DATA ldirr/2HR /
     
C
C
C  HISTORY:
C  890223 NRV REMOVED THIS CODE TO A SEPARATE ROUTINE
C  890324 NRV DECIDED TO USE LOOPING FOR FREQ. SWITCHING
C  890405 NRV CHANGES PER C. WALKER AFTER R&D-1 EXPERIMENT
C  890505 NRV CHANGED IDUR TO AN ARRAY BY STATION
C  890713 NRV CHANGED FREQUENCIES FOR WIDE-BAND R&D-3
C             ADDED ARRAY FOR HEAD OFFSET POSITION
C  890721 NRV ADDED MODE OPTION
C  890919 NRV ADDED DATE CHANGE OUTPUT
C  900316 NRV Changes per C. Walker request to reduce number of characters
C  900504 NRV Changes for "mode 1" to reduce number of characters
C  900810 gag removed "modes" and replaced with kswitch
C  901025 gag fixed some !NEXT! output with wrtap
C  910524 NRV Changed call to WRBBSYN to write buffers
C  910530 NRV Added spin at start of schedule to position tape
C  910705 NRV Added date output whenever it changes
C  910809 NRV Change spin speed to 330
C  921022 NRV Change wrtap call to add irec
C  930304 NRV Don't reset footage to 0 with new tape because we might
C             have to rewind to footage 0. Write out correct date if
C             the date changes in between spin blocks. Write out a block
C             to spin the tape down before changing tapes.
C  930407 nrv Implicit none
C  930708 nrv Get headstack position from arrays read from schedule file.
C  940127 nrv Call wrtrack with the sub-pass ("corresponding pass").
C  940215 nrv Reverse the track selection (got it wrong the first time).
C***********************************************************
C special version to write extra header lines for Bob's pol
C nrv 940617
C***********************************************************
C 960219 nrv Add KSW to call, true if switching.
C 960810 nrv Change itearl to an array
C 970114 nrv Change 8 to max_sorlen. May need to check out the fixed
C            array used for the 'sname' line.
C 970321 nrv Only call wrdur when changing direction for CONTINUOUS
C 970402 nrv Add !NEXT! between stopping tape and postpass.
C 970505 nrv Calculate IFTOLD with ITU=whether to use ITEARL or not.
C 970509 nrv Save tape start time to calculate end time for continuous.
C 970509 nrv Output the first source of a new pass as a new scan before
C            the setup for the new pass. Otherwise the tape will stop
C            before it reaches EOT.
C 970509 nrv Move code to WRSOR for writing the line with source name.
C 971015 nrv Don't write duplicate blocks for non-continuous.
C 980728 nrv Comment out lines no longer needed because VLBA is
C            now using dynamic tape allocation. These are marked
C            with Cdyn.
C 980924 nrv Replace the commented code for RDV11.
C 981207 nrv Comment out again.
C 990404 nrv Set idir=idirp for autoallocate.
C 990528 nrv Remove idir=idirp and let Setup blocks and STOP commands
C            be written. The innitial setup block is needed by operations.
C            The STOP commands give time for tape readbacks.
C 000614 nrv Don't do the block that runs the tape to the end of a pass
C            if tape has auto allocation.
C 011011 nrv New variable KAUTO used to set up for autoallocate.
C 011011 nrv Add KAUTO to wrtap call.
C 021014 nrv Change "seconds" argument in TSPIN to real.
C 2003Nov13 JMGipson.  Added extra argument to TSPIn
! 2006Sep28 JMGipson. Got rid of holleriths. Changed lspdir to ASCII
! 2014Feb04 JMGipson. Modified for new VLBI hardware.
C
C  Initialization

      kcont = tape_motion_type(istn).eq.'CONTINUOUS'
C
C  Add a comment if a new tape is to mounted before the next observation

      kauto = tape_allocation(istn).eq.'AUTO'
     
      irec=irecp
      if (kauto) irec = 1 ! always, for dynamic
      IDIR=+1
      IF (LDIR(ISTNSK).EQ.ldirr) IDIR=-1
      KNEWTP = KNEWT(IFT(ISTNSK),IPAS(ISTNSK),IPASP,IDIR,
     .    IDIRP,IFTOLD)
        ispinoff=0
        kspinoff=.false.
Cdyn
      if (kauto) knewtp = .false. ! always, for dynamic
C     Try letting the setup commands appear at tape reversals.
      if (kauto) idirp = idir ! always, for dynamic
Cdyn
      IF (KNEWTP) THEN ! new tape
        idirp=-1
          if (nrecst(istn).eq.1.and.iftold.gt.10) then !spin down the tape to the end
            ispinoff = ifix((270.0/330.0)*
     >                  tspin(iftold,ispm,sps,iSpinDelay))
            kspinoff = .true.
            if (kcont) kspinoff=.false.
            iftold=0
          endif
          if (iobs.le.1) then
            irec=1
          else ! Turn off recording on the current tape and postpass it
            
          endif
        write(lu,*) " "
        write(lu,'(a)') '!*   ** NEW TAPE **   *!'
        write(lu,*) " "
      ENDIF ! new tape

C   Setup block
        write(lu,*) " "

C  Set up tape parameters

      cspdir="-"

      if (kauto) cspdir="+"
C  ihead is the head offset position in microns
      IHEAD=ihdpos(1,IPAS(ISTNSK),istn,icod)
C  ihddir is not really "direction", it is the corresponding pass within
C  the mode. Use it to tell the wrtrack routine which tracks to record.
        idx = ihddir(1,ipas(istnsk),istn,icod)
        if (idx.eq.0) then
C         pause here
          itemp=1
        endif
C  The "corresponding pass" within the mode may be 1-28 depending on the
C  mode. It is not simply the direction, except for modes B and C. 

C  Calculate tape spin time and block stop time

     
C  If this observation starts at either end of the tape,
C  then we don't need to have the spin blocks, just put REWIND in setup block.

   
      if (iobs.eq.0.or.idayr.gt.idayrp) call wrdate(lu,iyr,idayr)
C     Setup block. None needed for continuous unless change of direction.
  
C  Source name, ra, dec in J2000 coordinates

      call wrsor(csname,irah2,iram2,ras2,ldsign2,idecd2,idecm2,decs2,lu)
      write(lu,'(a)') "qual=999"
      write(lu,'(a)') "disk=off"
      write(lu,'("stop=",i2.2,"h",i2.2,"m",i2.2,"s ","!NEXT!")') 
     >   ihr,imin,isc
      write(lu,'(a)') "qual=  0"
      write(lu,'(a)') "disk=off"
      write(lu,'("stop=",i2.2,"h",i2.2,"m",i2.2,"s ","!NEXT!")') 
     >  ihr2,min2,isc2

C  Set up tracks for forward or reverse

      iwr = 0
      ktape = .false.
      ktrack = .false.
C     ktrack=.true. !****************** always write them for pol

      IF (IDIR.NE.IDIRP.or.iobs.eq.0) THEN !change direction
        ktrack = .true.  ! always write new tracks when changing direction
      else
        ktape = .true.
      ENDIF !change direction
Cdyn
      if (kauto) ktrack = .false. ! always, for dynamic
      if (kauto) ktape = .true.   ! always, for dynamic
Cdyn
C************************************************
C       call vlbap(lu,icod,ierr)
C************************************************
    

C  This is the block for recording
  
      if (idayr2.gt.idayr) call wrdate(lu,iyr2,idayr2)

C *** First cycle: specify channel assignments
C  Start the tape moving

      ISP=1
Cdyn  The tape direction has already been set up above
      IF (IDIR.EQ.+1) then
        cspdir="+"
      else
        cspdir="-"
      end if
Cdyn  Comment out the above for auto
      iwr = 1
      ktape=.false.
 
C  Loop begins in this block
  

C  (save the last write for the end of outer loop)
C  Save tape info for checking on next pass

      IPASP=IPAS(ISTNSK)
C     IFTOLD=IFT(ISTNSK)+IFIX(IDIR*(ITEARL(istn)+IDUR(ISTNSK))*
C    .              SPEED(ICOD,istn))
      itu=itearl(istn)
      if (tape_motion_type(istn).eq.'CONTINUOUS'.and.
     .idir.eq.idirp) itu=0
  
      IDAYP=IDAYR
      idayrp=idayr2
      ihrp=ihr2
      minp=min2
      iscp=isc2
        irecp=irec
      if (idir.ne.idirp) then ! save tape start time
        idayr_save=idayr
        ihr_save=ihr
        min_save=imin
        isc_save=isc
      endif ! save tape start time
      IDIRP=IDIR
C
      RETURN
      END

