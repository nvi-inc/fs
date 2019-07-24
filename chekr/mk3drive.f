      subroutine mk3drive(lwho,lmodna,nverr,niferr,nfmerr,ntperr,
     .                    icherr,ichecks,kall)
C
      include '../include/fscom.i'
C
C  INPUT PARAMETERS
C
      integer*2 lmodna(1), lwho
      integer nverr,niferr,nfmerr,ntperr,icherr(1)
      integer ichecks(1)
      logical kall !true to check all every 20 sec
C
C LOCAL VARIABLES
C
      dimension ip(5)             ! - for RMPAR
      integer*2 ibuf1(40)
      integer icodes(4), maxerr
      data  icodes /-1,-2,-3,-4/
      data  maxerr /15/

      if (.not.kall) return
      call fs_get_drive(drive)
      call fs_get_icheck(icheck(18),18)
      if(icheck(18).le.0.or.ichecks(18).ne.icheck(18)) goto 699
      do jj=1,2
        ibuf1(2) = lmodna(18)
        iclass = 0
        do j=1,4
C  For the Mark IV tape drive, do not want to send ! strobe, which
C  is mode -1 to matcn. Replace with -5 which is the + strobe.
          if ((MK4.eq.iand(MK4,drive)).and.(j.eq.1)) then
            ibuf1(1) = -5
          else
            ibuf1(1) = icodes(j)
          endif
          call put_buf(iclass,ibuf1,-4,2Hfs,0)
        enddo
C
        ibuf1(1) = 8
        ibuf1(3) = o'47'   ! an apostrophe '
        call put_buf(iclass,ibuf1,-5,2Hfs,0)
C Finally, get alarm status
        call run_matcn(iclass,5)
C Send our requests to MATCN for the data
        call rmpar(ip)
        iclass = ip(1)
        nrec = ip(2)
        ierr = ip(3)
C
        if (ierr.ge.0) goto 300
        call clrcl(iclass)
      enddo
      call logit7(0,0,0,0,ierr,lwho,lmodna(18))
      goto 699
C
300   continue
C
      call gettp(iclass,nverr,niferr,nfmerr,ntperr,icherr)
C
699   continue
      return
      end
