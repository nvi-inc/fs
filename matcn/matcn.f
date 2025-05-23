*
* Copyright (c) 2020, 2023, 2024  NVI, Inc.
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
      program matcn
c      implicit none
      integer*4 ip(5),iclass
      integer i,get_buf
c
C 
C   MATCN controls the I/O to the Microprocessor ASCII Transceiver
C 
C  MODIFICATIONS: 
C
C  WHO  WHEN    WHAT
C  NRV  811012  REMOVED SOME WVR-SPECIFIC CODE, ALL REFERENCES TO LUWVR
C  MWH  870911  MODIFIED FOR USE WITH A400 8-CHANNEL MUX
C  GAG  901220  Added call to logit when initializing MODTBL table upon
C               error condition.
C  gag  920716  Added mode -54 for Mark IV formatter time info for setcl.
C  
C
C     INPUT VARIABLES: (RMPAR)
C
C        IP1    - class number of input buffer
C        IP2    - number of records in class
C
C     Buffer from class I/O contains following:
C     IBUF(1) = mode, must be between MINMOD and MAXMOD
C                  -54 - get MK4 fm data and cpu time
C                  -53 - get ( strobe data and cpu time
C                  -22 - get % strobe data, don't abort on time-out
C                  -21 - get ! strobe data, don't abort on time-out
C                   -8 - get ; strobe data
C                   -7 - get . strobe data
C                   -6 - get - strobe data
C                   -5 - get + strobe data
C                   -4 - get ) strobe data
C                   -3 - get ( strobe data
C                   -2 - get % strobe data
C                   -1 - get ! strobe data
C                    0 - send data and update
C                    1 - send data, verify, and update
C                    2 - send pending data
C                    3 - send pending data and verify 
C                    4 - update pending data
C                    5 - send contents of buffer with no modifications
C                    6 - issue "test/reset" (escape char.)
C                    7 - test alarm, reset alarm
C                    8 - send direct, like mode 5, but use address
C                   55 - send contents of buffer with no modifications, but
C                             reset baud rate first
C     IBUF(2) = device mnemonic 
C     IBUF(3 to end) = data, if mode is 0,1,2,3,4,5 
C 
C     OUTPUT VARIABLES:   (RMPAR) 
C 
C        IP1    - class number of response
C        IP2    - number of records in the class
C        IP3    - error return
C                 +2 - non-acknowledge (i.e. alarm is ON) 
C                 +1 - acknowledge
C                  0 - no response
C                 -1 - trouble with class buffer
C                 -2 - illegal mode 
C                 -3 - unrecognized device
C                 -4 - device time-out on response
C                 -5 - improper response (wrong number of chars)
C                 -6 - verify error 
C                 -7 - MAT device /dev/null (was error setting baud)
C                 -8 - Did not get Mark IV formatter prompt.
C                 -9 - MAT not open
C                -10 - bad buffer length used on read
C                -11 - read error
C                -12 - error setting BAUD
C        IP4    - who we are "MA" 
C        IP5    - not used
C 
C     Buffer returned to caller contains response, if any, to 
C     I/O request.
C 
C   COMMON BLOCKS USED
C 
      include '../include/fscom.i'
      include 'matcm.i'
      include '../include/time_arrays.i'
C 
C   SUBROUTINE INTERFACE: 
C 
C     CALLED SUBROUTINES: IAT, DATAT
C 
C   LOCAL VARIABLES 
C 
      include '../include/boz.i'
C
C               - RMPAR 
C        IMODE  - mode for transmission/reception , stored in common MATCM
C                                                   for communication with iat
C        MAXMOD,MINMOD,MAXDEV 
C               - maximum, minimum mode numbers allowed
C               - max devices
C        NCHAR  - # chars in class buffer we read
C        NCH2   - # chars in buffer 2
C        ICLASS - class # we read
C        ICLASR - class # we respond with
C        NCLREC - # class records
C        ICLREC - counter for outer loop over class records
      dimension ireg(2)
C               - registers from EXEC
      integer*2 ibuf(180),ibuf2(180),ibuf3
C               - buffers for input, output
C        ILEN,ILEN2   - length of above buffers
      integer*2 lstrob(8)
C              - strobe characters for modes < 0, requesting data
      logical kini, knull
C               - TRUE once we have initialized
C        NDEV   - # devices in module table
      dimension modtbl(3,30)
C               - module table, word 1 = mnemonic, word 2 = hex address
C               - word 3 = time out
      integer*2 lalarm(20)
C               - alarm message **NOTE** this should remain at a
C                 max of 20 characters for longest message from MATCN 
      integer ichcm_ch, iflch, fc_rte_prior, portopen, portbaud
      integer*4 ibmatl
      integer portclose
      logical ktp 
C               - true if this message is addressed to the TAPE drive
      equivalence (reg,ireg(1))
      parameter (nbaud=7)
      dimension ibaud(nbaud),ibdrt(nbaud)
C      - list of legal baud rates and corresponding indices
      logical kclear
      logical k5b
      integer it5b(6),it(6)
      logical kfirst
C
C   INITIALIZED VARIABLES
C
      data kini/.false./
      data minmod/-8/, maxmod/11/,  maxdev/30/, nalarm/18/
      data ilen/360/,ilen2/360/
      data lstrob/2h!>,2h%>,2h(>,2h)>,2h+>,2h->,2h.>,2h;>/
      data ibaud/110,300,600,1200,2400,4800,9600/
C effective read character rates from Blue Books
      data ibdrt/10,29.8,57.4,110,203,341,500/
      data kfirst/.true./
C
C
C     1. First get parameters and initialize if necessary.
C
      call char2hol('  *alarm*  (#  )'//char(7)//char(7),
     &             lalarm,1,18)
      call putpname('matcn')
      call setup_fscom
      call read_fscom
c     call fc_rte_lock(1)        ! lock into memory
      iold=fc_rte_prior(FS_PRIOR)
1     call wait_prog('matcn',ip)
      kclear=.true.
      iclass = ip(1)
      nclrec = ip(2)
      call char2hol('ma',ip(4),1,2)
      iclasr = 0
      nclrer = 0
      ierr = 0
C
100   if (kini) goto 200
      call fs_get_ibmat(ibmat)
      ibx=0
      do i=1,nbaud
        if (ibmat.eq.ibaud(i)) ibx=i
      enddo
      if(ibx.eq.0) then
        ibx=1
        call logit7ci(0,0,0,1,-102,'ma',ierr)
      endif
      nchar=iflch(idevmat,64)
      istop=1
      if(ibmat.eq.110.or.ibmat.eq.9600) istop=2
      iparity=2
      ibits=7
      ibmatl=ibmat
      knull=ichcm_ch(idevmat,1,'/dev/null ').eq.0
      lumat=-1
      if(.not.knull) then
         ierr=portopen(lumat,idevmat,nchar,ibmatl,iparity,ibits,istop)
         if (ierr.ne.0) then
            call logit7ci(0,0,0,1,-100,'ma',ierr)
            if(lumat.ge.0) then
               ierr=portclose(lumat)
               if (ierr.ne.0) call logit7ci(0,0,0,1,-103,'ma',ierr)
               lumat=-1
            endif
         endif
      endif
C
      if (lumat.lt.0.and..not.knull) goto 1090
C
C     1.2  Read in device address table.
C     Read table from class buffer
C
      do i=1,nclrec
        ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
        nchar = min(ireg(2),ilen)
        if (i.le.maxdev) then
          idum=ichmv(modtbl(1,i),1,ibuf,1,2)
          idum=ichmv(modtbl(2,i),1,ibuf,4,2)
          if (ichcm_ch(modtbl(2,i),1,'5b').eq.0) then
             idum=ichmv_ch(modtbl(2,i),1,'5B')
          endif
          ifc=7
          ix=ias2b(ibuf,ifc,nchar-ifc+1)
          if(ix.eq.-32768) ix=0
          modtbl(3,i)=ix
        endif
      enddo
      if (nclrec.gt.maxdev) call logit7ci(0,0,0,1,-101,'ma',maxdev)
C
190   ndev = min0(maxdev,nclrec)
C
      idev=1
      kini = .true.
      goto 1090
C
C     2. Begin the loop over class buffer records.
C     Read in the buffer, get the mode and module code.
C     Search the module table for a match.
C     Set up the output buffer with the hex address.
C
200   continue
      if (iclass.eq.0) then
         ierr = -1
         goto 1090
      endif
      if(knull) then
        ierr=-7
        goto 1090
      endif
      if(lumat.lt.0) then
         ierr=-9
         goto 1090
      endif
      call ifill_ch(ibuf,1,180,' ')
      k5b=.false.
      do 900 iclrec = 1,nclrec
        ireg(2) = get_buf(or(ocp020000,iclass),ibuf,-ilen,idum,idum)
c
c to avoid race condition with late clrcl
c
        kclear=iclrec.ne.nclrec
        if(.not.kclear) call clrcl( iclass)
c
        if (ierr.lt.0) goto 900
C                   If we got an error earlier, skip to end of loop
        if (ireg(1).lt.0) then
          ierr = -1
          goto 900
        endif
C
        nchar = min(ireg(2),ilen)
        imode = ibuf(1)
        if(imode.eq.-53.or.imode.eq.55) goto 220
        if (imode.ge.minmod.and.imode.le.maxmod) goto 220
        if(imode.eq.-54) goto 220
        if(imode.eq.-21.or.imode.eq.-22) goto 220
        ierr = -2
        goto 900
C
220     idev = 1
        if (imode.eq.5.or.imode.eq.55) goto 500
C
        do i=1,ndev
          if (ichcm(modtbl(1,i),1,ibuf(2),1,2).eq.0) goto 221
        enddo
        ierr = -3
        goto 900
221     idev = i
        itimeout=modtbl(3,i)
        call fs_get_ibmat(ibmat)
        itn=modtbl(3,i)+1.5*10.*100./float(ibdrt(ibx))+5.5
        ktp=ichcm_ch(modtbl(1,idev),1,'t1').eq.0.or.
     $       ichcm_ch(modtbl(1,idev),1,'t2').eq.0

C
        idum=ichmv_ch(ibuf,1,'#')
        idum=ichmv(ibuf,2,modtbl(2,idev),1,2)
C                   The input buffer now has: #xx <data>
        ibuf2(1) = modtbl(1,idev)
C                   The output buffer now has module mnemonic
C
        if (imode.eq.-54) goto 800
        if (imode.lt.0) goto 400
        if (imode.eq.6) goto 600
        if (imode.eq.7) goto 700
        if (imode.eq.8) goto 800
        if (imode.eq.9) goto 800
        if (imode.eq.10) goto 800
        if (imode.eq.11) goto 800
C
C
C     3. Here we are sending data to the MAT.
C     Put an "=" sign before the data
C
        idum=ichmv_ch(ibuf,4,'=')
        call fs_get_kecho(kecho)
        call datat(imode,ibuf,nchar,lumat,kecho,
     .             ibuf2(2),nch2,ierr,itn)
        goto 899
C
C
C     4.  Here we are requesting a type of data from the device.
C     For tape drive communications, the buffer is set up like:
C                   #nns>
C     For other units, the buffer is:
C                   #nns
C     where s=strobe character
C 
400     continue
        istrob=imode
        if(imode.eq.-21.or.imode.eq.-22) then
           istrob=istrob+20
        elseif(imode.eq.-53) then
           istrob=-3
        endif
        nchar = ichmv(ibuf,4,lstrob(-istrob),1,2)-1
C                   Put proper strobe character followed by > into buffer 
        call fs_get_kecho(kecho)
        if (ktp) call iat(ibuf,nchar,lumat,kecho,ibuf2(2),
     &    nch2,ierr,itn)
C                   Send #nns> to the tape drive and let it get 
C                   ready for the following data request. 
        if (ktp) nchar = 4
C                   For the tape drive, we send #nn? only 
C                   For the other modules, we already have #nns> in the 
C                   buffer and NCHAR is set at the > character
        nchar = ichmv_ch(ibuf,nchar,'?')-1
C                   Put the ? into the buffer, so that
C                   for the tape drive, we have #nn?
C                   and for the others, we have #nns?
        call fs_get_kecho(kecho)
        call iat(ibuf,nchar,lumat,kecho,ibuf2(2),nch2,ierr,itn)
        goto 899
C
C
C     5. For mode 5, send buffer straight to MAT, get response,
C     if any, and return to caller.
C
500     continue
        call fs_get_ibmat(ibmat)
        if(imode.eq.55) then
          ibx=0
          do i=1,nbaud
            if (ibmat.eq.ibaud(i)) ibx=i
          enddo
          if(ibx.eq.0) then
             ibx=1
             call logit7ci(0,0,0,1,-102,'ma',ierr)
          endif
          ierr=portbaud(lumat,ibmat)
          if(ierr.ne.0) then
             ierr=-12
             goto 899
             endif
          itn=modtbl(3,i)+1.5*10.*100./float(ibdrt(ibx))+5.5
       else
          nch=iscn_ch(ibuf(2),1,nchar-2,'#')
          if(nch.ne.0.and.nch.lt.nchar-3) then
             idum=ichmv(ibuf3,1,ibuf(2),nch+1,2)
             call lower(ibuf3,2)
             do i=1,ndev
                if (ichcm(modtbl(2,i),1,ibuf3,1,2).eq.0) then
                   itn=modtbl(3,i)+1.5*10.*100./float(ibdrt(ibx))+5.5
                   goto 501
                endif
             enddo
          endif
       endif
c do something sensible at least for itn if we can't find the device
c this prevents the FS from hanging if the device is turned off or fails
c when an answer is expected
        itn=1.5*10.*100./float(ibdrt(ibx))+5.5
501     continue
        call fs_get_kecho(kecho)
        call iat(ibuf(2),nchar-2,lumat,kecho,ibuf2(2),
     &    nch2,ierr,itn)
        goto 899
C
C
C     6. TEST/RESET mode messages.  Buffer already contains #xx.
C
600     continue
        call pchar(ibuf,4,ocp33)
        nch = 4
        call fs_get_kecho(kecho)
        call iat(ibuf,nch,lumat,kecho,ibuf2(2),nch2,ierr,itn)
C                   Send <escape> to the device
        if (ierr.lt.0.or.nch2.eq.0) goto 601
        call put_buf(iclasr,ibuf2,-nch2-2,'fs','  ')
        nclrer = nclrer + 1 
601     continue
        idum=ichmv_ch(ibuf,1,'UUUUU')
C                   Send some UU's to synch up again
        nch = 5 
        call fs_get_kecho(kecho)
        call iat(ibuf,nch,lumat,kecho,ibuf2(2),nch2,ierrx,itn)
        goto 900
C 
C 
C     7. Query and reset alarm.  Buffer contains address. 
C 
700     idum=ichmv_ch(ibuf,4,'''') 
        nch = 4 
        call fs_get_kecho(kecho)
        call iat(ibuf,nch,lumat,kecho,ibuf2(2),nch2,ierr,itn)
C                   Send ' to query alarm 
        if (ierr.lt.0.or.nch2.eq.0) goto 900
        call put_buf(iclasr,ibuf2,-nch2-2,'fs','  ')
        nclrer = nclrer + 1 
        idum=ichmv_ch(ibuf,4,'"') 
        nch = 4 
        call fs_get_kecho(kecho)
        call iat(ibuf,nch,lumat,kecho,ibuf2(2),nch2,ierr,itn)
C                   Send " to reset alarm 
        idum=ichmv_ch(ibuf,4,'''') 
        nch = 4 
        call fs_get_kecho(kecho)
        call iat(ibuf,nch,lumat,kecho,ibuf2(2),nch2,ierr,itn)
        goto 899
C 
C 
C     8. Send buffer directly.  Address has already been substituted
C     into first three characters.  Fill in fourth with a blank.
C 
800     continue
        if (ichcm_ch(ibuf,1,'#5B').eq.0) then
c
c  makr5b needs a very small delay between consecutive commands
c
           if(k5b) then
              call fc_rte_time(it,it(6))
              idiff=(it(2)-it5b(2))*100+it(1)-it5b(1)
              if(idiff.lt.0) idiff=idiff+6000
              if(idiff.lt.2) call susp(1,2)
           endif
           idum=ichmv(ibuf,4,ibuf,5,nchar-3)
           nchar=nchar-1
        else
           idum=ichmv_ch(ibuf,4,' ') 
        endif
        if(imode.eq.9.or.imode.eq.11.or.imode.eq.-54) then
           nchar=nchar+1
           call pchar(ibuf,nchar,10)
        else if(imode.eq.10) then
           nchar=nchar+1
           call pchar(ibuf,nchar,mk4dec_fs)
           m4dt=mk4dec_fs
        endif
        call fs_get_kecho(kecho)
        call iat(ibuf,nchar,lumat,kecho,ibuf2(2),nch2,ierr,itn)
        if (ichcm_ch(ibuf,1,'#5B').eq.0) then
           call fc_rte_time(it5b,it5b(6))
           k5b=.true.
        endif
        goto 899
C 
C 
C     9.  End of outer loop on class records. 
C 
 899    continue
c on first read, if time-out close and re-open, maybe a 
C solution for an intermittent kernel 2.6 problem with SuperMicro C7SIM-Q?
        if(kfirst.and.ierr.eq.-4) then
           call logit7ci(0,0,0,1,-104,'ma',0)
           ierr=portclose(lumat)
           if (ierr.ne.0) call logit7ci(0,0,0,1,-103,'ma',ierr)
           lumat=-1
           nchar=iflch(idevmat,64)
           ierr=portopen(lumat,idevmat,nchar,ibmatl,iparity,ibits,istop)
           if (ierr.ne.0) then
              call logit7ci(0,0,0,1,-100,'ma',ierr)
              if(lumat.ge.0) then
                 ierr=portclose(lumat)
                 if (ierr.ne.0) call logit7ci(0,0,0,1,-103,'ma',ierr)
                 lumat=-1
              endif
           endif
           if(lumat.ge.0) then
              call logit7ci(0,0,0,1,-105,'ma',ierr)
           else
              call logit7ci(0,0,0,1,-106,'ma',ierr)
           endif
c this was still a time-out even if we recovered
           ierr=-4
        endif
c never again
        kfirst=.false.
        if (imode.eq.-21.or.imode.eq.-22) then
           call put_buf(iclasr,ierr,-4,'fs','  ')
           nclrer = nclrer + 1 
           ierr=0
        elseif((ierr.lt.0.and.ierr.ne.-5).or.nch2.eq.0) then
           goto 900 
        endif
C                   If there was a real error, skip any responses 
C                   EXCEPTION: for wrong-length responses, report 
C                   the actual response - it might be interesting. 

        call put_buf(iclasr,ibuf2,-nch2-2,'fs','  ')
        nclrer = nclrer + 1 
C                   Put response into class 
        if(imode.eq.-53 .or. imode.eq.-54) then
          call put_buf(iclasr,centisec,-24,'fs','  ')
          nclrer=nclrer +1
        endif
        if (ierr.ne.+2) goto 900
        idum=ichmv(lalarm, 1,modtbl(1,idev),1,2)
        idum=ichmv(lalarm,10,modtbl(1,idev),1,2)
        idum=ichmv(lalarm,14,modtbl(2,idev),1,2)
        call put_buf(iclasr,lalarm,-nalarm,'fs','  ')
C                   If alarm was on, send message 
        nclrer = nclrer + 1 
C 
900   continue
C 
C     10. Now we have read all of the class records.  There may have
C     been an error in one record, and there may also be outstanding
C     response class numbers.  If so, do not send back partial classes. 
C     EXCEPTION: for wrong-length responses (IERR=-5) send it back. 
C 
      if (ierr.lt.0 .and. ierr.ne.-5 .and. iclasr.ne.0) then
        do i=1,nclrer
          ireg(2) = get_buf(iclasr,ibuf,-ilen,idum,idum)
        enddo
        iclasr = 0
        nclrer = 0
      endif
C
1090  continue
      ip(1) = iclasr
      ip(2) = nclrer
      ip(3) = ierr
      call char2hol('ma',ip(4),1,2)
      ip(5) = modtbl(1,idev)
C                   SUSPEND HERE *********************************
      if(kclear) call clrcl( iclass)
      goto 1
      end
