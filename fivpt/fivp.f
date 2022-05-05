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
      subroutine fivp(lbuf,isbuf) 
      integer*2 lbuf(1) 
C 
C WRITE FIVEPT LOG ENTRY
C 
       include '../include/fscom.i'
       include '../include/dpi.i'
C 
C WE READ THE FOLLOWING FROM FSCOM: 
C 
C     LAXFP, LDEVFP, CALFP, NREPFP, NPTSFP, FREQFP, INTPFP, STEPFP, 
C     ANGLFP, DIAMAN
C 
C FIVEPT LOG ENTRY IDENTIFIER
C
      icnext=1
      icnext=ichmv_ch(lbuf,icnext,'fivept ')
C
C AXIS OF SCAN
C
      icnext=ichmv(lbuf,icnext,laxfp,1,4)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C REPITITONS
C
      icnext=icnext+ib2as(nrepfp,lbuf,icnext,3)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C NUMBER OF POINTS PER AXIS
C
      icnext=icnext+ib2as(nptsfp,lbuf,icnext,3)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C STEP SIZE
C
      icnext=icnext+jr2as(stepfp,lbuf,icnext,-4,2,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C INTEGRERATION PERIOD
C
      icnext=icnext+ib2as(intpfp,lbuf,icnext,2)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C DEVICE MNEMONIC
C
      icnext=ichmv(lbuf,icnext,ldevfp,1,4)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C CALIBRATION NOISE SOURCE
C
      icnext=icnext+jr2as(calfp,lbuf,icnext,-5,1,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C BEAMWIDTH
C
      icnext=icnext+jr2as(bmfp_fs*180./RPI,lbuf,icnext,-7,4,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C FLUX
C
      icnext=icnext+jr2as(fxfp_fs,lbuf,icnext,-9,1,isbuf)
      icnext=ichmv_ch(lbuf,icnext,' ')
C
C CLEAN UP AND OUTPUT THE RESULT
C
      nchars=icnext-1
      if (1.ne.mod(icnext,2)) icnext=ichmv_ch(lbuf,icnext,' ')
      call logit2(lbuf,nchars)

      return
      end
