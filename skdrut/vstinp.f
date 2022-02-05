*
* Copyright (c) 2020-2022 NVI, Inc.
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
      SUBROUTINE VSTINP(ivexnum,lu,ierr)
C
C     This routine gets all the station information
C     and stores it in common.
C
      implicit none
      include '../skdrincl/skparm.ftni'
      include '../skdrincl/statn.ftni'
      include '../skdrincl/constants.ftni'
C
C History:
! 2022-02-04 JMG Increased size of recorder to 12chars
! 2021-11-20 JMG Previously assumed that mask (az,el) came in pairs.  Now can have step functions
! 2021-04-02 JMG Renamed islcon-->slew_off, stnrat-->slew_rate. Made slew_off real. 
! 2021-10-02 JMG Removed all references to S2. 

C 960517 nrv New.
C 960810 nrv Add tape motion to VUNPDAS call. Store LSTREC.
C 960817 nrv Add tape speed and number of tapes to VUNPDAS.
c 970123 nrv Add calls to ERRORMSG.
C 991103 nrv Initialize LSTREC2 to 'none', LFIRSTREC to 'A'.
C 991123 nrv Recorder 1 and 2, not a and b.
C 001114 nrv For two recorders save second type same as first.
C 010615 nrv Initialize lstrec2 to blanks.
! 2006Nov30 JMGipson. Modified to check recorder type.
! 2016Nov29 JMG. Rack changed to character*20 from character*8 
! 2019Sep03 JMG. Correct length for station name.  Added implicit none 
C
C INPUT:
      integer ivexnum ! vex file number 
      integer lu ! unit for writing error messages
C
C OUTPUT:
      integer ierr ! error number, non-zero is bad

! functions
      integer ptr_ch,fget_station_def,fvex_len
      integer trimlen
      logical kvalid_rack
      logical kvalid_rec  

C LOCAL:      
      integer ierr1
      real slcon(2),SLRATE(2),ANLIM1(2),ANLIM2(2)
      character*8 cocc
      character*12 crec 
      character*20 crack
      character*8 cant,cter,csit
      character*4 caxis

      realr slcon(2)   
      real DIAM
      real sefd(max_band),par(max_sefdpar,max_band)
      integer*2 lb(max_band)
      double precision POSXYZ(3),AOFF
      INTEGER nr,maxt,npar(max_band),nel,i
      character*2 ctlc
      character*2 cid
      character*4 cidt
      character cstid(max_stn)
      double precision poslat,poslon
      integer nstack
      integer il,ite,itl,itg
      integer iret ! return from vex routines
      character*128 cout,ctapemo
      integer nch 
      integer i12 

C
C     1. First get all the def names 
C
      nstatn=0
      iret = fget_station_def(ptr_ch(cout),len(cout),ivexnum) ! get first one
      do while (iret.eq.0.and.fvex_len(cout).gt.0)
        IF  (nstatn.eq.MAX_STN) THEN  !
          write(lu,
     > '("VSTINP20 - Too many antennas.  Max is ",i3,".  Ignored: ",a)')
     >  MAX_STN,cout
        else
          nstatn=nstatn+1
          stndefnames(nstatn)=cout
          iret = fget_station_def(ptr_ch(cout),len(cout),0) ! get next one
        END IF 
      enddo

C     2. Now call routines to retrieve all the station information.

      ierr1= 0
      do i=1,nstatn ! get all station information

        il=fvex_len(stndefnames(i))
        CALL vunpant(stndefnames(i),ivexnum,iret,ierr,lu,
     .    cant,cAXIS,AOFF,SLCON,SLRATE,ANLIM1,ANLIM2,DIAM)      
        if (iret.ne.0.or.ierr.ne.0) then 
          write(lu,
     >    '(a, a,/,"iret=",i5," ierr=",i5)')
     >     "VSTINP01 - Error getting $ANTENNA information for ",
     >     stndefnames(i)(1:il),  iret,ierr
          call errormsg(iret,ierr,'ANTENNA',lu)
          ierr1=1
        endif
        CALL vunpsit(stndefnames(i),ivexnum,iret,IERR,lu,
     >    CID,csit,POSXYZ,POSLAT,POSLON,cOCC,nhorz(i),nel,
     >    azhorz(1,i),elhorz(1,i))     
 
        klineseg(i) = nhorz(i) .eq. nel 
         
        if (iret.ne.0.or.ierr.ne.0) then 
          write(lu,'(a,a,/,"iret=",i5," ierr=",i5)')
     >     "VSTINP02 - Error getting $SITE information for ",
     >      stndefnames(i)(1:il),  iret,ierr
          call errormsg(iret,ierr,'SITE',lu)
          ierr1=2
        endif

        CALL vunpdas(stndefnames(i),ivexnum,iret,IERR,lu,
     .    cIDT,cter,nstack,maxt,nr,lb,sefd,par,npar,
     .    crec,crack,ctapemo,ite,itl,itg,ctlc)

   
        if (iret.ne.0.or.ierr.ne.0) then 
          write(lu,'(a,a,/,"iret=",i5," ierr=",i5)')
     >    "VSTINP03 - Error getting $DAS information for ",
     >    stndefnames(i)(1:il),  iret,ierr
          call errormsg(iret,ierr,'DAS',lu)
          ierr1=3
        endif
