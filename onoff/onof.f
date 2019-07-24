      subroutine onof(lbuf,isbuf) 
      integer*2 lbuf(1) 
C 
C WRITE ONOFF  LOG ENTRY
C 
      include '../include/fscom.i'
C 
C WE READ THE FOLLOWING FROM FSCOM: 
C 
C     NREPNF, INTPNF, LDV1NF, LDV2NF, CTOFNF, FRQ1NF, FRQ2NF, 
C     CAL1NF, CAL2NF
C 
C ONOFF LOG ENTRY IDENTIFIER
C 
      icnext=1
      icnext=ichmv(lbuf,icnext,6Honoff ,1,6)
C 
C REPITITONS
C 
      icnext=icnext+ib2as(nrepnf,lbuf,icnext,2) 
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C INTEGRERATION PERIOD
C
      icnext=icnext+ib2as(intpnf,lbuf,icnext,2)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C DEVICE MNEMONIC 1
C
      icnext=ichmv(lbuf,icnext,ldv1nf,1,2)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C DEVICE MNEMONIC 2
C
      icnext=ichmv(lbuf,icnext,ldv2nf,1,2)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C CUTOFF ELEVATION
C
      icnext=icnext+jr2as(ctofnf*180./pi,lbuf,icnext,-2,0,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C STEP SIZE
C
      icnext=icnext+jr2as(stepnf,lbuf,icnext,-2,0,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C CALIBRATION NOISE SOURCE 1
C
      icnext=icnext+jr2as(cal1nf,lbuf,icnext,-5,2,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C CALIBRATION NOISE SOURCE 2
C
      icnext=icnext+jr2as(cal2nf,lbuf,icnext,-5,2,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C FREQUENCY 1
C
      icnext=icnext+jr2as(bm1nf_fs*180./pi,lbuf,icnext,-4,2,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C FREQUENCY 2
C
      icnext=icnext+jr2as(bm2nf_fs*180./pi,lbuf,icnext,-4,2,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C DIAMETER OF DISH
C
      icnext=icnext+jr2as(fx1nf_fs,lbuf,icnext,-7,1,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C DIAMETER OF DISH
C
      icnext=icnext+jr2as(fx2nf_fs,lbuf,icnext,-7,1,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C CLEAN UP AND OUTPUT THE RESULT
C
      nchars=icnext-1
      if(1.ne.mod(icnext,2)) icnext=ichmv(lbuf,icnext,2H  ,1,1)
      call logit2(lbuf,nchars)

      return
      end
