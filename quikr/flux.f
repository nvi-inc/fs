      subroutine flux(ip,nsub)
C
C     Set and display FLUX values
C
      include '../include/fscom.i'
      include '../include/dpi.i'
C
      dimension ip(1)
      dimension ireg(2),iparm(2)
      integer get_buf,ichcm_ch
      integer*2 ibuf(40)
      integer imdl
      real*4 arr(6)
      character cjchar
C
      equivalence (ireg(1),reg),(iparm(1),parm)
C
      data ilen/80/
C
      imdl=0
      do i=1,6
        arr(i)=0.0
      enddo
C
      indtmp=nsub-10
C
      iclcm = ip(1)
      ireg(2) = get_buf(iclcm,ibuf,-ilen,idum,idum)
      nchar = ireg(2)
      call fs_get_rack(rack)
      ieq = iscn_ch(ibuf,1,nchar,'=')
      if (ieq.eq.0) goto 500
C
C     2. Parse the command:
C
C  FLUX=GAUSSIAN,<flux1>,<major1>,<minor1>,<flux2>,<major2>,<minor2>
C  FLUX=DISK,<flux>,<diameter>
C  FLUX=TWOPOINTS,<flux1>,<seperation>,<flux2>
C
C     2.1 First get the model name
C
C
220   continue
      ich=ieq+1
      ic2=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 225
      if (cjchar(parm,1).ne.'*') goto 221
      if(indtmp.eq.1) then
        imdl=imdl1fx_fs
      else if(indtmp.eq.2) then
        imdl=imdl2fx_fs
      else if(indtmp.eq.3) then
        imdl=imdl3fx_fs
      else if(indtmp.eq.4) then
        imdl=imdl4fx_fs
      else if(indtmp.eq.5) then
        imdl=imdl5fx_fs
      else
        imdl=imdl6fx_fs
      endif
C                   Pick up the model from common
      goto 229
221   continue
      corr=1.0
      flx=-3.0
C  there is no default for the model, so assume the user doesn't want one
      goto 301
225   continue
      imdl=-1
      if(ichcm_ch(ibuf,ic2,'gaussian').eq.0) imdl=1
      if(ichcm_ch(ibuf,ic2,'disk').eq.0) imdl=2
      if(ichcm_ch(ibuf,ic2,'twopoints').eq.0) imdl=3
C
229   continue
      if(imdl.ge.0.and.imdl.le.3) go to 230
      ierr=-403
      goto 990
C
C  2.3 second parameter value, a flux
C
230   continue
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(ierr.ne.0) then
        ierr=-411
        goto 990
      endif
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 235
      if (cjchar(parm,1).ne.'*') goto 231
      if(indtmp.eq.1) then
        arr(1)=arr1fx_fs(1)
      else if(indtmp.eq.2) then
        arr(1)=arr2fx_fs(1)
      else if(indtmp.eq.3) then
        arr(1)=arr3fx_fs(1)
      else if(indtmp.eq.4) then
        arr(1)=arr4fx_fs(1)
      else if(indtmp.eq.5) then
        arr(1)=arr5fx_fs(1)
      else
        arr(1)=arr6fx_fs(1)
      endif
C                   Pick up the flux from common
      goto 240
231   continue
      ierr=-404
C                   there is no default for the flux
      goto 990
235   continue
      arr(1)=parm
      go to 240
C
C 2.4 third parameter, an angle
C
240   continue
      ic1=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 245
      if (cjchar(parm,1).ne.'*') goto 241
      if(indtmp.eq.1) then
        arr(2)=arr1fx_fs(2)
      else if(indtmp.eq.2) then
        arr(2)=arr2fx_fs(2)
      else if(indtmp.eq.3) then
        arr(2)=arr3fx_fs(2)
      else if(indtmp.eq.4) then
        arr(2)=arr4fx_fs(2)
      else if(indtmp.eq.5) then
        arr(2)=arr5fx_fs(2)
      else
        arr(2)=arr6fx_fs(2)
      endif
C                   Pick up the angle from common
      goto 250
241   continue
      ierr=-405
C                   there is no default for the angle
      goto 990
245   continue
      call gtrad(ibuf,ic1,ich-2,4,arr(2),ierr)
      if (ierr.ge.0.and.arr(2).gt.0.0) goto 250
      ierr = -406
      goto 990
