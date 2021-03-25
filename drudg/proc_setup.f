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
      subroutine proc_setup(icode,codtmp,ktrkf,kpcal,kpcal_d,
     &  itpicd_period_use,cproc_ifd,cproc_vc,cproc_core3h,cproc_thread,
     &  cpmode,lwhich8,ierr)
! include
      implicit none  
      include 'hardware.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'
      include 'drcom.ftni'
      include 'bbc_freq.ftni'
! passed
      integer icode
      logical ktrkf
      logical kpcal
      logical kpcal_d

! returned
      integer itpicd_period_use
      character*10 cproc_vc             !procedure name for VC/BBC
      character*10 cproc_ifd            !procedure name for IFD
      character*10 cproc_core3h         !procedure name for core3h 
      character*10 cproc_thread         !procedure name for thread 
      character*4 cpmode
      character*1 lwhich8               ! which8 BBCs used: F=first, L=last
  
      integer ierr
! functions
      integer iwhere_in_string_list
      integer trimlen
      character*1 cband_char  
 
! Updates
! 2020-12-31 JMG DBBC3 support. Got rid of MK3 stuff 
! 2020-10-28 JMG Got rid of S2  stuff
! 2018-06-18 JMG Yet another attempt to fix cont_cal. In skedf.ctl, if 'cont_cal off' then emit cont_cal=off
! 2018-04-20 JMG Fixed bug introduced in the above.
!
! 2015Jun05 JMG. Replaced squeezewrite by drudg_write.
! 2015Jul17 JMG. Added cont_cal_polarity.
! 2015Jul20 JMG. Only write cont_cal_polarity if "cont_cal=on"
! 2015Jul21 JMg. If cont_cal_polarity is "ASK" then do ask.
! 2016Jan19 JMG. Distinguish between DBBC_DDC and DBBC_PFB
! 2016May24 PdV  check first 8 (not 10) characters of rack for continuous cal
! 2016Sep11 JMG. For cont_cal prompt, make input appear on same line as prompt.
! 2017Dec23 JMG. Updating handling of cont_cal prompt

! local
      character*12 cnamep
      character*4 cont_cal_out
      integer ipass              !No longer have tapes
      integer ichan,ic             !counters.
      integer ifan_fact
      integer irecbw
      character*5 lform          !Mark4 or VLBA

      character*2  codtmp

      logical kroll              !barrel roll on
      logical kman_roll          !manual barrel roll on
      logical ktpicd
      integer iwhere
      integer nch 

      real samptest
      integer num_chans_obs         	!number of channels observed
      integer num_tracks_rec_mk5        !number we record=num obs * ifan
      integer NumTracks
      character*4   ctemp
      logical knewline                 !Do we need to put a newline?

      character*80 ldum          !temporary string
      character*4 lvalid_polarity(5)
      data lvalid_polarity/"0","1","2","3","NONE"/     
 
! Start of code
      knewline=.true. 
      ipass=1
      irec=1
      call setup_name(ccode(icode),cnamep)
      call proc_write_define(lu_outfile,luscn,cnamep)

      kroll = .false.
      knopass=.true.

      ktpicd=
     >  km4rack.or.kvrack.or.kv4rack.or.klrack.or.kdbbc_rack
     > .or.
     > ( (km5rack.or.kv5rack) .and. (km5b .or. km5c.or.knorec(1)) ) .or.
     > knorack

      call trkall(ipass,istn,icode,
     >          cmode(istn,icode), itrk,cpmode,ifan(istn,icode))

      call lowercase(cpmode)
 
      kpiggy_km3mode=.false.

      if(k8bbc.and.(cpmode(1:1).eq."a".or.cpmode(1:1).eq."c"))then
         write(luscn,"(/,a)")
     >        " This is a Mode A or C experiment at an 8-BBC station."
         lwhich8=" "
         do while (lwhich8 .ne. "F" .or. lwhich8 .ne. "L")
           write(luscn,'(a,$)')
     >          " Do you want the first or last 8 channels(F/L) ? "
           read(luusr,'(A)') lwhich8
           call capitalize(lwhich8)
         end do
      endif
   
