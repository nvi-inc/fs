      subroutine frinit(nst,nco)

C  FRINIT initializes arrays in freqs.ftni before reading from a schedule file.

C 960610 nrv New.
C 960709 nrv Add barrel initialization.
C 970206 nrv Remove itra2,ihddi2,ihdpo2 and add max_headstack

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'

C Input
      integer nst,nco ! number of stations, codes to initialize

C Local
      integer i,j,k,m,idum,ih
      integer ichmv_ch ! function

      do i=1,nco
        samprate(i)=0.0
      enddo
      do j=1,nco
        do i=1,nst
          nchan(i,j)=0
          idum=ichmv_ch(lbarrel(1,i,j),1,'NONE')
        enddo
      enddo 
      do i=1,nco
        do j=1,nst
          do k=1,max_chan
            invcx(k,j,i)=0
          enddo
        enddo
      enddo
      do i=1,nco
        do m=1,nst
          DO J=1,max_subpass
            DO K=1,max_chan
              do ih=1,max_headstack
                ITRAS(1,1,ih,K,J,m,I)=-99
                ITRAS(2,1,ih,K,J,m,I)=-99
                ITRAS(1,2,ih,K,J,m,I)=-99
                ITRAS(2,2,ih,K,J,m,I)=-99
              END DO
            END DO
          END DO
        end do
      enddo
      do k=1,nco
        do j=1,nst
          do i=1,max_pass
            do ih=1,max_headstack
              ihdpos(ih,i,j,k)=9999
              ihddir(ih,i,j,k)=0
            enddo
          enddo
        enddo
      enddo
      do i=1,nco
        lcode(i)=0
      enddo
      do i=1,nco
        do j=1,nst
          do k=1,max_chan
            idum=ichmv_ch(lifinp(k,j,i),1,'  ')
          enddo
        enddo
      enddo
      return
      end
