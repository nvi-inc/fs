      SUBROUTINE flinp(IBUF,ILEN,lu,ierr)
C
C     FLINP reads and decodes a source flux line, and puts
C           the information into common
C
       INCLUDE 'skparm.ftni'
C
C  INPUT:
      integer*2 IBUF(*)
      integer ilen,lu
C      - buffer holding source entry
C     ILEN - length of IBUF in words
C
C  OUTPUT:
      integer ierr
C     IERR - error number
C
C  Called by: FLGET
C
C  Common
       INCLUDE 'sourc.ftni'
C
C  LOCAL:
      integer*2 lb ! band for unpacking
      integer*2 lname(4) !temp source name for unpacking
      real*4 fl(max_flux)
C      - temporary baseline/flux holders for unpacking
      integer j,j1,nfl,i,is,ib
      integer igtba,idum
      character*1 cfl
C
C  PROGRAMMER: NRV
C   NRV 891113 Created, based on SOINP
C   NRV 910924 Change UNPFL call, store in new flux variables
C   NRV 911106 Fixed calculation of number of flux steps
C   nrv 950626 Make IGTBA a function
C
C
C     1. Call UNPFL to unpack the buffer we were passed.
C     Put all of the fields into temporary variables.
C
      CALL UNPFL(IBUF,ILEN,IERR,LNAME,LB,cfl,NFL,FL)
C
      IF  (IERR.NE.0) THEN  !
        write(lu,'("FLINP01 - Error in field ",i4," in following:")')
     .  -(IERR+100)
        write(lu,'(40a2)') (ibuf(i),i=1,ilen)
        RETURN
      END IF 
      if (cfl.eq.'M'.and.nfl.ne.6) then
        write(lu,'("FLINP02 - Need 6 parameters for model component:")')
        write(lu,'(40a2)') (ibuf(i),i=1,ilen)
        return
      endif
C
C     2. Find out which source and which band.
C        Store baselines and flux into common arrays.
C
      call igtso(lname,is) 
      idum = igtba(lb,ib) 
      if (ib.gt.0.and.is.gt.0) then !band and source are selected
        cfltype(ib,is) = cfl
        if (cfl.eq.'M') then !model
          nflux(ib,is)=nflux(ib,is)+1
          if (nflux(ib,is).gt.MAX_FLUX/6) then
            write(lu,'("FLINP04 - Too many model components, max is ",
     .      i4)') MAX_FLUX/6
            write(lu,'(40a2)') (ibuf(i),i=1,ilen)
            return
          endif
          do j=1,6
            j1 = 1 + (nflux(ib,is)-1)*6
            flux(j+j1-1,ib,is) = fl(j)
          enddo
        else !baseline pairs
          nflux(ib,is) = ((nfl+1)/2)-1
          if (nflux(ib,is).gt.MAX_FLUX) then
            write(lu,'("FLINP04 - Too many baseline/flux entries, ",
     .      "max is ",i4)') MAX_FLUX
            write(lu,'(40a2)') (ibuf(i),i=1,ilen)
            return
          endif
          DO j=1,nfl
            flux(j,ib,is) = fl(j)
          END DO
        endif
      endif
C
      RETURN
      END
