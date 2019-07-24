c fscom_quikr.i
c
c See fscom.i for information on the structure
c
c
      REAL ARR1FX_FS(6), BEAMSZ_FS(2), BM1NF_FS,
     . BM2NF_FS, BMFP_FS, CAL1NF, CAL2NF,
     . CALFP, CALTMP(2), COR1FX_FS, COR2FX_FS, CTOFNF,
     . FASTFW(2), FASTRV(2), FIWO_FS(2),
     . FLX1FX_FS, FLX2FX_FS, FOWO_FS(2), FREQLO(2,2),
     . FREQVC(15), FX1NF_FS, FX2NF_FS, FXFP_FS,
     . LMTN_FS(2), LMTP_FS(2), PETHR, POSNHD(2),
     . RBDread_FS, 
     . RBDwrite_FS, RNGLC_FS, RSread_FS, RSwrite_FS,
     . RV13_FS, RV15flip_FS, RV15for_FS, RV15rev_FS,
     . RV15scale_FS, RVrevW_FS, RVw0_FS, RVw8_FS,
     . Rsdread_FS, Rsdwrite_FS, SIWO_FS(2), SOWO_FS(2), STEPFP,
     . STEPLC_FS, STEPNF, TP1IFD, TP2IFD,
     . TPERER, TPSOR(30), TPSPC(30), TPZERO(30), VADCRX,
     . VADCST, VLTPK_FS, VMINPK_FS,
     . SLOWFW(2),SLOWRV(2)

      INTEGER IADCRX, IADCST, IAT1IF, IAT2IF, IATLVC(15),
     . IATUVC(15), IBUGPC, IBWTAP, IBWVC(15), IBXHRX,
     . IBXHST, IBYPAS, IBR4TAP, IBYPPC, ICHAND,
     . ICHPER, ICLWO_FS, IDCHRX, IDCHST, IDECPA_FS,
     . IEQTAP, IEQ4TAP, IERRDC_FS, IFAMRX(3),
     . IFAMST(3), IFASTP, IFP2VC(14), IFTGO, IHDLC_FS,
     . IHDPK_FS, IHDWO_FS, ILOHST, ILOWTP, IMDL1FX_FS,
     . IMDL2FX_FS, IMODDC, IMODPE,
     . INPFM, INSPER, INTPFP, INTPNF, IOL1IF_FS,
     . IOL2IF_FS, IPAUPC, IPCFLG,
     . IREMIF, IREMVC(15), IREPPC, IRSTTP, ISETHR,
     . ISYNFM, ITERPK_FS, ITPIVC(15), ITRAKAUS_FS,
     . ITRAKBUS_FS, ITRAKBUS_FS, ITRKEN(28),
     . ITRKENUS_FS(28), ITRKPA(2), ITRKPAR4(36), 
     . ITRKPC(28), ITRPER, LOSTRX, LOSTST, LSWCAL,
     . LTRKEN(4),
     . NBLKPC, NCYCPC, NPTSFP, NREPFP, NREPNF, 
     . NSAMPLC_FS, NSAMPPK_FS, RDHD_FS, WRHD_FS,
     . b_quikr(INT_ALIGN),e_quikr

      LOGICAL KVrevW_FS, KV15rev_FS, KV15for_FS, KV15scale_FS,
     . KV13_FS, KV15flip_FS, KVw0_FS, KVw8_FS, KSREAD_FS,
     . KSread_FS, KSwrite_FS, Ksdread_FS, Ksdwrite_FS,
     . KBDwrite_FS, KBDread_FS, KHECHO_FS, KPEAKV_FS, KPOSHD_FS(2),
     . KRDWO_FS, KWRWO_FS, KDOAUX_FS, KRPTP_FS, KMVTP_FS,
     . KENTP_FS

      INTEGER*2 LAUXFM(6), LAUXFM4(4), LAXFP(2), LDEVFP, LDV1NF, 
     . LDV2NF, LTPCHK(2), LTPNUM(4), LOPRID(6), QFILL(1)

      common/fscom_quikr/b_quikr,
     . ARR1FX_FS, BEAMSZ_FS, BM1NF_FS,
     . BM2NF_FS, BMFP_FS, CAL1NF, CAL2NF,
     . CALFP, CALTMP, COR1FX_FS, COR2FX_FS, CTOFNF,
     . FASTFW, FASTRV, FIWO_FS,
     . FLX1FX_FS, FLX2FX_FS, FOWO_FS, FREQLO, FREQVC,
     . FX1NF_FS, FX2NF_FS, FXFP_FS,
     . LMTN_FS, LMTP_FS, PETHR, POSNHD,
     . RBDread_FS,
     . RBDwrite_FS, RNGLC_FS, Rsdread_FS, Rsdwrite_FS,
     . RSread_FS, RSwrite_FS, RV13_FS, RV15flip_FS, 
     . RV15for_FS, RV15rev_FS, RV15scale_FS, RVrevW_FS,
     . RVw0_FS, RVw8_FS, SIWO_FS, SOWO_FS, STEPFP,
     . STEPLC_FS, STEPNF, TP1IFD, TP2IFD,
     . TPERER, TPSOR, TPSPC, TPZERO, VADCRX,
     . VADCST, VLTPK_FS, VMINPK_FS,
     . SLOWFW,SLOWRV,
     . IADCRX, IADCST, IAT1IF, IAT2IF, IATLVC,
     . IATUVC, IBUGPC, IBWTAP, IBWVC, IBXHRX,
     . IBXHST, IBYPAS, IBR4TAP, IBYPPC, ICHAND, 
     . ICHPER, ICLWO_FS, IDCHRX, IDCHST,
     . IDECPA_FS, IEQTAP, IEQ4TAP, IERRDC_FS, IFAMRX,
     . IFAMST, IFASTP, IFP2VC, IFTGO, IHDLC_FS,
     . IHDPK_FS, IHDWO_FS, ILOHST, ILOWTP, IMDL1FX_FS,
     . IMDL2FX_FS, IMODDC, IMODPE,
     . INPFM, INSPER, INTPFP, INTPNF, IOL1IF_FS,
     . IOL2IF_FS, IPAUPC, IPCFLG,
     . IREMIF, IREMVC, IREPPC, IRSTTP, ISETHR,
     . ISYNFM, ITERPK_FS, ITPIVC,
     . ITRAKAUS_FS, ITRAKBUS_FS, ITRKEN,
     . ITRKENUS_FS, ITRKPA, ITRKPAR4, ITRKPC, ITRPER,
     . LOSTRX, LOSTST, LSWCAL,
     . LTRKEN, 
     . NBLKPC, NCYCPC, NPTSFP, NREPFP,
     . NREPNF, NSAMPLC_FS, NSAMPPK_FS, RDHD_FS, WRHD_FS,
     . KVrevW_FS, KV15rev_FS, KV15for_FS, KV15scale_FS,
     . KV13_FS, KV15flip_FS, KVw0_FS, KVw8_FS,
     . KSread_FS, KSwrite_FS, Ksdread_FS, Ksdwrite_FS,
     . KBDwrite_FS, KBDread_FS, KHECHO_FS, KPEAKV_FS, KPOSHD_FS,
     . KRDWO_FS, KWRWO_FS, KDOAUX_FS, KRPTP_FS, KMVTP_FS,
     . LAUXFM, LAUXFM4, LAXFP, LDEVFP, LDV1NF, LDV2NF,
     . LTPCHK, LTPNUM, LOPRID,
     . qfill, e_quikr
