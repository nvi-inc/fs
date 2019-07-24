      subroutine lxsze
C
C  COMMON BLOCKS USED:
C 
      include '../include/fscom.i'
      include 'lxcom.i'
C 
C      CALLING SUBROUTINES: 
C 
C      File manager package routines
C      Character manipulation routines
C 
C  LOCAL VARIABLES: 
C 
      character*79 outbuf
      integer answer, nchar, trimlen
      character cjchar
      dimension iparm(2)
C 
      equivalence (parm,iparm(1))
C 
C  INITIALIZED VARIABLES:
C
      data n/1/ 
C 
C 
1600  if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 1610
        outbuf='size= '
        call ib2as(iwidth,answer,1,4)
        call hol2char(answer,1,4,outbuf(7:))
        call ib2as(ihgt,answer,1,4)
        call hol2char(answer,1,4,outbuf(12:))
        call po_put_c(outbuf)
        goto 1700
C
C Get the width parameter
C
1610  ich=ieq+1
      call gtprm(ibuf,ich,nchar,1,parm,id)
      if (cjchar(iparm,1).ne.',') goto 1620
      iwidth=78
      goto 1640
C
C Check for a valid width and if it is ok, store it.
C
1620  if (iparm(1).lt.78.or.iparm(1).gt.130) goto 1630
        iwidth=iparm(1)
        goto 1640
1630  outbuf='lxsze100 - '
      call ib2as(iparm(1),answer,1,4)
      call hol2char(answer,1,4,outbuf(12:))
      nchar = trimlen(outbuf) + 1
      outbuf(nchar:)=' is an invalid width parameter'
      call po_put_c(outbuf)
      goto 1700
C
C Get the height parameter
C
1640  call gtprm(ibuf,ich,nchar,1,parm,id)
      if (cjchar(iparm,1).ne.',') goto 1650
      ihgt=18
      goto 1700
C
C Check for a valid height, if ok, store it.
C
1650  if (iparm(1).lt.10.or.iparm(1).gt.100) goto 1660
        ihgt=iparm(1)
        goto 1700
1660  outbuf='lxsze110 - '
      call ib2as(iparm(1),answer,1,4)
      call hol2char(answer,1,4,outbuf(12:))
      nchar = trimlen(outbuf) + 1
      outbuf(nchar:)=' is an invalid height parameter'
      call po_put_c(outbuf)
C
1700  continue
      return
      end
