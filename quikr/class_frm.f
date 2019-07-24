      subroutine class_frm(ipre,ich,ip)
      implicit none
      integer*2 ipre(1)
      integer ich,ip(5)
C
C  CLASS_FRM: format class contents from MATCn and seend to class
C
C  INPUT:
C     IPRE - command to extract log entry prefix from
C            the prefix is the part upto the first equal or end
C            whichever comes first
C     IP - Field System Return Parameters
C     IP(1) - class number
C     IP(2) - number of records in the class
C
C  If PREFIX + / + buffer exceeds MAX_CHARS, it is truncated.
C
      integer max_wds,max_chars,len_wds,len_chars
      parameter (
     &          max_chars=120,
     &          max_wds=(max_chars+1)/2,
     &          len_chars=20,
     &          len_wds=(len_chars+1)/2
     &          )
      integer*2 ibuf(len_wds),ibuf2(max_wds)
      integer nrec,i,ncfsr,nch
      integer ichmv,mcoma,imov,nchs,iscn_ch,iclass
C
      iclass=0
      nrec=0
C
      if (ip(2).ne.0) then
        imov=iscn_ch(ipre,1,ich,'=')-1
        if(imov.le.0) imov=ich
        nch=1
        nch=ichmv(ibuf2,nch,ipre,1,min(imov,max_chars))
        nch=ichmv(ibuf2,nch,2h//,1,1)
        nchs=nch
        do while(ip(2).gt.0)
          call get_class(ibuf,-len_chars,ip,ncfsr)
          if(nch.ne.nchs.and.nch+ncfsr-2.gt.max_chars)then
            call add_class(ibuf2,nch-1,iclass,nrec)
            nch=nchs
          endif
          if (nch.ne.nchs) nch=mcoma(ibuf2,nch)
          nch = ichmv(ibuf2,nch,ibuf(2),1,min(ncfsr-2,max_chars-nch+1))
        enddo
        if(nch.ne.nchs) call add_class(ibuf2,nch-1,iclass,nrec)
      endif
C
      ip(1)=iclass
      ip(2)=nrec
C
      return
      end
