      subroutine beam(ip,nsub)
C
C     Set and display RF beamwidth, FWHM
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
      dimension ip(1)
      dimension ireg(2),iparm(2)
      integer get_buf
      integer*2 ibuf(20)
      real*4 btmp
      double precision flo
      integer sblo
      character cjchar
C
      equivalence (ireg(1),reg),(iparm(1),parm)
C
      data ilen/40/
C
C  HISTORY:
C  WHO  WHEN    WHAT
C  NRV  920226  Get LO freq. from shm
C  gag  920713  Added a check for Mark IV along with checking Mark III
C
      indtmp=nsub
C
      iclcm = ip(1)
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2)
      call fs_get_rack(rack)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500
C
C     2. Parse the command:   BEAM=< SIZE>
C
C     2.1 First get the size and convert to radians
C
210   ich = ieq+1
      ic1 = ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 215
      if (cjchar(parm,1).ne.'*') goto 211
      btmp = beamsz_fs(indtmp)
C                   Pick up the size from common
      goto 300
211   continue
      indf=indtmp 
      if(indf.gt.4) then
         ierr=-413
         goto 990
      endif
      call fs_get_freqlo(flo,indf-1)
c      write(6,101) flo,indf
c101   format(/' flo,indf=',f10.3,i5/)
      f=flo
      if(f.lt.0) then
         ierr=-401
         goto 990
      endif
C
C use the middle of the bandpass for the appropriate rack
C
      call fs_get_sblo(sblo,indf-1)
      if(sblo.eq.2) then
         isg=-1
      else
         isg=+1
      endif
c      write(6,102) isg,sblo
c 102  format(/' isign, sblo=',2i10/)
      if(VLBA.eq.rack.or.VLBA4.eq.rack) then
        f=f+isg*750.
      else
        f=f+isg*300.
        if(indf.eq.3) then
          call fs_get_icheck(icheck(21),21)
          call fs_get_imixif3(imixif3)
          if(icheck(21).eq.0) then
             ierr=-502
             goto 990
          else if(imixif3.eq.1) then
             call fs_get_freqif3(freqif3)
             f=f+isg*freqif3*0.01
c            write(6,*) freqif3
          endif
        endif
      endif
      call fs_get_diaman(diaman)
c100   format(/' f,diaman=',2f10.3/)
c      write(6,100) f,diaman
      btmp=0.0
      if (f.gt.0.0.and.diaman.gt.0.0)
     .btmp=1.05*299792458d0/(f*1d6*diaman)
      if(btmp.gt.4.8d-8)  goto 300
      ierr=-401
  
C                   there is no default if IFD and LO haven't been set
      goto 990
215   call gtrad(ibuf,ic1,ich-2,2,btmp,ierr)
      if (ierr.ge.0.and.btmp.gt.0.0) goto 300
      ierr = -402
      goto 990
C
C     3. Plant the variables in COMMON.
C
300   continue
      beamsz_fs(indtmp) = btmp
      if(indtmp.eq.1) then
        flx1fx_fs=-1.0
      else if (indtmp.eq.2) then
        flx2fx_fs=-1.0
      else if (indtmp.eq.3) then
        flx3fx_fs=-1.0
      else if (indtmp.eq.4) then
        flx4fx_fs=-1.0
      else if (indtmp.eq.5) then
        flx5fx_fs=-1.0
      else
        flx6fx_fs=-1.0
      endif
      ierr = 0
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qo',ip(4),1,2)
      return
C
C     5. Return the beamsize for display
C
500   nch = ichmv_ch(ibuf,nchar+1,'/')
      bo=beamsz_fs(indtmp)*180./RPI
      nch = nch + ir2as(bo,ibuf,nch,10,4)
C
      iclass = 0
      nch = nch - 1
      call put_buf(iclass,ibuf,-nch,'fs','  ')
      ip(1) = iclass
      ip(2) = 1
      ip(3) = 0 
      call char2hol('qo',ip(4),1,2)

      return
      end 