! Initialize cont_cal_out
      if(cstrack_cap(1:8) .eq. "DBBC_DDC" .or.
     &   cstrack_cap .eq. "DBBC3_DDC") then
        cont_cal_out=cont_cal_prompt
        call lowercase(cont_cal_out)
        do while(.not. (cont_cal_out .eq. "on".or.
     >                  cont_cal_out .eq. "off".or.
     >                  cont_cal_out .eq. "no" .or.
     >                  cont_cal_out .eq. " "))
          if(knewline) then
             write(*,*) " "
             knewline=.false.
          endif 
          write(*,'(a,$)') "     Enter in cont_cal action: (on/off) "
          read(*,*) cont_cal_out
          call lowercase(cont_cal_out)
          kcont_cal = cont_cal_out .eq. "on"
        end do
        if(kcont_cal .and. cont_cal_polarity .eq. "ASK") then
          iwhere=0
          do while(iwhere .eq. 0)
            if(knewline) then
               write(*,*) " "
               knewline=.false.
            endif 
            write(*,'(a, $)')
     >       "     Enter in cont_cal_polarity (0-3, or none): "
            read(*,*) cont_cal_polarity
            call capitalize(cont_cal_polarity)
            iwhere = iwhere_in_string_list(lvalid_polarity,5,
     &                                        cont_cal_polarity)
            if(cont_cal_polarity .eq. "NONE") cont_cal_polarity=" "
          end do
        end if
      endif
      if(.not.knewline) then 
         knewline=.true. 
         cnamep=" "
         call proc_write_define(lu_outfile,luscn,cnamep)
      endif
  

C Find out if any channel is LSB, to decide what procedures are needed.
      klsblo=.false.
      DO ichan=1,nchan(istn,icode) !loop on channels
        ic=invcx(ichan,istn,icode) ! channel number
        if (abs(freqrf(ic,istn,icode)).lt.freqlo(ic,istn,icode))
     >       klsblo=.true.
      enddo
   
      ktrkf=km4rack .or. kvrack .or. kv4rack .or. km4fmk4rack

      if(km5disk .or. knorec(1) .and. km4form) then
        ifan_fact=max(1,ifan(istn,icode))
        call find_num_chans_rec(ipass,istn,icode,
     >            ifan_fact,num_chans_obs,num_tracks_rec_mk5)
        NumTracks=num_chans_obs*ifan_fact
        call proc_mk5_init1(num_chans_obs,num_tracks_rec_mk5,luscn,ierr)
        if(ierr .ne. 0) return
      endif
  
C  PCALON or PCALOFF
      if (kpcal) then
        write(lu_outfile,'(a)') 'pcalon'
      else
        write(lu_outfile,'(a)') 'pcaloff'
      endif

    
C  TPICD=STOP
      if(ktpicd) then
        write(lu_outfile,'(a)') 'tpicd=stop'
      endif

      if (kvrec(irec).or.kv4rec(irec)  .or.
     >    km4rec(irec) .or.
     >    Km5disk.or. knorec(irec).or.ktrkf) then
C  PCALD=STOP
         if (kpcal_d)  write(lu_outfile,'(a)') 'pcald=stop'

C  TRKFffmp
C  Also write trkf for Mk3 modes if it's an 8 BBC station or LSB LO
c..2hd..if piggy make sure mk3 modes are written
        if(ktrkf .and. .not. klrack) then !For LBA, write trkf latter
          cnamep="trkf"//codtmp
          write(lu_outfile,'(a)') cnamep
        endif
C  PCALFff
        if (kpcal_d.and.(km4rack.or.kvrack.or.kv4rec(irec))) then
           call snap_pcalf(codtmp)
        endif
      endif
    
      if(cstrack_cap .eq. "DBBC3_DDC") then
       cproc_core3h="core3h"//codtmp
       write(lu_outfile,'(a)') "core3h"//codtmp//"=$"
      endif
   
      if (kvrec(irec)  .or.kv4rec(irec) .or.
     >    km4rec(irec) .or.Km5disk .or. knorec(irec)) then
        lmode_cmd=" " 
        call proc_get_mode_vdif(cstrec(istn,1),kfila10g_rack)
        call proc_tracks(icode,num_tracks_rec_mk5)
  
        if(cstrec_cap.eq."FLEXBUFF" .or. cstrec_cap.eq."MARK5C") then
          if(lvdif_thread .eq. "IGNORE" ) then 
            continue
          else
            cproc_thread="thread"//codtmp
            write(lu_outfile,'(a)') cproc_thread
          endif          
  
          if(lmode_cmd .ne. "bit_streams") then
            write(lu_outfile,'(a)') "jive5ab_cnfg"
          endif 
        endif  
      endif
  
  
