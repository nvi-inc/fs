c fscom_init.i
c
c See fscom.i for information on the structure
c

      REAL AMPTOL, AZHMWV(10), CPKMIN, 
     . DIFTOL, ELHMWV(30), FOROFF(2), GDYTOL,
     . LVBOSC_FS, rxvfac(MAX_RXCODES), 
     . PHATOL, PHJMAX, PI, PSLOPE(2), PVOLT_FS(30), 
     . REVOFF(2), RSLOPE(2),
     . SOF2HI, SON2HI, SON2LO, TMPK_FS(30), rate0ti_fs

      integer*4 freqif3_fs, span0ti_fs

      INTEGER I20KCH, I70KCH, IACFTP, IACTTP, IBDB, ILENAL,
     . ILENTS, ILVTL_FS, IMONDS, INTAMP, INTPHA, IRDCL_FS,
     . ITR2VC(28,4), IWRCL_FS, 
     . IYRCTL_FS, LVSENS, MODSA, NHORWV, rxncodes,
     . NPRSET, NRX_FS, RPDT_FS, RPRO_FS, RDHD_FS,
     . iswavif3_fs,
     . b_init(INT_ALIGN),e_init

      LOGICAL KCHECK, KADAPT_FS, KIWSLW_FS

      integer*2 idevmat(32), idevdb(32), idevwand(32),
     . rxlcode(3,MAX_RXCODES),
     . lalrm(3), ltsrs(5), loccup(4), lidstn, model0ti_fs,
     . sVerMajor_fs, sVerMinor_fs, sVerPatch_fs,
     . iaxis(2),
     . e_fill_init

      common/fscom_init/b_init,
     . AMPTOL, AZHMWV, CPKMIN, DIFTOL, 
     . ELHMWV, FOROFF, GDYTOL,
     . LVBOSC_FS, rxvfac,
     . PHATOL, PHJMAX, PI, PSLOPE, PVOLT_FS,
     . REVOFF, RSLOPE,
     . SOF2HI, SON2HI, SON2LO, TMPK_FS, rate0ti_fs,
     . freqif3_fs, span0ti_fs,
     . I20KCH, I70KCH, IACFTP, IACTTP, IBDB, ILENAL,
     . ILENTS, ILVTL_FS, IMONDS, INTAMP, INTPHA, 
     . IRDCL_FS, ITR2VC, IWRCL_FS, 
     . IYRCTL_FS, LVSENS,
     . MODSA, NHORWV, rxncodes,
     . NPRSET, NRX_FS, RPDT_FS, RPRO_FS, RDHD_FS,
     . iswavif3_fs,
     . KCHECK, KADAPT_FS, KIWSLW_FS,
     . idevmat, idevdb, idevwand,
     . rxlcode,
     . lalrm, ltsrs, loccup, lidstn, model0ti_fs,
     . sVerMajor_fs, sVerMinor_fs, sVerPatch_fs,
     . iaxis,
     . e_fill_init,
     . e_init
