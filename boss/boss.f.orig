      program boss
cxx      implicit none
c
      include '../include/fscom.i'
c
      integer ifsnum
      parameter (ifsnum=1024)
      integer*4 ip(5)
      dimension lnames(13,ifsnum)
      integer*4 lproc1(10,MAX_PROC1),lproc2(10,MAX_PROC2)
      integer*4 itscb(13,15)
      integer idcbsk(2)
      integer ntscb,maxpr1,maxpr2,nnames,ierr,idum,fc_rte_prior
      data ntscb/15/
C                     Number of available entries in ITSCB
      data maxpr1/MAX_PROC1/, maxpr2/MAX_PROC2/
C                     Number of entries in each proc list
      data nnames/ifsnum/
C                     Maximum number of entries available in LNAMES
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

      call fs_set_abend_normal_end(1)
      call fc_exit( 0)
      end
