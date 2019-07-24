      program boss
cxx      implicit none
      integer ifsnum
      parameter (ifsnum=256)
      integer*4 ip(5)
      dimension lnames(12,ifsnum)
      integer*2 lproc1(10,80),lproc2(10,80)
      integer itscb(13,15)
      integer idcbsk(2)
      integer ntscb,maxpr1,maxpr2,nnames,ierr,idum,fc_rte_prior
      data ntscb/15/
C                     Number of available entries in ITSCB
      data maxpr1/80/, maxpr2/80/
C                     Number of entries in each proc list
      data nnames/ifsnum/
C                     Maximum number of entries available in LNAMES
C
      include '../include/fscom.i'
C
      call setup_fscom
      call read_fscom
      call wait_prog('boss',ip)
      idum=fc_rte_prior(FS_PRIOR)
C
      call binit(ip,lnames,nnames,itscb,ntscb,idcbsk,ierr)
      if (ierr.ne.0) goto 900
      call bwork(ip,lnames,nnames,lproc1,maxpr1,lproc2,maxpr2,
     .           itscb,ntscb,idcbsk)
900   continue

C  HARI-KIRI

      call fc_exit( -1)
      end
