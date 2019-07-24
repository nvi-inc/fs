c fscom_init.i
c
c See fscom.i for information on the structure
c

      REAL AMPTOL, AZHMWV(10), CPKMIN, 
     . DIFTOL, ELHMWV(30), FOROFF(2), FSVER, GDYTOL,
     . LVBOSC_FS, 
     . PHATOL, PHJMAX, PI, PSLOPE(2), PVOLT_FS(30), 
     . REVOFF(2), RSLOPE(2),
     . SOF2HI, SON2HI, SON2LO, TMPK_FS(30)

      INTEGER I20KCH, I70KCH, IACFTP, IACTTP, IBDB, ILENAL,
     . ILENTS, ILVTL_FS, IMONDS, INTAMP, INTPHA, IRDCL_FS,
     . ITAPOF(100), itapof4(12,3), ITR2VC(28,4), IWRCL_FS, 
     . IYRCTL_FS, LVSENS, MODSA, NHORWV,
     . NPRSET, NRX_FS, RPDT_FS, RPRO_FS,
     . b_init(INT_ALIGN),e_init

      LOGICAL KCHECK, KADAPT_FS, KIWSLW_FS, kpass4, 
     .  koff4

      integer*2 idevmat(32), idevdb(32), idevwand(32),
     . lalrm(3), ltsrs(5), loccup(4), lidstn

      common/fscom_init/b_init,
     . AMPTOL, AZHMWV, CPKMIN, DIFTOL, 
     . ELHMWV, FOROFF, FSVER, GDYTOL,
     . LVBOSC_FS,
     . PHATOL, PHJMAX, PI, PSLOPE, PVOLT_FS,
     . REVOFF, RSLOPE,
     . SOF2HI, SON2HI, SON2LO, TMPK_FS, 
     . I20KCH, I70KCH, IACFTP, IACTTP, IBDB, ILENAL,
     . ILENTS, ILVTL_FS, IMONDS, INTAMP, INTPHA, 
     . IRDCL_FS, ITAPOF, itapof4, ITR2VC, IWRCL_FS, 
     . IYRCTL_FS, LVSENS,
     . MODSA, NHORWV,
     . NPRSET, NRX_FS, RPDT_FS, RPRO_FS,
     . KCHECK, KADAPT_FS, KIWSLW_FS, kpass4, koff4,
     . idevmat, idevdb, idevwand,
     . lalrm, ltsrs, loccup, lidstn,
     . e_init
