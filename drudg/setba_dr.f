      SUBROUTINE SETBA_DR
C
C A DRUDG version of SKEd's SETBA
C 960119 nrv New

C   SETBA looks through information in freqs.ftni and figures out
C   which frequency bands are in use.
C   It also counts the number of frequencies in each subgroup.
C
      INCLUDE 'skparm.ftni'
C
C   COMMON BLOCKS USED
      include 'sourc.ftni'
      INCLUDE 'freqs.ftni'
      include 'statn.ftni'
C
C  LOCAL VARIABLES
      integer*2 lb(max_band),ls1,ls2
      integer ierr,ic,i,iv,nb,nmatch,nx,
     .nfr,if1,ib,is,j,ifr,idum,ichmv_ch,ichmv,isub,iul,ii
      character*3 cs
      character*1 chband
      integer ichcm,ichcm_ch
      integer ixband,isband
      real*8 reffreq,frim,fovref,sum_del_f,sum_del_f2,
     .sum_del_fovf,del_f
      real*8 frsum,frsqsum,s
      real*4 speed ! function
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
        do i=1,nvcs(is,ic)
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
          if (ivix(iv,is,ic).ne.0) then ! this channel is used
            cs=cset(iv,is,ic)
            do iul=1,2
C             Only check pass 1 since all are consistent
C             Full addition for sign bit
              if (itras(iul,1,iv,1,is,ic).gt.-99) then 
                if (cs.eq.'1,2') then
C                  Two-thirds of the data on a switched track are used
                   trkn(isub,is,ic)=trkn(isub,is,ic)+0.6667
                else if (cs(1:1).eq.'1'.or.cs(1:1).eq.' ') then
C                  All the data on un-switched tracks are used
                   trkn(isub,is,ic)=trkn(isub,is,ic)+1
                endif
              endif
C             Add another 0.38 for magnitude bit
              if (itras(iul,2,iv,1,is,ic).gt.-99) then 
                trkn(isub,is,ic)=trkn(isub,is,ic)+0.38
              endif
            enddo
          endif
        enddo
      enddo
      enddo
      if (ierr.eq.1) ncodes=ncodes-1
C
      return
      end