C REC_MODE=<mode> for K4
C !* to mark the time
          if (kk42rec(irec).or.kk41rec(irec)) then ! K4 recorder
            call snap_rec('=synch_on')
            if (kk42rec(irec)) then ! type 2 rec_mode
              irecbw = 16.0*samprate(istn,icode)
              if(krec_append) then
                 write(ldum,'("rec_mode",a1,"=",i3)') crec(irec), irecbw
              else
                 write(ldum,'("rec_mode=",i3)') irecbw
              endif
              call drudg_write(lu_outfile,ldum)
              write(lu_outfile,'("!*")')
            endif ! type 2 rec_mode
C  RECPff
            if (km4rack.or.kvracks.or.kk41rack.or.kk42rack) then  
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
! Note: Don't do Form or tracks command for Mark5 formatters

      if((km4form .or. kvform) .and. .not.
     >        (kk41rec(irec) .or. kk42rec(irec))) then
              call proc_form(icode,ipass,kroll,kman_roll,lform)
      endif ! kvracks or km3rac.or.km4rack but not S2 or K4

C  BBCffb, IFPffb  or VCffb
      cproc_vc=" "    !initialze to no VC command
      ctemp=" " 
      if (kbbc) then
        ctemp="bbc"
      else if(kifp) then
        ctemp="ifp"
      elseif (kvc) then
        ctemp="vc"
      else if(cstrack_cap(1:8) .eq. "DBBC_DDC") then 
       ctemp="dbbc"
      else if(cstrack_cap .eq. "DBBC3_DDC") then
       ctemp="dbbc"
      endif
      if(ctemp .ne. " ") then      
        nch=trimlen(ctemp)
        cproc_vc=ctemp(1:nch)//codtmp//cband_char(vcband(1,istn,icode))
        write(lu_outfile,'(a)') cproc_vc
      endif

      if (kbbc .or. kifp .or. kvc.or.
     &   cstrack_cap(1:4) .eq. "DBBC") then
         cproc_ifd="ifd"//codtmp
         writE(lu_outfile,'(a)') cproc_ifd
       endif ! kbbc kvc kfid

       if(cstrack_cap(1:8) .eq. "DBBC_DDC" .or.
     &    cstrack_cap      .eq. "DBBC3_DDC") then 
          if(kcont_cal) then
             write(lu_outfile,'("cont_cal=on,",a)') cont_cal_polarity
          else
             write(lu_outfile,'("cont_cal=off")')
          endif

          if(idbbc_bbc_target .gt. 0) then
             write(ldum,'(a,i5)') "bbc_gain=all,agc,",idbbc_bbc_target          
             call drudg_write(lu_outfile,ldum)
          endif 
       endif

C  !*
        if (kvrack.and..not.
     >       (kk41rec(irec).or.kk42rec(irec))) then
             write(lu_outfile,'(a)') '!*'
        endif

C  TPICD=no,period
         if(ktpicd) then
           call snap_tpicd("no",itpicd_period_use)
         endif

C DECODE=a,crc
C replaced with CHECKCRC station-specific procedure
          if ((kv4rack.or.km4rack).and..not.
     .       (kk41rec(irec).or.kk42rec(irec))) then ! decode commands
            samptest = samprate(istn,icode)
            if (ifan(istn,icode).gt.0)
     .        samptest=samptest/ifan(istn,icode)
            if (samptest.lt.7.5) then ! no double speed decoding
              write(lu_outfile,'(a)') 'checkcrc'
            endif
          endif ! decode commands
C !*+8s for VLBA formatter
          if (kvrack.and..not.
     >      (kk41rec(irec).or.kk42rec(irec))) then ! formatter wait
            write(lu_outfile,"('!*+8s')")
          endif

         if(km5disk) then
           call proc_mk5_init2(lform,ifan(istn,icode),
     >             samprate(istn,icode),num_tracks_rec_mk5,luscn,ierr)
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
        if(ktpicd) then
          write(lu_outfile,'(a)') "tpicd"
        endif

        if(km5a) write(lu_outfile,'(a)') "mk5=mode?"
        write(lu_outfile,'(a)') "enddef"
        return
        end

