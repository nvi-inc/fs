      subroutine site(vfivpt,lbuf,isbuf)
      integer*2 lbuf(1)
C
      include '../include/dpi.i'
      include '../include/fscom.i'
C
C  WRITE SITE RECORD TO LOG
C
      icnext=1
      icnext=ichmv(lbuf,1,6Hsite  ,1,5)
C
C  ANTENNA NAME
C
      call fs_get_lnaant(lnaant)
      icnext=ichmv(lbuf,icnext,lnaant,1,8)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C  LONGITUDE
C
      call fs_get_wlong(wlong)
      icnext=icnext+jr2as(sngl(wlong*rad2deg),lbuf,icnext,-8,4,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C  LATITIUDE
C
      call fs_get_alat(alat)
      icnext=icnext+jr2as(sngl(alat*rad2deg),lbuf,icnext,-8,4,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C
C  DIAMETER
C
      icnext=icnext+jr2as(diaman,lbuf,icnext,-6,2,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C  AXIS TYPE
C 
      icnext=ichmv(lbuf,icnext,4Hxxxx,1,4)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C  POINTING MODEL NUMBER
C 
      icnext=icnext+ib2as(0,lbuf,icnext,3)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C  FIVPT VERSION NUMBER 
C 
      icnext=icnext+jr2as(vfivpt,lbuf,icnext,-5,2,isbuf)
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C  FS VERSION 
C 
      icnext=icnext+jr2as(fsver,lbuf,icnext,-5,2,isbuf) 
      icnext=ichmv(lbuf,icnext,2H  ,1,1)
C 
C CLEAN UP AND SEND 
C 
      nchars=icnext-1 
      if (1.ne.mod(icnext,2)) icnext=ichmv(lbuf,icnext,2H  ,1,1) 
      call logit2(lbuf,nchars) 
C 
      return
      end 
