      subroutine feet(ip)
C  tape positioner  c#870115:04:33#
C
C  WHO  WHEN    DESCRIPTION
C  GAG  910114  Changed LFEET to LFEET_FS and removed line comparing IOLDFT
C               with 10000.
C
C  INPUT VARIABLES
      dimension ip(1)
C        IP(1) - class # of input parameter buffer
C
C  OUTPUT VARIABLES
C        IP(1) - class returned
C        IP(2) - # of records
C        IP(3) - error return
C        IP(4) - who we are
C
C  COMMON BLOCK USED
      include '../include/fscom.i'
C
C  LOCAL VARIABLES
      integer*2 ibuf(10)
      dimension ireg(2)
      integer get_buf
      dimension nft(7)
      dimension nsav(3)
      logical kfirst
C
      equivalence (reg,ireg(1))
C
      data ilen/20/
      data nft/0,0,0,2,10,40,65/
      data nsav/0,1,2/
C
      isp=8
      n=0
      ip(2) = 0
      call fs_get_icheck(icheck(18),18)
      ichold = icheck(18)
      iclcm = ip(1)
      ip(1) = 0
      if (iclcm.eq.0) then
C         error if there is no class #
        ierr = -1
        goto 990
      endif
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = min0(ireg(2),ilen)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if(ieq.eq.0.or.ieq.eq.nchar) goto 990 
      inewft = ias2b(ibuf,ieq+1,nchar-ieq)
C         decode footage parameter
      if (inewft.lt.0) then
        ierr = -2 
        ip(1) = 0 
        goto 990
      endif
C         First check whether tape is stopped and read footage
      ibuf(1) = -3
      call char2hol('tp',ibuf(2),1,2)
      iclass = 0
      call put_buf(iclass,ibuf,-4,'fs','  ')
      call run_matcn(iclass,1)
      call rmpar(ip)
      iclass=ip(1)
      if(ip(3).lt.0) goto 999
      ireg(2) = get_buf(iclass,ibuf,-ilen,idum,idum)
      call ma2tp(ibuf,ilow,lfeet_fs,ifastp,icaptp,istptp,itactp,irdytp)
      call char2hol('tp',ibuf(2),1,2)
      call fs_set_icaptp(icaptp)
      call fs_set_istptp(istptp)
      call fs_set_itactp(itactp)
      call fs_set_irdytp(irdytp)
      call fs_set_lfeet_fs(lfeet_fs)
      call fs_get_icaptp(icaptp)
      if (icaptp.eq.0) goto 20
        ierr = -301
        ip(1) = 0
        goto 990
      call fs_get_lfeet_fs(lfeet_fs)
20    ioldft = ias2b(lfeet_fs,1,5)
C    Now disable general record, set low-tape sensor,put in BYPass mode
      icheck(18) = 0
      call fs_set_icheck(icheck(18),18)
      iclass = 0
      ibuf(1) = 0 
      ienatp=0
      call fs_set_ienatp(ienatp)
      call en2ma(ibuf(3),ienatp,itrken,ldummy)  
      call put_buf(iclass,ibuf,-13,'fs','  ')
      ilowtp = 1
      call tp2ma(ibuf(3),ilowtp,0)
      call put_buf(iclass,ibuf,-13,'fs','  ')
      ibypas = 1
      call fs_get_itraka(itraka)
      call fs_get_itrakb(itrakb)
      call rp2ma(ibuf(3),ibypas,ieqtap,ibwtap,itraka,itrakb)
      call put_buf(iclass,ibuf,-13,'fs','  ')
      call run_matcn(iclass,3) 
      call rmpar(ip)
      if (ip(3).lt.0) goto 999
      call clrcl(ip(1)) 
C  Now calculate how far we have to go and in which direction.
      if(ioldft.ge.0) goto 25
        ierr = -3
        goto 990
C25    IF(IOLDFT.GT.10000) IOLDFT = IOLDFT - 20000
25    idelft = iabs(ioldft-inewft)
      idir = 0
      if(inewft.gt.ioldft) idir = 1
C
C   1. DECIDE WHAT SPEED IS NEEDED AND START TAPE
C
      kfirst=.true.
100   continue
      isp=isp-1
      if(isp.lt.4) goto 500
      if(idelft.lt.6) goto 500
      if(idelft.lt.nft(isp)) goto 100
      call setsp(idir,isp,ip)
      if (ip(3).lt.0) goto 500
C
110   continue
      if(kfirst) then
        call susp(2,1)
        kfirst=.false.
      endif
      idelft = ickft(ibrk,inewft,icurft,idir,ip)
      if (ip(3).lt.0) goto 500
      if(ibrk.eq.1) goto 500
C
C  GIVE THREE TRIES, IF IT HASN'T CHANGED, WE ARE STUCK
C
      n=n+1
      if(n.gt.3) n=1
      nsav(n)=idelft
      if(nsav(1).ne.nsav(2)) go to 120
      if(nsav(2).ne.nsav(3)) go to 120
         ierr=-4
         ip(1)=0
         goto 990
C
120   continue
      if(idelft.gt.nft(isp)) goto 110
      goto 100
C
C   5.  WE'RE THERE.
C
500   continue
      ierr = ip(3)
      isp = 0
      call setsp(idir,isp,ip)
      call susp(2,1)
      idelft = ickft(ibrk,inewft,icurft,idir,ip)
C     ID = IPRTY(JPR)
      if (ip(3).lt.0) goto 999
C
C  6.  Set up response.
C
600   nch = ichmv_ch(ibuf,1,'feet/')
      nch = nch + ib2as(icurft,ibuf,nch,o'100005')-1
      iclass = 0
      call put_buf(iclass,ibuf,-nch,'fs','  ')
C
      ip(1) = iclass
      ip(2) = 1
990   ip(3) = ierr
      call char2hol('q?',ip(4),1,2)
999   icheck(18) = ichold
      call fs_set_icheck(icheck(18),18)
      return
      end
