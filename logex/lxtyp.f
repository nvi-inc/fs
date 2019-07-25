      subroutine lxtyp
C
C  COMMON BLOCKS USED:
C 
      include '../include/fscom.i'
      include 'lxcom.i'
C 
C  LOCAL VARIABLES: 
C 
      character*79 outbuf
      integer answer, nchar, trimlen, jchar, ichcm_ch
      integer*2 iprm
      dimension iparm(2)
C 
      equivalence (parm,iparm(1))
C 
      integer*2 lspecr(4)
C        - Array of valid special characters
C
C  INITIALIZED VARIABLES:
C
      data jtype/5/
      data lspecr/2H:;,2H$@,2H?&,2H/#/
      data n/1/ 
C 
C 
C  Determine whether any types were specified by search for any equals
C  sign.  If there was no equals sign, write out the previous specified
C  types.
C
C
      if (iscn_ch(ibuf,1,nchar,'=').ne.0) goto 1110
C
C
C  If no types are specified, a message is written out. If any types
C  were specified, they are written out.  If all types were requested, a
C  message is written out.
C
      if (ntype.eq.0) then
        call po_put_c(' none specified')
        goto 1700
      else if (ichcm_ch(ntype,1,' ').eq.0) then
        call po_put_c('type= <all types are being listed>')
        goto 1700
      else
        outbuf='type='
        nchar=6
        do i=1,ntype
          call hol2char(ltype(i),1,1,outbuf(nchar:))
          if (i.ne.ntype) then
            outbuf(nchar+1:)=','
            nchar=nchar+2
          endif
        enddo
        call po_put_c(outbuf)
        goto 1700
      end if
C
C  Let's get the special characters that are specified.  Fill the LTYPE
C  array in case a previous TYPE command was issued.
C
1110  ich=ieq+1
      ntype=0
      call ifill_ch(ltype,1,10,' ')
      do i=1,jtype
        call gtprm(ibuf,ich,nchar,0,parm,id)
C
C  Store the special character in IPRM.
C
        iprm=jchar(iparm,1)
C
C  If the first parm is an a, then all types are to be listed. Set
C  NTYPE to a blank and return to LOGEX.
C
        if (ichcm_ch(iprm,1,'A').eq.0) then
          call char2hol(' ',ntype,1,1)
          goto 1700
        end if
C
        if (ichcm_ch(iprm,1,',').eq.0) goto 1700
        idumc=0
c        idum=ichmv(idumc,2,iprm,1,1)
        idumc=jchar(iprm,1)
        nch=iscnc(lspecr,1,8,idumc)
        ltype(i)=iprm
C
C  Check to see if the character is valid.
C
        if (nch.eq.0) then
          outbuf='lxtyp50 - invalid special character: '
          call hol2char(ltype(i),1,1,outbuf(38:))
          call po_put_c(outbuf)
        endif
        icode=-1
        ntype=ntype+1
      end do
C
1700  continue
      return
      end
