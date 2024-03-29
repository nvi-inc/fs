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
      SUBROUTINE STINP(IBUFX,ILEN,LU,IERR)
      implicit none
C
C     This routine reads and decodes a station entry
C
      include '../skdrincl/skparm.ftni'
      include "../skdrincl/constants.ftni"
C
C  INPUT:
      integer*2 IBUFX(*)
      integer ilen,lu
C      - buffer holding source entry
C     ILEN - length of IBUFX in words
C     LU - unit for writing error messages
C
C  OUTPUT:
      integer ierr
C     IERR - error number, non-zero is bad
C
      include '../skdrincl/statn.ftni'
      include '../skdrincl/freqs.ftni'
C
! functions
      integer igtba              ! functions
      integer trimlen
      integer iwhere_in_string_list
     
C  LOCAL:
      integer MaxBufIn
      parameter (MaxBufIn=256)
      integer*2 ibufin(MaxBufIn)
      character*(2*MaxBufIn) cbufin,cbufin0
      equivalence (ibufin,cbufin)

      logical kline
      integer*2 LAXIS(2)
      character*8 cname
      character*4 caxis
      equivalence (caxis,laxis)

      real*4 SLRATE(2),ANLIM1(2),ANLIM2(2)

      real slcon(2)
      REAL*4 AZH(MAX_HOR),ELH(MAX_HOR),CO1(MAX_COR),CO2(MAX_COR)
      real*4 DIAM
      real*4 sefd(max_band),par(max_sefdpar,max_band)
      character*2 cb(max_band)
      real*8 POSXYZ(3),AXOFF
      real tol
      integer iwhere
      character*1 ctype


C      - these are used in unpacking station info
      INTEGER J,nr,maxt,npar(max_band)
      integer ib,ii,nco,nhz,i
      integer*2 lid,lidpos,lidhor

      character*20 crack
      character*12 crec1,crec2
      character*4 cidt,cidhor,cidpos
      character*2 cid
      character*1 c1
      equivalence (cid,lid), (c1,cid)
      equivalence (cidpos,lidpos),(cidhor,lidhor)

      double precision poslat,poslon
      double precision chklat,chklon,rht
      integer ibitden
      integer nstack

      integer nch
      integer i12   !counter 

! These are used to parse the input line.
      integer MaxToken
      integer NumToken
      parameter(MaxToken=20)
      character*30 ltoken(MaxToken)
      integer itoken

      integer ierr_ptr
      character*12 lerror_vec(16)

      data lerror_vec/"Axoff",
     >  "Slewrate 1","slew_con1","Ant Lim1_lo","Ant Lim1_hi",
     >  "Slewrate 2","slew_con2","Ant Lim2_lo","Ant Lim2_hi",
     >  "Diameter",
     >  "PosX","PosY", "PosZ", " ","Latitude", "Longitude"/
