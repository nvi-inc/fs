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
      SUBROUTINE unsks(IBUF,ILEN,IERR,
     .LNAME1,LNAME2,LRAHMS,IRAH,IRAM,RAS,RARAD,
     .LDSIGN,LDCDMS,IDECD,IDECM,DECS,DECRAD,
     .EPOCH,VELOC,
     .            OINC,OECC,OPER,ONOD,
     .OANM,OAXS,OMOT,IEPY,OEDY,
     .            PARALX,PMRA,PMDEC,
     .NCOM,IVER,IDATE,LCOMP,
     .LPROT,PCOUNT)
      implicit none
C
C     UNSKS unpacks the record holding information on a source entry version
C           This routine may be called only the first 30 parameters
C           if information related to the catalog only is not wanted.
C           27 parameters will work for no parrallax and proper motion.
C**NOTE: THIS VERSION OF UNPVS IS USED BY SKED BECAUSE
C        IT CAN HANDLE SATELLITES.
C
      include '../skdrincl/skparm.ftni'
C
C  HISTORY:
C      NRV   ??????  CREATED
C      WEH   830519  SATELLITES ADDED
C      NRV   880315  DE-COMPC'D
C      nrv   930225  implicit none
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,pcount
C           - buffer having the record
C     ILEN - length of the record in IBUF, in words
C
C  OUTPUT:
      integer ierr,irah,iram,idecd,idecm
      integer*2 lprot,ldsign
C     IERR - error, 0=OK, -100-n=error reading nth field in the record
      integer*2 LNAME1(max_sorlen/2), LNAME2(max_sorlen/2)
C           - IAU and common names
C
C   Celestial Source Info:
C
      integer*2 LRAHMS(8)
C          - right ascension, in form hhmmss.ssssssss
C     IRAH,IRAM - right ascension hours&minutes, in binary
      real*8 RAS
C           - seconds field of right ascension
      real*8 RARAD
C           - right ascension, in radians
C     LDSIGN - sign of the declination, + or -
      integer*2 LDCDMS(7)
C           - declination, in form ddmmss.sssssss
C     IDECD,IDECM - declination degrees&minutes, in binary
      real*8 DECS
C           - declination seconds field
      real*8 DECRAD
C           - declination, in radians
C     EPOCH - epoch of RA and DEC
C     VELOC - velocity, for spectral line sources
C
C   Satellite orbit info:
C
      real*8 OINC
C           - orbit inclination
      real*8 OECC
C           - orbit eccentricity
      real*8 OPER
C           - orbit arguement of the perigee
      real*8 ONOD
C           - orbit right ascending node
      real*8 OANM
C           - orbit anomaly
      real*8 OAXS
C           - orbit semi-major axis
      real*8 OMOT
C           - orbit motion
C     IEPY - orbit epoch year
      real*8 OEDY
C           - orbit epoch day
C
C   More celestial source info:
C
C     PARALX - parallax
C     PMRA, PMDEC - proper motion in ra and dec
C
C   Catalog info:
C
C     NCOM - number of comments
C     IVER - version number of this information
      integer*2 IDATE(4)
C          - date/time this version was entered
C     LCOMP - computer ID where this version was entered
C     LPROT - Y for protected, N for OK to edit and delete
C
C  SUBROUTINES CALLED: LNFCH UTILITIES
C                      UNPWC - to get celestial specific info
C                      UNPWO - to get satellite orbit specific info
C
C  LOCAL:
C
C     real*8 DAS2B
      integer*2        LORBIT(4)
      CHARACTER*8      LORBIT_CHAR
      EQUIVALENCE      (LORBIT,LORBIT_CHAR) ! added by P. Ryan
      integer nargs,nch,ic1,ic2
C
C  INITIALIZED:
C
      DATA LORBIT_CHAR /'ORBIT   '/
C
C
C     0. First, find out how many parameters we were called with.
C
      NARGS = PCOUNT
C
C      NO ERRORS YET SET CODE TO ZERO
C
      IERR = 0
C
C
C     1. Start decoding this record with the first character.
C
      ICH = 1
C
C
C     IAU-name, 8 characters.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.max_sorlen)
     &  THEN  !"too long"
          IERR = -101
          RETURN
          END IF  !"too long"
      CALL IFILL(LNAME1,1,max_sorlen,oblank)
      IDUMY = ICHMV(LNAME1,1,IBUF,IC1,NCH)
C
C
C     Common-name, 8 characters.
C
      CALL GTFLD(IBUF,ICH,ILEN*2,IC1,IC2)
      NCH = IC2-IC1+1
      IF  (NCH.GT.max_sorlen)
     &  THEN  !"too many"
          IERR = -102
          RETURN
          END IF  !"too many"
      CALL IFILL(LNAME2,1,max_sorlen,oblank)
      IDUMY = ICHMV(LNAME2,1,IBUF,IC1,NCH)
C
C
C   Test for Satellite as opposed to celestial source and call
C        the appropriate decoding routine.
C
      JERR=0
      IF  (ICHCM(LNAME1,1,LORBIT,1,8).NE.0)
     &  THEN  !"celestial"
          CALL UNPWC(IBUF,ILEN,JERR,LRAHMS,IRAH,IRAM,RAS,RARAD,
     .               LDSIGN,LDCDMS,IDECD,IDECM,DECS,DECRAD,
     .               EPOCH,VELOC,NARGS,APARA,APMRA,APMDEC,ICH)
          IF  (JERR.NE.0)
     &      THEN  !"error celestial"
              IERR=JERR
              RETURN
            ELSE  !"good celestial"
              IF  (NARGS.GT.27)
     &          THEN  !"more celestial"
                  PARALX=APARA
                  PMRA=APMRA
                  PMDEC=APMDEC
                  END IF  !"more celestial"
              END IF  !"good celestial"
        ELSE  !"orbit"
          CALL UNPWO(IBUF,ILEN,JERR,OINC,OECC,OPER,ONOD,
     .               OANM,OAXS,OMOT,IEPY,OEDY,ICH)
          IF  (JERR.NE.0)
     &      THEN  !"error orbit"
              IERR=JERR
              RETURN
              END IF  !"error orbit"
          END IF  !"orbit"
C
C
C       CORRECT FOR DIFFERANT NUMBER OF SATELLITE AND CELESTIAL
C       SOURCE FIELDS, IF AND ONLY IF THERE IS ERROR
C
      IF  (JERR.NE.0 .AND. ICHCM(LNAME1,1,LORBIT,1,8).EQ.0) THEN
        IERR=JERR+2
      END IF
C
C
      RETURN
      END