C
C  2.5 third parameter, angle for model 1 and 4
C
250   continue
      ic1=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 255
      if (cjchar(parm,1).ne.'*') goto 251
      if(indtmp.eq.1) then
        arr(3)=arr1fx_fs(3)
      else if (indtmp.eq.2) then
        arr(3)=arr2fx_fs(3)
      else if (indtmp.eq.3) then
        arr(3)=arr3fx_fs(3)
      else if (indtmp.eq.4) then
        arr(3)=arr4fx_fs(3)
      else if (indtmp.eq.5) then
        arr(3)=arr5fx_fs(3)
      else
        arr(3)=arr6fx_fs(3)
      endif
C                   Pick up the value from common
      goto 260
251   continue
      if(imdl.eq.1) then
        arr(3)=arr(2)
      else
        arr(3)=0.0
      endif
C                   pick correct default
      goto 260
255   continue
      call gtrad(ibuf,ic1,ich-2,4,arr(3),ierr)
      if (ierr.ge.0.and.arr(3).gt.0.0) goto 260
      ierr = -407
      goto 990
C
C 2.6 fifth parameter: flux for model 4
C
260   continue
      call gtprm(ibuf,ich,nchar,2,parm,ierr)
      if(ierr.ne.0) then
        ierr=-412
        goto 990
      endif
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 265
      if (cjchar(parm,1).ne.'*') goto 261
      if(indtmp.eq.1) then
        arr(4)=arr1fx_fs(4)
      else if(indtmp.eq.2) then
        arr(4)=arr2fx_fs(4)
      else if(indtmp.eq.3) then
        arr(4)=arr3fx_fs(4)
      else if(indtmp.eq.4) then
        arr(4)=arr4fx_fs(4)
      else if(indtmp.eq.5) then
        arr(4)=arr5fx_fs(4)
      else
        arr(4)=arr6fx_fs(4)
      endif
C                   Pick up the value from common
      goto 270
261   continue
      arr(4)=0.0
C                default is zero
      goto 270
265   continue
      arr(4)=parm
      go to 270
C
C 2.7 sixth parameter: angle for model 1
C
270   continue
      ic1=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 275
      if (cjchar(parm,1).ne.'*') goto 271
      if(indtmp.eq.1) then
        arr(5)=arr1fx_fs(5)
      else if(indtmp.eq.2) then
        arr(5)=arr2fx_fs(5)
      else if(indtmp.eq.3) then
        arr(5)=arr3fx_fs(5)
      else if(indtmp.eq.4) then
        arr(5)=arr4fx_fs(5)
      else if(indtmp.eq.5) then
        arr(5)=arr5fx_fs(5)
      else
        arr(5)=arr6fx_fs(5)
      endif
C                   Pick up the angle from common
      goto 280
271   continue
      arr(5)=0.0
C                   default is zero
      goto 280
275   continue
      call gtrad(ibuf,ic1,ich-2,4,arr(5),ierr)
      if (ierr.ge.0.and.arr(5).gt.0.0) goto 280
      ierr = -408
      goto 990
C
C 2.8 7th parameter: angle for model 1
C
280   continue
      ic1=ich
      call gtprm(ibuf,ich,nchar,0,parm,ierr)
      if (cjchar(parm,1).ne.'*'.and.cjchar(parm,1).ne.',') goto 285
      if (cjchar(parm,1).ne.'*') goto 281
      if(indtmp.eq.1) then
        arr(6)=arr1fx_fs(6)
      else if(indtmp.eq.2) then
        arr(6)=arr2fx_fs(6)
      else if(indtmp.eq.3) then
        arr(6)=arr3fx_fs(6)
      else if(indtmp.eq.4) then
        arr(6)=arr4fx_fs(6)
      else if(indtmp.eq.5) then
        arr(6)=arr5fx_fs(6)
      else
        arr(6)=arr6fx_fs(6)
      endif
C                   Pick up the angle from common
      goto 300
281   continue
      arr(6)=arr(5)
C                   default is previous parameter
      goto 300
285   continue
      call gtrad(ibuf,ic1,ich-2,4,arr(6),ierr)
      if (ierr.ge.0.and.arr(6).gt.0.0) goto 300
      ierr = -409
      goto 990
