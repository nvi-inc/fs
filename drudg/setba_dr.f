      SUBROUTINE SETBA_dr
C
      include '../skdrincl/skparm.ftni'
C
C   COMMON BLOCKS USED
      include '../skdrincl/sourc.ftni'
      include '../skdrincl/freqs.ftni'
      include '../skdrincl/statn.ftni'

      integer itras
C
C  LOCAL VARIABLES
      integer*2 lb(max_band),ls1,ls2
      integer ierr,ip,ic,i,iv,nb,nmatch,nx,
     .nfr,if1,ib,is,j,ifr,idum,ichmv_ch,ichmv,isub,iul,ii
      character*3 cs
      character*1 chband
      integer ichcm,ichcm_ch
      integer ixband,isband
      double precision reffreq,frim,fovref,sum_del_f,sum_del_f2,
     .sum_del_fovf,del_f
      double precision frsum,frsqsum,s
      real speed ! function
C
C  1. Count number of frequencies and the number of tracks being
C     recorded at each station on each frequency.
C
      ierr=0
      idum= ichmv_ch(ls1,1,'  ')
      idum= ichmv_ch(ls2,1,'  ')
      do ic=1,ncodes
      do is=1,nstatn
        nfreq(1,is,ic)=0
        nfreq(2,is,ic)=0
        do i=1,nchan(is,ic) ! number of channels
          iv=invcx(i,is,ic)
          if (ichcm_ch(ls1,1,'  ').eq.0) then
            ls1=lsubvc(iv,is,ic)
          else
            if (ls1.ne.lsubvc(iv,is,ic).and.ichcm_ch(ls2,1,'  ').eq.0)
     .      ls2=lsubvc(iv,is,ic)
          endif
          if (lsubvc(iv,is,ic).eq.ls1) isub=1
          if (lsubvc(iv,is,ic).eq.ls2) isub=2
          nfreq(isub,is,ic)=nfreq(isub,is,ic)+1 !count number of frequencies
          if (iv.ne.0) then ! this channel is used
            cs=cset(iv,is,ic)
            do iul=1,2 ! upper/lower
              do ip=1,npassf(is,ic) ! all subpasses
C               Full addition for sign bit
                if (itras(iul,1,1,iv,ip,is,ic).ne.-99) then 
                  if (cs.eq.'   '.or.cs.eq.'1,2') then
C                  All the data on un-switched tracks are used
                   trkn(isub,is,ic)=trkn(isub,is,ic)+1
                  else if (cs(1:1).eq.'1') then
C                  Two-thirds of the data on a switched track are used
                   trkn(isub,is,ic)=trkn(isub,is,ic)+0.6667
                  endif
                endif
C             Add another 0.38 for magnitude bit
                if (itras(iul,2,1,iv,ip,is,ic).ne.-99) then 
                  trkn(isub,is,ic)=trkn(isub,is,ic)+0.38
                endif
              enddo ! all subpasses
            enddo ! upper/lower
          endif
        enddo ! number of channels
      enddo
      enddo
      if (ierr.eq.1) ncodes=ncodes-1
C
      do ic=1,ncodes
        if (samprate(ic).eq.0) samprate(ic)=2.0*vcband(1,1,ic)
      enddo

      RETURN
      END

