      subroutine newpf(idcbp1,idcbp2,lproc1,maxpr1,nproc1,lproc2,
     .maxpr2,nproc2,ibuf,iblen,istkop,istksk)
C
C     NEWPF checks for a newly-edited procedure file from PFMED
C     and acts accordingly.
C
C     DATE   WHO CHANGES                   LAST EDIT <910328.1434>
C     810906 NRV CREATED
C     890509 MWH Modified to use CI files
C
C  COMMON BLOCKS:
C
      include '../include/fscom.i'
C
C  INPUT/OUTPUT:
C
C     IDCBP1,IDCBP2 - DCBs for the two procedure files
C     LPROC1,LPROC2 - directory arrays for the two files
C     MAXPR1,MAXPR2 - maximum number of entries in each file
C     NPROC1,NPROC2 - actual number of entries
C     IBUF - buffer to pass to OPNPF for use
C     IBLEN - length of IBUF in words
C     ISTKOP,ISTKSK - operator and schedule procedure stacks
      dimension idcbp1(1),idcbp2(1)
      integer*2 ibuf(1)
      integer*2 lproc1(10,1),lproc2(10,1)
      dimension istkop(1),istksk(1)
C
C
C  CALLING ROUTINES: BOSS
C  SUBROUTINES CALLED:  OPNPF, KSTAK, FMP
C
C  LOCAL:
C
C     KSTAK - function which is TRUE if there's some procedure in the stacks
      character*28 pathname,pathname2
      logical kstak, rn_test, result
      integer trimlen, nch, rn_take
C
C  INITIALIZED:
C
C
C     1. Lock the resource number no matter what.
C
      ierr = 0
      irnprc = rn_take('pfmed',1)
      if (irnprc.eq.0) then
C
C     2. Get a new version of the schedule proc file.
C     First check that there are not any procedures from the schedule
C     library on the active stack list.
C     If not, then close the file, purge it, and rename the pending
C     edited file to the proper name.  Then call OPNPF to get the
C     directory.
C
        call fs_get_lnewsk(ilnewsk)
        if (ilnewsk(1).eq.0) then
          lnewsk=' '
        else
          call hol2char(ilnewsk,1,8,lnewsk)
        end if
        if ((lnewsk.ne.' ').and.(.not.kstak(istkop,istksk,1))) then
          call fmpclose(idcbp1,ierr)
          call fs_get_lprc(ilprc)
          call hol2char(ilprc,1,8,lprc)
          nch = trimlen(lprc)
          pathname = FS_ROOT//'/proc/' // lprc(1:nch) // '.prc'
          call ftn_purge(pathname,ierr)
C                     Purge the old version of the file
          call fs_get_lprc(ilprc)
          call hol2char(ilprc,1,8,lprc)
          nch = trimlen(lprc)
          pathname2= FS_ROOT//'/proc/' // lprc(1:nch) // '.prx'
          call ftn_rename(pathname2,ierr1,pathname,ierr2)
C                     Rename the edited version to the proper name
          if (ierr1.lt.0) then
            call logit7(0,0,0,1,-127,2hbo,ierr1)
            ierr1 = 0
          else if (ierr2.lt.0) then
            call logit7(0,0,0,1,-127,2hbo,ierr2)
            ierr2 = 0
          else
            call fs_get_lprc(ilprc)
            call hol2char(ilprc,1,8,lprc)
            call opnpf(lprc,idcbp1,ibuf,iblen,lproc1,maxpr1,nproc1,ierr,
     &               'o')
            lnewsk = ' '
            call char2hol(lnewsk,ilnewsk,1,12)
            call fs_set_lnewsk(ilnewsk)
          endif
        endif
C
C     3. Get a new version of the station proc file.
C
        call fs_get_lnewpr(ilnewpr)
        if (ilnewpr(1).eq.0) then
          lnewpr=' '
        else
          call hol2char(ilnewpr,1,8,lnewpr)
        endif
        if (lnewpr.ne.' '.and..not.kstak(istkop,istksk,2)) then
          call fmpclose(idcbp2,ierr)
          call fs_get_lstp(ilstp)
          call hol2char(ilstp,1,8,lstp)
          nch = trimlen(lstp)
          pathname = FS_ROOT//'/proc/' // lstp(1:nch) // '.prc'
          call ftn_purge(pathname,ierr)
          call fs_get_lstp(ilstp)
          call hol2char(ilstp,1,8,lstp)
          nch = trimlen(lstp)
          pathname2= FS_ROOT//'/proc/' // lstp(1:nch) // '.prx'
          call ftn_rename(pathname2,ierr1,pathname,ierr2)
          if (ierr1.lt.0) then
            call logit7(0,0,0,1,-127,2hbo,ierr1)
            ierr1 = 0
          else if (ierr2.lt.0) then
            call logit7(0,0,0,1,-127,2hbo,ierr2)
            ierr2 = 0
          else
            call fs_get_lstp(ilstp)
            call hol2char(ilstp,1,8,lstp)
            call opnpf(lstp,idcbp2,ibuf,iblen,lproc2,maxpr2,nproc2,ierr,
     &               'o')
            lnewpr = ' '
            call char2hol(lnewpr,ilnewpr,1,12)
            call fs_set_lnewpr(ilnewpr)
          endif
        endif
C
        call rn_put('pfmed') 
        if (ierr.lt.0) call logit7(0,0,0,1,-131,2hbo,ierr)
      endif
C
      return
      end
