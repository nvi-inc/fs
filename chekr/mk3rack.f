      subroutine mk3rack(lmodna,lwho,icherr,ichecks,nverr,niferr,
     .                   nfmerr)
C
      include '../include/fscom.i'
C 
C  INPUT: 
      integer*2 lmodna(1), lwho
      integer icherr(1), ichecks(1), nverr, niferr, nfmerr
C 
C  SUBROUTINES CALLED:
C 
C     MATCN - to get data from the modules
C     LOGIT - to log and display the error
C 
C  LOCAL VARIABLES: 
C 
      dimension ip(5)             ! - for RMPAR
      integer*2 ibuf1(40)
      dimension nbufs(17), icodes(4,17)
      integer rn_take
C      - MODule NAmes, 2-char codes
C      - Number of BUFfers for each module
C      - Integer CODES for MATCN for each buffer
C
C  INITIALIZED:
C
      data nbufs/15*2,2,2/
      data icodes/-1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0,  -1,-2,0,0, -1,-2,0,0,
     .            -1,-2,0,0, -53,-4,0,0/
      data nmod/17/
C
      do iloop=1,nmod
        call fs_get_icheck(icheck(iloop),iloop)
        if(icheck(iloop).le.0.or.ichecks(iloop).ne.icheck(iloop))
     .     goto 699
        do jj=1,2
          ibuf1(2) = lmodna(iloop)
          iclass = 0
          do j=1,nbufs(iloop)
            ibuf1(1) = icodes(j,iloop)
            call put_buf(iclass,ibuf1,-4,'fs','  ')
          enddo
C
          ibuf1(1) = 8
          ibuf1(3) = o'47'   ! an apostrophe '
          call put_buf(iclass,ibuf1,-5,'fs','  ')
C Finally, get alarm status
         ierr=rn_take('fsctl',0)
          call run_matcn(iclass,nbufs(iloop)+1)
          call rn_put('fsctl')
C Send our requests to MATCN for the data
          call rmpar(ip)
          iclass = ip(1)
          nrec = ip(2)
          ierr = ip(3)
C
          if (ierr.ge.0) goto 300
          call clrcl(iclass)
        enddo
        call logit7(0,0,0,0,ierr,lwho,lmodna(iloop))
        goto 699
C There was an error in MATCN.  Log it and go on to the next module.
C
C 3. This is the VC section.
C
300     continue
C
        if (iloop.gt.15) goto 400
        call getvc(iclass,nverr,icherr,iloop)
        goto 699
C
C 4. This is the IF distributor section.
C
400     continue
C
        if (iloop.ne.16) goto 500
        call getif(iclass,nverr,niferr,icherr)
        goto 699
C
C
C 5. This is the Formatter section.
C
500     continue
C
        if (iloop.ne.17) goto 699
        call getfm(iclass,nverr,niferr,nfmerr,icherr)
        goto 699
C
C This is the end of the checking loop over modules. 
C 
c       call clrcl(iclass)
699     continue
      enddo
C
      return
      end
