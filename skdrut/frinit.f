      subroutine frinit(nst,nco)

C  FRINIT initializes arrays in freqs.ftni before
C  reading from a schedule file.

C 960610 nrv New.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'

C Input
      integer nst,nco ! number of stations, codes to initialize

C Local
      integer i,j,k,m,idum
      integer ichmv_ch ! function

      do i=1,nco
        samprate(i)=0.0
      enddo
      do j=1,nco
        do i=1,nst
          nchan(i,j)=0
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
          DO J=1,max_pass
            DO K=1,max_chan
C             do l=1,2
C               do n=1,2
                  ITRAS(1,1,K,J,m,I)=-99
                  ITRAS(2,1,K,J,m,I)=-99
                  ITRAS(1,2,K,J,m,I)=-99
                  ITRAS(2,2,K,J,m,I)=-99
C               enddo
C             enddo
            END DO
          END DO
        END DO
      end do
      do i=1,nco
        do m=1,nst
          DO J=1,max_pass
            DO K=1,max_chan
C             do l=1,2
C               do n=1,2
                  ITRA2(1,1,K,J,m,I)=-99
                  ITRA2(2,1,K,J,m,I)=-99
                  ITRA2(1,2,K,J,m,I)=-99
                  ITRA2(2,2,K,J,m,I)=-99
C               enddo
C             enddo
            END DO
          END DO
        END DO
      end do
      do k=1,nco
        do j=1,nst
          do i=1,max_pass
            ihdpos(i,j,k)=9999
            ihddir(i,j,k)=0
            ihdpo2(i,j,k)=9999
            ihddi2(i,j,k)=0
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