C
C     3. Plant the variables in COMMON.
C
300   continue
C
C     3.1 first calculate effective flux
C
      bm=beamsz_fs(indtmp)
      if(bm.lt.4.8e-8) then
        ierr=-410
        goto 990
      endif
      fx=flxvl(imdl,arr,bm,corr)
301   continue
      if(indtmp.eq.1) then
        imdl1fx_fs=imdl
        do i=1,6
          arr1fx_fs(i)=arr(i)
        enddo
        cor1fx_fs=corr
        flx1fx_fs=fx
      else if(indtmp.eq.2) then
        imdl2fx_fs=imdl
        do i=1,6
          arr2fx_fs(i)=arr(i)
        enddo
        cor2fx_fs=corr
        flx2fx_fs=fx
      else if(indtmp.eq.3) then
        imdl3fx_fs=imdl
        do i=1,6
          arr3fx_fs(i)=arr(i)
        enddo
        cor3fx_fs=corr
        flx3fx_fs=fx
      else if(indtmp.eq.4) then
        imdl4fx_fs=imdl
        do i=1,6
          arr4fx_fs(i)=arr(i)
        enddo
        cor4fx_fs=corr
        flx4fx_fs=fx
      else if(indtmp.eq.5) then
        imdl5fx_fs=imdl
        do i=1,6
          arr5fx_fs(i)=arr(i)
        enddo
        cor5fx_fs=corr
        flx5fx_fs=fx
      else
        imdl6fx_fs=imdl
        do i=1,6
          arr6fx_fs(i)=arr(i)
        enddo
        cor6fx_fs=corr
        flx6fx_fs=fx
      endif
      ierr = 0
C
990   ip(1) = 0
      ip(2) = 0
      ip(3) = ierr
      call char2hol('qo',ip(4),1,2)
      return
C
C     5. Return the values for display
C
500   nch = ichmv_ch(ibuf,nchar+1,'/')
      if(indtmp.eq.1) then
        imdl=imdl1fx_fs
        do i=1,6
          arr(i)=arr1fx_fs(i)
        enddo
        corr=cor1fx_fs
        fx=flx1fx_fs
      else if(indtmp.eq.2) then
        imdl=imdl2fx_fs
        do i=1,6
          arr(i)=arr2fx_fs(i)
        enddo
        corr=cor2fx_fs
        fx=flx2fx_fs
      else if(indtmp.eq.3) then
        imdl=imdl3fx_fs
        do i=1,6
          arr(i)=arr3fx_fs(i)
        enddo
        corr=cor3fx_fs
        fx=flx3fx_fs
      else if(indtmp.eq.4) then
        imdl=imdl4fx_fs
        do i=1,6
          arr(i)=arr4fx_fs(i)
        enddo
        corr=cor4fx_fs
        fx=flx4fx_fs
      else if(indtmp.eq.5) then
        imdl=imdl5fx_fs
        do i=1,6
          arr(i)=arr5fx_fs(i)
        enddo
        corr=cor5fx_fs
        fx=flx5fx_fs
      else
        imdl=imdl6fx_fs
        do i=1,6
          arr(i)=arr6fx_fs(i)
        enddo
        corr=cor6fx_fs
        fx=flx6fx_fs
      endif
C
      if(imdl.eq.1) then
        nch=ichmv_ch(ibuf,nch,'gaussian')
      else if(imdl.eq.2) then
        nch=ichmv_ch(ibuf,nch,'disk')
      else if(imdl.eq.3) then
        nch=ichmv_ch(ibuf,nch,'twopoints')
      endif
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(arr(1),ibuf,nch,10,1)
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(arr(2)*180./RPI,ibuf,nch,10,4)
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(arr(3)*180./RPI,ibuf,nch,10,4)
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(arr(4),ibuf,nch,10,1)
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(arr(5)*180./RPI,ibuf,nch,10,4)
      nch=mcoma(ibuf,nch)
C
      nch=nch+ir2as(arr(6)*180./RPI,ibuf,nch,10,4)
      nch=mcoma(ibuf,nch)
C
      nch = nch + ir2as(corr,ibuf,nch,10,3)
      nch=mcoma(ibuf,nch)
C
      nch = nch + ir2as(fx,ibuf,nch,10,1)
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
