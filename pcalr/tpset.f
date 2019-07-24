      subroutine tpset(ihold,ibuf,ierr,ksplit,ksa)
C
      include '../include/fscom.i'
C
      integer*2 ibuf(1)
C
      logical ksplit,ksa
C
      ierr = 0
      ibuf(1) = 0
      call char2hol('tp',ibuf(2),1,2)
      call fs_get_iratfm(iratfm)
      ieql = iratfm-2
      if (ieql.lt.0) ieql = 6
      ibcd = iratfm-1
      if (ibcd.lt.0) ibcd = 7
      call fs_get_itraka(itraka)
      call fs_get_itrakb(itrakb)
      if (ksa) then
        call rp2ma(ibuf(3),ibyppc,ieql,ibcd,itrakb,itrakb)
      else
        call rp2ma(ibuf(3),ibyppc,ieql,ibcd,itraka,itrakb)
      endif
C                   Code up the buffer for MATCN.
      if (ibugpc.gt.0) write(lu,9100) ibyppc,itraka,itrakb
9100  format(/" ibyppc="i2" itraka="i3" itrakb="i3)
C                   Get bandwidth from IRATFM in common
      iclass = 0
      call put_buf(iclass,ibuf,-13,2hfs,0)
      call run_matcn(iclass,1)
      call rmpar(ibuf)
      if (ibuf(3).ge.0) goto 290
      ierr = ibuf(3)
      goto 990
C
290   if (ibuf(1).ne.0) call clrcl(ibuf(1))
C                   Clear out the class response -- assume OK
      ibuf(3)=0
      icheck(18) = ihold
      call fs_set_icheck(icheck(18),18)
990   continue

      return
      end