C
C  INITIALIZED
C
C  PROGRAMMER: NRV
C  WHEN   WHO  CHANGES
C  830423 NRV ADDED AXIS TYPES 2,4 FOR X,Y MOUNTS
C  840924 MWH GET STATION NAME FROM POSITION ENTRY
C  880314 NRV DE-COMPC'D
C  880603 PMR revised for workstation (removed PCOUNT)
C  881221 GAG added nrv's calls to UNPVH for HORIZON AND COORDINATE MASKS
C  891116 NRV Changed UNPVT call to get multiple SEFDs and bands
C  891117 NRV restored UNPVT call
C  891215 NRV Store antenna names in new array LANTNA
C  891228 NRV Changed UNPVA call to add PCOUNT
C  900116 NRV Changed UNPVT call to add SEFD info
C  900119 NRV Removed lb, sefd from UNPVT and moved to LO lines
C  900125 NRV Changed terminal ID to integer
C  900126 NRV Changed calling sequence to replace INUM with LU
C  921101 nrv Add nr to unpvt call
C  930225 nrv implicit none
C  940428 nrv Always store away LBSEFD even if frequencies are available.
C             If new frequencies are selected, this array is checked, so
C             it needs to be set up correctly and this is the place to do it.
C 951116 nrv Remove maxpass and replace with bit density
C 960208 nrv Increment NSTATN after checking for MAX_STN
C 960227 nrv Make terminal ID up to 4 characters, not integer.
C 960409 nrv Change UNPVT call to include nstack, ibitden
C 980629 nrv If "auto" for tape length, set tape_motion_type=DYNAMIC
C 990607 nrv Add rack,rec,fm to UNPVT call. Store values.
C 990620 nrv Check rack,rec,frm types for consistency.
C 990620 nrv Store S2 mode.
C 991028 nrv Initialize second recorder type to 'none'.
C 991103 nrv For errors in later fields on the input lines, try decoding anyway.
C 991103 nrv Remove checks for recorder/rack pairs. Add recb to unpvt call.
C 991122 nrv Remove S2 speed and mode to be set in the modes section. Set
c            S2 speed.
C 991123 nrv Recorder 1 and 2, not a and b.
C 000126 nrv Convert S2 tape length from minutes (e.g. 360) to feet
C            (e.g. 7560) using speed.
C
C     1. Find out what type of entry this is.  Decode as appropriate.
C
! 2021-11-10 JMG. Modified slew algorithm  so that uses slew_off, slew_vel, slew_acc.  
!                Since sked catalogs only have an offset and a rate term, must infer slew_off and  slew_acc
! 2021-04-02 JMG Renamed islcon-->slew_off, stnrat-->slew_rate. Made slew_off real. 
! 2020-11-11 JMG. Catch bug if Station ID has wrong format in horizon mask. 
! 2020-10-02  JMG. Removed all references to S2
! 2007Mar30  JMG. Checked to make sure didn't duplicate codes.
! 2007Apr05  JMG. But OK to have duplicate " " for horizon mask.
! 2009Mar03  JMG. Fixed bug in OR statement with K5.
! 2013Mar22  JMG. Fix problem if first antenna limit is negative. (i.e., (-270,270) instead of (90, 630)
! 2013Sep17  JMG. Fixed incorrect error message for latitude. Said "A line" but was "B line".
! 2015Jun30  JMG. Changed Rack, recorder length from 8-->12 chars.
! 2016Jul28  JMG. Changed rack length to 20 chars.
!                 Initialize cfirtrec(i)="1" even if have problems reading "T " line.
! 2017Mar13  JMG. If rack or recorder are not recongnized, set them to 'unknown' and continue.
! 2022-02-10 JMG. Use subroutine to stuff crec, crack into appropriate slots. 


      cbufin=" "
! AEM 20050314 init vars
      caxis = " "
      cname = " "
      crack = " "
      crec1 = " "
      crec2 = " "
      cid = " "
      cidt = " "
      cidpos = " "
      cidhor = " "

      do i=1,min(ilen,MaxBufIn)
        ibufin(i)=ibufx(i)
      end do
      i=index(cbufin,char(0))
      if(i .ne. 0) then
         cbufin(i:2*MaxBufin)=" "
      endif
      cbufin0=cbufin    !cbufin is modified below. Want to keep a copy

      ctype=cbufin(1:1)

      cbufin(1:1)=" "            !this just gets rid of the type: A,P,T,C,H

! initalize all the tokens.
      do i=1,Maxtoken
        ltoken(i)=" "
      end do

! extract all the tokens and parcel them out.
!      call capitalize(cbufin)
      call splitNtokens(cbufin,ltoken,Maxtoken,NumToken)
      nch=trimlen(cbufin)
   
! Antenna line
! ID  Name    Caxis axix_off rate1 con1 low1   high1  rate2 con2  low2  high2 diam  Cidpos cidt cidhor
!  1   2       3      4       5    6     7     8       9    10   11    12     13     14     15 16
!  B  BR-VLBA  AZEL 2.00000  90.0  0    270.0  810.0  30.0  0    2.3   88.0  25.0    Br     BR BV
      if(ctype .eq. "A") then
        if(NumToken .lt. 14) goto 950
        cid = ltoken(1)
        cname=ltoken(2)
        caxis=ltoken(3)

        do itoken=4,13
          ierr_ptr=itoken-3
          if(itoken .eq. 4) then
            read(ltoken(4),*,err=900) axoff
          else if(itoken .eq. 5) then
            read(ltoken(5),*,err=900) slrate(1)
          else if(itoken  .eq. 6) then
            read(ltoken(6),*,err=900) slcon(1)
          else if(itoken  .eq. 7) then
            read(ltoken(7),*,err=900) anlim1(1)
          else if(itoken  .eq. 8) then
            read(ltoken(8),*,err=900) anlim1(2)
          else if(itoken  .eq. 9) then
            read(ltoken(9),*,err=900) slrate(2)
          else if(itoken  .eq. 10) then
            read(ltoken(10),*,err=900) slcon(2)
          else if(itoken  .eq. 11) then
            read(ltoken(11),*,err=900) anlim2(1)
          else if(itoken  .eq. 12) then
             read(ltoken(12),*,err=900) anlim2(2)
          else if(itoken  .eq. 13) then
            read(ltoken(13),*,err=900) Diam
          endif
        end do
! This takes care of the case where someone gives a negative cable wrap.
        if(caxis .eq. "AZEL") then
        if(anlim1(1) .lt. 0) then
           anlim1(1)=anlim1(1)+360
           anlim1(2)=anlim1(2)+360
        endif
        if(anlim2(1) .lt. 0) then
           anlim2(1)=anlim2(1)+360
           anlim2(2)=anlim2(2)+360
        endif
        endif

        cidpos=ltoken(14)
        if(NumToken .ge. 15) then
          cidt=ltoken(15)
        endif
        if(NumToken .ge. 16) then
          cidhor=ltoken(16)
          if(cidhor .eq. "--".or.cidhor.eq."-") cidhor=" "
        endif
        
        i=iwhere_in_string_list(cstcod(i),nstatn,c1)
        if(i .eq. 0) then        !new entry.
          if(nstatn .lt. Max_stn) then
             nstatn=nstatn+1
             i=nstatn
          else
             write(lu,'(a,i3)')
     >       "STINP: Too many antennas. Max is: ", max_stn
             goto 910
          endif
        endif
C
C     2.2 Now we have, in "I", the proper index to use for the antenna
C     information.
C NO: Store the position ID temporarily into the first word of STNPOS.
C     Put the position ID into a permanent place in LPOCOD
C
        cSTCOD(I) = c1
        call axtyp(laxis,iaxis(i),1)
        
        do i12=1,2        
          slew_vel(i12,I) = SLRATE(i12)*deg2rad/60.0d0
          slew_off(i12,I) = SLCON(i12)
!Assume have of the catalog offset is due to settling, the other for time to accelerate.        
          if(slew_off(i12,i) .gt. 0) then
            slew_off(i12,i)=slew_off(i12,i)/2.
            slew_acc(i12,i)=slew_vel(i12,i)/slew_off(i12,i)
          else
            slew_acc(i12,i)=60.0*deg2rad      !no offset--->very fast acceleration 60deg/sec^2
          endif                                   
        end do         
           
        STNLIM(1,1,I) = ANLIM1(1)*deg2rad
        STNLIM(2,1,I) = ANLIM1(2)*deg2rad
        STNLIM(1,2,I) = ANLIM2(1)*deg2rad
        STNLIM(2,2,I) = ANLIM2(2)*deg2rad
        AXISOF(I)=AXOFF
        DIAMAN(I)=DIAM
        cPOCOD(I)   = cIDPOS
        cterid(i)=cidt
        chccod(i) = cidhor

        if(i .ne. 1) then
          iwhere=iwhere_in_string_list(cpocod,i-1,cidpos)
          if(iwhere .ne. 0) then
            write(*,*) "STINP ERROR: Duplicate position codes: ",
     >        cidpos
            goto 960
          endif

          iwhere=iwhere_in_string_list(cterid,i-1,cidt)
          if(iwhere .ne. 0) then
             write(*,*) "STINP ERROR: Duplicate terminal ID code: ",
     >         cidt
            goto 960
          endif

          if(cidhor .ne. " ") then
            iwhere=iwhere_in_string_list(chccod,i-1,cidhor)
            if(iwhere .ne. 0.and. cidhor .ne. " ") then
               write(*,*) "STINP ERROR: Duplicate horizon mask code: ",
     >         cidhor
             goto 960
            endif
          endif
        endif

        NHORZ(I) = 0
        cantna(i)=cname
        return
      else if(ctype .eq. "P") then
        if(numtoken .lt. 8) goto 950
! Do the position line.
! cidpos cname   posxyz(1)        posxyz(2)     posxyz(3)      Locc      poslon  poslat    Who
!   1    2          3              4               5             6       7        8          9
!  Sc  SC-VLBA   2607848.52822 -5488069.69340  1932739.53143   76159001  64.58   17.76      GLB1069
        cid=ltoken(1)
        cname=ltoken(2)
        do itoken=3,8
           ierr_ptr=itoken+8
          if(itoken .eq. 3) then
            read(ltoken(3),*,err=900) posxyz(1)
          else if(itoken .eq. 4) then
            read(ltoken(4),*,err=900) posxyz(2)
          else if(itoken .eq. 5) then
            read(ltoken(5),*,err=900) posxyz(3)
          else if(itoken .eq. 6) then
            continue
          else if(itoken .eq. 7) then
            read(ltoken(7),*,err=900) poslon
          else if(itoken .eq. 8) then
            read(ltoken(8),*,err=900) poslat
          endif
        end do

        i=iwhere_in_string_list(cpocod,nstatn,cid)
        if(i .eq. 0) then
          write(lu,'("STINP- Problem with: ",a)') cbufin0(1:nch)
          write(lu,'("STINP21 - Pointer not found: ",a)') cid
          return
        endif
C
C     2.3 Now "I" contains the index into which we will put the
C     position information.
C
        cstnna(i)=cname
        stnxyz(1,i) = posxyz(1)
        stnxyz(2,i) = posxyz(2)
        stnxyz(3,i) = posxyz(3)
        ! Do a quick check.
        call plh(stnxyz(1,i),chklat,chklon,rht)
        chklat=chklat*rad2deg
        chklon=-chklon*rad2deg    !note minus sign
        tol=0.4
        if(abs(chklat-poslat) .gt. tol .or.
     >       abs(chklon-poslon) .gt. tol .and.
     >      abs(360-abs(chklon-poslon)) .gt. tol) then
           write(lu,'(a,a,a)')
     >      "STINP Warning: For station ", cname,
     >      " Inconsistent position information in 'P' line!"
           write(lu,'(a,2f8.2)')
     >        "Calculated position: ",chklat,chklon
           write(lu,'(a,2f8.2)')
     >        "Input Lat, Lon:      ",poslat,poslon
           write(lu,'(a)') "Using calculated positions"
        endif
        STNPOS(1,I) = CHKLON*deg2rad
        STNPOS(2,I) = CHKLAT*deg2rad

        coccup(i)=ltoken(6)
        return
      else if(ctype .eq."T") then
! Terminal line.
! ID   Terminal  HDXDen  NumTape Bl   SEFD  B   SEFD2 SEFD1 params       SEFD2 Params
! 101  MOJ-VLBA 1x56000  17640    X   750   S   800   X 1.0 0.954 0.0464 S 1.0 0.974 0.0263 VLBA VLBA
        cidt=ltoken(1)
        cname=ltoken(2)

        j=8
        CALL UNPVT(IBUFX(2),ILEN-1,IERR,cIDT,cNAME,ibitden,
     >   nstack,maxt,nr,cb,sefd,j,par,npar,crack,crec1,crec2)
!
! Try to get the station by looking at the terminal ID at station name.
!
        i=0
        if (cidt .ne. " " .and. cidt .ne. "--") then
          i=iwhere_in_string_list(cterid,nstatn,cidt)
        endif
        if (i.eq. 0) then ! try to match station name
          i=iwhere_in_string_list(cstnna,nstatn,cname)
        endif
        IF  (I.eq.0) THEN  !matching entry not found
          write(lu,'("STINP24 - Name or ID match not found: ",a)') cname
          goto 910
        END IF  !matching entry not found

! Initialize to default values. Must do here before error exit.
        cfirstrec(i)="1 "

! This ierr is from unpvt and indicates a problem in parsing the line.
!        if(ierr .ne. 0) goto 910
! 2017Mar13. Continue on.

! Assume the terminal id line is correct.
        if(cidt .ne. " " .and. cidt .ne. "--") then
          cterid(i)=cidt
        endif
C  Got a match. Initialize names.
        cterna(i)=cname

! Put rack and recorder in appropriate slots.  
! Doing it this way ensures SKD and VEX files are treated the same. 

        call store_rack_and_recorder(lu,cstnna(i),
     >    crack,crec1, cstrack(i),cstrec(i,1))

C       If second recorder is specified and the first recorder was S2
C       then save the second recorder field as the S2 mode.
        if (crec2 .eq. " ") then
         if(nr .eq. 2) nr=1
        endif

        nrecst(i) = nr
        if (cstrec(i,1)(1:2) .eq. "K4")  then ! set K4 variables
          nheadstack(i)=1
          maxtap(i) = maxt ! conversion??
          ibitden_save(i)=1
        else if(cstrec(i,1) .eq. "Mark5A" .or.
     >          cstrec(i,1) .eq.  "K5") then
          maxtap(i)=10000         !set to 10 thousand feet.
          bitdens(i,1)=1.000d11   !very high means we don't need to worry about it.
          nheadstack(i)=nstack
        else ! set Mk34 variables
          maxtap(i) = maxt
          ibitden_save(i)=ibitden
          nheadstack(i)=nstack
        endif
        do ib=1,2
          ii = igtba(cb(ib))
          if (ii.ne.0) then ! got frequencies selected already
            sefdst(ii,i) = sefd(ib)
            if (npar(ii).gt.0) then
              do j=1,npar(ii)
                sefdpar(j,ii,i) = par(j,ii)
              enddo
            endif
            nsefdpar(ii,i) = npar(ii)
            cbsefd(ib,i) = cb(ib)
          else ! store away until frequencies are selected
            sefdst(ib,i) = sefd(ib)
            if (npar(ib).gt.0) then
              do j=1,npar(ib)
                sefdpar(j,ib,i) = par(j,ib)
              enddo
            endif
            nsefdpar(ib,i) = npar(ib)
            cbsefd(ib,i) = cb(ib)
          end if
        enddo
        return

      else if(ctype .eq. "C") then    !Coordinate type mask
        J = 8
        CALL UNPVH(IBUFX(2),ILEN-1,IERR,LID,NCO,CO1,CO2)
        IF (IERR.NE.0) THEN
          if (ierr.eq.-99) then
            write(lu,*)
     >      "STINP260 - Too many coordinate mask pairs. Max is ",max_cor
            goto 910
          endif
          if (ierr.eq.-103) then
C           error for no matching value, which is ok
          endif
        END IF  !
        i=iwhere_in_String_list(chccod(i),nstatn,cid)
        IF (I.eq.0 ) THEN ! matching entry not found
          write(lu,'("STINP26 - Pointer not found.  Coordinate mask ")')
          goto 910
        ELSE ! keep it
          NCORD(I) = NCO
          DO J=1,NCORD(I)
            CO1MASK(J,I) = CO1(J)*deg2rad
            CO2MASK(J,I) = CO2(J)*deg2rad
          END DO
        END IF
        return
      ELSE IF (ctype .eq. "H")  then   ! Horizon type mask.
        J = 8
        CALL UNPVH(IBUFX(2),ILEN-1,IERR,LID,Nhz,AZH,ELH)
        kline=.true.  
! Not really an error.  Just using step functions 
        if (ierr.eq.-103) then
!           write(lu,'("STINP251 - No matching el for last azimuth,",
!     >      " wraparound value used.")')            
            kline=.false.
            elh(nhz)=0.d0   !set to zero. We don't use this anyway. 
            ierr=0              
        endif
! Real errors 
        IF (IERR.NE.0) THEN
          nch=max(1,trimlen(cbufin0))
          write(*,*) "Error parsing horizon mask: "//cbufin(:nch)
          if(ierr .eq. -101) then
            write(*,*) "Incorrect form for station ID (2nd arg)" 
          else if (ierr.lt.-200) then
            write(lu,*) "STINP252 - Horizon mask azimuths are out "//
     >      "of order. Error in field ", -(ierr+200)                                
          else if (ierr.eq.-99)then
            write(lu,'(a,i5)')
     >     "STINP250 - Too many horizon mask az/el pairs. Max is ",
     >        max_hor          
          endif
          return
        ENDIF
        i=iwhere_in_String_list(chccod,nstatn,cid)
  
        if (i.eq.0 ) then !check position codes too
          write(lu,*) "STINP251 - Horizon mask pointer not found. "//
     >      "Checking position code."
          write(lu,'(a)') cbufin0(1:80)
! try checking against cpocod.
          i=iwhere_in_String_list(cpocod,nstatn,cid)
        endif
        IF (I.eq. 0) THEN  !matching entry not found
          write(lu,'("STINP25 - Pointer not found.  Horizon mask ")')
          goto 910
        ELSE  ! keep it    
        nhorz(i)=nhz 
        klineseg(i)=kline    
        do j=1,nhorz(i)         
          AZHORZ(J,I) = AZH(J)*deg2rad                     
          ELHORZ(J,I) = ELH(J)*deg2rad
        END DO
        END IF
      ELSE
        write(*,*) "Unknown $STATION line!"
      END IF
      return

C! come here on bad line.
900   continue
      write(lu,'("STINP- Problem with: ",a)') cbufin0(1:nch)
      write(lu,'("       Bad or missing ",a)') lerror_vec(ierr_ptr)
      write(lu,'("       reading token ",a)') ltoken(itoken)
      RETURN

910   continue
      write(lu,'("STINP- Problem with: ",a)') cbufin0(1:nch)
      write(*,*) "ERROR NUMBER: ",ierr
      return


950   continue
      write(lu,'("STINP - Not enough tokens: ",a)') cbufin0(1:nch)
      return

960   continue
      write(lu, *)
     >     "STINP - duplicate codes in station 'A' lines."//
     >     " Please fix before proceeding!"
      ierr=100
      stop
      END
