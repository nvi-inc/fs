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
c fscom_init.i
c
c See fscom.i for information on the structure
c

      REAL AMPTOL, AZHMWV(10), CPKMIN, 
     . DIFTOL, ELHMWV(30), FOROFF(2,2), GDYTOL,
     . LVBOSC_FS(2), rxvfac(MAX_RXCODES), 
     . PHATOL, PHJMAX, PI, PSLOPE(2,2), PVOLT_FS(MAXNRX_FS), 
     . REVOFF(2,2), RSLOPE(2,2),
     . SOF2HI, SON2HI, SON2LO, TMPK_FS(MAXNRX_FS), rate0ti_fs

      integer*4 span0ti_fs

      INTEGER I20KCH, I70KCH, IACTTP(2), IBDB, ILENAL,
     . ILENTS, ILVTL_FS(2), IMONDS, INTAMP, INTPHA,
     . ITR2VC(28,4),  LVSENS, MODSA, NHORWV, rxncodes,
     . NPRSET, NRX_FS, RPDT_FS(2), RPRO_FS(2),
     . iswavif3_fs,decoder4,pcalcntrl,
     . b_init(INT_ALIGN),e_init

      LOGICAL KCHECK, KADAPT_FS(2), KIWSLW_FS(2)

      integer*2 idevmat(32), idevdb(32), idevwand(32),
     . rxlcode(3,MAX_RXCODES),
     . lalrm(3), ltsrs(5), model0ti_fs,
     . sVerMajor_fs, sVerMinor_fs, sVerPatch_fs,
     . iaxis(2),mk4dec_fs,
     . e_fill_init(1)

      common/fscom_init/b_init,
     . AMPTOL, AZHMWV, CPKMIN, DIFTOL, 
     . ELHMWV, FOROFF, GDYTOL,
     . LVBOSC_FS, rxvfac,
     . PHATOL, PHJMAX, PI, PSLOPE, PVOLT_FS,
     . REVOFF, RSLOPE,
     . SOF2HI, SON2HI, SON2LO, TMPK_FS, rate0ti_fs,
     .  span0ti_fs,
     . I20KCH, I70KCH, IACTTP, IBDB, ILENAL,
     . ILENTS, ILVTL_FS, IMONDS, INTAMP, INTPHA, 
     . ITR2VC,
     . LVSENS,
     . MODSA, NHORWV, rxncodes,
     . NPRSET, NRX_FS, RPDT_FS, RPRO_FS,
     . iswavif3_fs,decoder4,pcalcntrl,
     . KCHECK, KADAPT_FS, KIWSLW_FS,
     . idevmat, idevdb, idevwand,
     . rxlcode,
     . lalrm, ltsrs, model0ti_fs,
     . sVerMajor_fs, sVerMinor_fs, sVerPatch_fs,
     . iaxis,mk4dec_fs,
     . e_fill_init,
     . e_init