C
C     2. Now decide what to do with this information.
C
C       2.1 Antenna information

        cSTCOD(I) = cID
        cPOCOD(I) = cid
        call axtyp(caxis,iaxis(i),1)

        do i12=1,2            
          slew_vel(i12,I) = SLRATE(i12)
          slew_off(i12,I) = SLCON(i12)
!Assume have of the catalog offset is due to settling, the other for time to accelerate.        
          if(slew_off(i12,i) .gt. 0) then
            slew_off(i12,i)=slew_off(i12,i)/2.
            slew_acc(i12,i)=slew_vel(i12,i)/slew_off(i12,i)
          else
            slew_acc(i12,i)=60.0*deg2rad      !no offset--->very fast acceleration 60deg/sec^2
          endif                                   
        end do         
        
        STNLIM(1,1,I) = ANLIM1(1)
        STNLIM(2,1,I) = ANLIM1(2)
        STNLIM(1,2,I) = ANLIM2(1)
        STNLIM(2,2,I) = ANLIM2(2)
        AXISOF(I)=AOFF
        DIAMAN(I)=DIAM
        cterid(i)=cidt
C       For VEX 1.3, antenna name is not there, so use site name

       if(cant .eq. ' ') then
          cantna(i)=csit
       else
          cantna(i)=cant
       endif
       if(cantna(i) .eq. "TIGOCONC") then
          cantna(i) ="TIGO"
       endif 

C
C       2.2 Here we handle the position information.
C     It is not an error to have the occ. code or lat,lon missing.
C
        cstnna(i)=csit
        STNPOS(1,I) = POSLON*deg2rad
        STNPOS(2,I) = POSLAT*deg2rad
        stnxyz(1,i) = posxyz(1)
        stnxyz(2,i) = posxyz(2)
        stnxyz(3,i) = posxyz(3)
        coccup(i)=cocc
C
C     2.4 Here we handle terminal information
C
        if(cter .eq. ' ') then
           cterna(i)=csit
        else
           cterna(i)=cter
        endif

        nch = trimlen(stndefnames(i)) 


        if(.not.kvalid_rack(crack)) then        
            write(lu,'(a)') "VSTINP: for station "// 
     >        stndefnames(i)(1:il)//" unrecognized rack type: "//
     >        crack// "setting to none!"
            crack='none'
        endif 
        cstrack(i)=crack         

        if(.not.kvalid_rec(crec)) then        
            nch=max(1,trimlen(crec))
            write(lu,'(a)') "VSTINP: for station "// 
     >         stndefnames(i)(1:il)//" unrecognized recorder type: "//
     >         crec(:nch)// "setting to none!"
            crec='none'
        endif   
        cstrec(i,1)=crec 
      
        if(nr .eq. 1) then
          cstrec(i,2)='none'
        else
          nr=1
          cstrec(i,2)=crec
        endif

        cfirstrec(i)='1'
        nheadstack(i)=nstack ! number of headstacks
        maxtap(i) = maxt     ! tape length
        nrecst(i) = nr       ! number of recorders
        tape_motion_type(i)=ctapemo   ! tape motion
        itearl(i)=ite                 ! early start time
        itlate(i)=itl                 ! late stop time
        itgap(i)=itg                  ! gap time
C Skip SEFDs for now
C       do ib=1,2
C         idum = igtba(lb(ib),ii)
C         if (ii.ne.0) then 
C           sefdst(ii,i) = sefd(ib)
C           do j=1,npar(ii)
C             sefdpar(j,ii,i) = par(j,ii)
C           enddo
C           nsefdpar(ii,i) = npar(ii)
C           lbsefd(ib,i) = lb(ib)
C         else ! error
C         end if
C       enddo
C
C      2.5 Here we handle the horizon mask
C
! No longer need to do anything.        
       
   
C
C      2.6 Here we handle the coordinate mask
C
      enddo ! get all station information

C Check for duplicate 1-letter codes and change any necessary.

      do i=1,nstatn
        cstid(i)=cstcod(i)(1:1)
      enddo
      do i=2,nstatn
        call idchk(i,cstid,lu)
      enddo
      do i=1,nstatn
        cstcod(i)=cstid(i)//' '
      enddo

      ierr=ierr1
      RETURN
      END
