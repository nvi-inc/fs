      subroutine frinit(nst,nco)

C  FRINIT initializes arrays in freqs.ftni before reading from a schedule file.

C 960610 nrv New.
C 960709 nrv Add barrel initialization.
C 970206 nrv Remove itra2,ihddi2,ihdpo2 and add max_headstack
C 991119 nrv Add initialization of trkn.
C 000126 nrv Add initialization of ntrkn.
C 010207 nrv Add initialization of freqpcal and freqpcal_base
C 011011 nrv Initialize LS2MODE.
C 021111 jfq Add initialization of LS2DATA
C 31Jul2003  JMG Made itras virtual.
C 26Aug2003  JMG made cbarrel, cinfip character strings.

      include '../skdrincl/skparm.ftni'
      include '../skdrincl/freqs.ftni'

C Input
      integer nst,nco ! number of stations, codes to initialize

C Local
      integer i,j,k,ih

      do i=1,nco
        samprate(i)=0.0
      enddo
      do j=1,nco
        do i=1,nst
          nchan(i,j)=0
          do k=1,max_band
            trkn(k,i,j)=0.0
            ntrkn(k,i,j)=0
          enddo
          cbarrel(i,j)="NONE"
          call ifill(ls2mode(1,i,j),1,16,oblank)
          call ifill(ls2data(1,i,j),1,8,oblank)
        enddo
      enddo 
      do i=1,nco
        do j=1,nst
          do k=1,max_chan
            invcx(k,j,i)=0
          enddo
        enddo
      enddo

      call init_itras()

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
            freqpcal(k,j,i) = -1.d0
            freqpcal_base(k,j,i) = -1.d0
            cifinp(k,j,i)="  "
          enddo
        enddo
      enddo
      return
      end
