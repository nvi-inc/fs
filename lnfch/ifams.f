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
        function ifams(iout,istrt,lsgn,ih,im,sec,iform) 

C  THIS FUNCTION FORMAT ANGLES(EITHER DEGREES OR HOURS)
C  MINUTES AND SECONDS INTO AN ASCII FORMAT OF THE FOLLOWING FORM
C 
C  shhammbss.sc
C 
C       WHERE THE CHARACTERS HAVE THE FOLLOWING MEANING AND AFFECT
C 
C       s       - If not a zero(=0) this will be inserted into stream else
C                 field will begin later
C 
C       hh      - ASCII conversion of IH unless all the following conditions
C                 are meet: 
C 
C                       1.  s was not inserted
C                       2.  IH =0 
C 
C       a       - first field designator character in string IFORM
C 
C       mm      - ASCII conversion of IM the following combination of 
C                 conditions have been meet:
C 
C                       1.  IM = 0 and no previous characters have been 
C                           generated in this call
C 
C               or      2.  the second and third forms character are both 
C                           identically equal to zero 
C 
C       b       - the second character in the string IFORM
C 
C       ss.s    - the FORTRAN equivalent conversion of SEC via and F4.1 
C                 format unless the character c is = 0 or SEC =0
C 
C       c       - the third character in IFORM
C 
C 
C               THE FOLLOWING OUTPUTS ARE POSSIBLE
C 
C                       (NULL) IF (LSGN=0&IH=0&IM=0&JCHAR(IFORM,3)=0) 
C       hha             IF(LSGN=0&ICHCM(IFORM,1,0,1,2)=0) 
C       hhammb          IF(LSGN=0&JCHAR(IFORM,3)=0) 
C       hhammbss.sc     IF(LSGN=0)
C       shha            IF(ICHCM(IFORM,2,0,1,2)=0)
C       shhammb         IF(JCHAR(IFORM,3)=0orISEC=0)
C       shhammbss.sc
C       mmb             IF(LSGN=0&IH=0&JCHAR(IFORM,3)=0)
C       mmbss.sc        IF(LSGN=0&IH=0) 
C       ss.sc           IF(LSGN=0&IH=0&IM=0)
C 
      dimension iout(1) 
      ifams=istrt 
      if (jchar(lsgn,1).ne.0) ifams=ichmv(iout,ifams,lsgn,1,1)
      if (ih.eq.0.and.ifams.eq.istrt) goto 1000
      ifams=ib2as(ih,iout,ifams,o'41002')+ifams 
      ifams=ichmv(iout,ifams,iform,1,1) 
1000  continue
      if ((im.eq.0.and.ifams.eq.istrt)
     .               .or.ichcm(iform,2,0,1,2).eq.0)
     .         goto 2000 
      ifams=ib2as(im,iout,ifams,o'41002')+ifams 
      ifams=ichmv(iout,ifams,iform,2,1) 
2000  continue
      if (jchar(iform,3).eq.0.or.sec.eq.0.) goto 3000
      ifams=ir2as(sec,iout,ifams,4,1)+ifams 
      ifams=ichmv(iout,ifams,iform,3,1) 
3000  continue

      return
      end 
