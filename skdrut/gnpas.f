      SUBROUTINE gnpas(ierr)
C
C     GNPAS derives the number of sub-passes in each frequency code
C try to cound the total number of real passes in ihdpos
C
       INCLUDE 'skparm.ftni'
       INCLUDE 'statn.ftni'
       INCLUDE 'freqs.ftni'
C
C  Output
      integer ierr ! non-zero if inconsistent track counts per pass

C  LOCAL VARIABLES:
      integer ip,is,it,np,j,k,i,l,itrk(max_pass)
C
C     880310 NRV DE-COMPC'D
C     930225 nrv implicit none
C 951019 nrv New frequency code common variables, handles VLBA modes
C 951213 nrv More effective tracks for 2-bit sampling.
C
C
C     1. For each code, go through all possible passes and add
C     up the total number of tracks used. 
C     Use itras(u/l,s/m,max_pass,max_chan,code)
C
      ierr=0
      IF (NCODES.LE.0) RETURN
C
      DO  I=1,NCODES ! codes
        do is=1,nstatn
          np=0
          DO  J=1,max_pass ! all possible passes
            IT = 0
            do k=1,max_chan ! channels
              do l=1,2 ! upper/lower
                if (itras(l,1,k,j,is,i).ne.-99) it=it+1
C               For 2-bit sampling, we get an increase of 67%
                if (itras(l,2,k,j,is,i).ne.-99) it=it+0.6
              END DO ! upper/lower
            enddo ! channels
            if (it.gt.0) then
              np=np+1
              if (np.le.max_pass) itrk(np)=it
            endif
          END DO  ! all possible passes
          npassf(is,i)=np
          ntrakf(is,i)=itrk(1)
          j=1
          do while (j.lt.np.and.itrk(j).eq.itrk(j+1))
            j=j+1
          enddo
          if (itrk(1).eq.0.or.np.eq.0.or.j.lt.np.or.np.gt.max_pass) 
     .     ierr=1
        enddo
      END DO  ! codes
C
C  2. Now count up the number of passes, i.e. different head positions.
C     Look in ihddir and count the non-zero entries. Do this only for
C     frequency code 1.

      do is=1,nstatn
        ip=0
        do j=1,4*max_pass
          if (ihddir(j,is,1).eq.1) ip=ip+1
        enddo
        maxpas(is)=ip
        if (ip.eq.0) ierr=1
      enddo
C
      RETURN
      END
