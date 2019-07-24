      function iat(itran,ntr,lumat,kecho,lu,irecv,nrc,ierr,itn)
C 
C   IAT handles communications with the MAT 
C 
C  WHO  WHEN    WHAT
C  NRV  810624  MODIFY FOR DVF00 TRIGGER CHAR IMMEDIATE TURNAROUND
C  NRV  811012  REMOVE SOME WVR-SPECIFIC CODE (AFTER RBM) 
C  MWH  870911  Modify for use with A400 8-channel MUX
C  gag  920716  Added mode -54.
C
      include 'matcm.i'
C 
C  INPUT VARIABLES:
C 
C  NTR    - number of characters in ITRAN 
C  LUMAT  - LU of MAT daisy chain 
C  LU     - LU for operator's terminal
      integer*2 itran(1)         ! buffer to be transmitted
      logical kecho              ! true if MAT communications echo desired
C 
C  OUTPUT VARIABLES: 
C 
C  NRC    - number of characters in received buffer 
C  IERR   - error code

      integer*2 irecv(1)         ! buffer received from AT 
C 
C  CALLING SUBROUTINES: MATCN,DATAT
C
C  CALLED SUBROUTINES: character utilities
C 
C LOCAL VARIABLES 
C 
C  ILEN   - max length available in ITRAN buffer, characters. 
C          ***NOTE*** THIS MUST CORRESPOND TO THE LENGTH
C                     OF IBUF2 IN MATCN, LESS 1 WORD. 
C  IFRECV - 1 if we expect response, 0 if none expected
C  IR     - which terminal character in IRSPN we find
C  MAXTRY - maximum number of times we will try to communicate
C  ITRY - count of attempts
C  NCTRAN - number of char to be transmitted
C  NRSPN  - number of responses possible
      integer ichmv, portflush, portwrite,portread
      dimension ireg(2)
      integer nchrc(8)   ! number of characters received in responses
      integer*2 irspn(4) ! terminal characters which generate a response
      integer wrdech,maxech
      parameter (wrdech=320,maxech=wrdech*2)
      integer iebuf(wrdech),iebuf2(wrdech),itn
      integer*2 irecx(10)
C
      equivalence (ireg(1),reg)
C
C   INITIALIZED VARIABLES
C
      data nchrc/3,3,10,10,3,3,16,3/
      data irspn/2h$*,2h?/,2h>',2h :/
C                   We put <enq> in first charcater of last word by hand below
      data ilen/158/
      data nrspn/8/
      data maxtry/2/
C
      call pchar(irspn(4),1,5)
C
C 1. Set up the buffer to be sent to the MAT.
C    First initialize some things.
C
      ierr = 0
      itry = 0
      nrc = 0
      nctran = ntr
      itimeout=itn
C
C  1.1 Find the last character in the buffer to determine the
C      type of response.
C
      if (iscn_ch(itran,1,ntr,':').ne.0) then
        ir = 8
        ifrecv = 1
      else if (imode.eq.-54) then
        ifrecv = 1
      else if (imode.eq.9) then
        ifrecv = 1
      else
C  A colon in the message means a response to the download 
        do ir=1,nrspn
          if (jchar(itran,ntr).eq.jchar(irspn,ir)) then
            ifrecv = 1
            goto 200
          endif
        enddo
        ifrecv = 0
      endif
C  Check each type of terminal character
C  IR holds the index for the type of response
C
C  2. Write the buffer to the MAT, and read response if expected.
C     Set the time-out on the MAT depending on the response.
C
200   continue
      if (kecho) then
        call echoe(itran,iebuf,nctran,iecho,maxech)
      endif
C  Write message on the screen if echo is on
      ilen=nchrc(ir)
      ierr=portflush(lumat)
      if(imode.eq.-53) then
        ierr=portwrite(lumat,itran,nctran-1)
        idum=ichmv(irecx,1,itran,nctran,1)
        call fc_rte_time(it1,it1(6))
        ierr=portwrite(lumat,irecx,1)
      else if(imode.eq.-54) then
        call fc_rte_time(it1,it1(6))
        ierr=portwrite(lumat,itran,nctran)
      else
        ierr=portwrite(lumat,itran,nctran)
      endif
C                   Write the buffer to the MAT bus
      if (ifrecv.eq.0) then
        iat = 0
        if (kecho) then
          call put_cons_raw(iebuf,iecho)
          call put_cons_raw(o'006412',1)   !cr-lf
        endif
        return    !  we're done now if there is to be no response.
      endif
C
C  For actual communications, use o'2000' in the read request.
C  For terminal tests, use o'400' instead.
C    o'2000' = 0 0 0 0 1 0 0 0 0    followed by six bits of LU #
C            !       !   !   ! ASCII read
C            !       !   ! no echo
C            !       ! transmit special characters
C            ! buffered mode
C
      maxc=ilen
C  at this time, don't know how many characters are expected 7/16/92
      if(imode.eq.-53) then
        ireg(1)=portread(lumat,irecx,ilen,1,-1,itimeout)
        call fc_rte_time(it1(7),it1(12))
        ireg(1)=portread(lumat,irecx(2),ilen,maxc-1,-1,itimeout)
        idum=ichmv(irecv,1,irecx,1,1)
        idum=ichmv(irecv,2,irecx(2),1,maxc-1)
        ilen=ilen+1
      else if(imode.eq.-54) then
        maxc=40
        ireg(1)=portread(lumat,irecx,ilen,1,-1,itimeout)
        call fc_rte_time(it1(7),it1(12))
        ireg(1)=portread(lumat,irecx(2),ilen,maxc-1,10,itimeout)
        idum=ichmv(irecv,1,irecx,1,1)
        idum=ichmv(irecv,2,irecx(2),1,maxc-1)
        ilen=ilen+1
      else if (imode.eq.9) then
        maxc=78
        ireg(1)=portread(lumat,irecv,ilen,maxc,10,itimeout)
      else
        ireg(1)=portread(lumat,irecv,ilen,maxc,-1,itimeout)
      endif
c     if (ichcm_ch(irecv,1,'t').eq.0) then
c       ierr = -4
c       return
c     endif
c
      nrc=ilen
      if (kecho) then
         call echoe(irecv,iebuf2,nrc,iecho2,maxech)
         call put_cons_raw(iebuf,iecho)
         call put_cons_raw(iebuf2,iecho2)
         call put_cons_raw(o'006412',1)    !cr-lf
      endif
C  If echo requested, write response on screen
      itry = itry + 1
C
C
C  8. Now check for errors.  If time-out or wrong number of characters,
C     try communications all over again.
C     If we got a o'6' (ack) or o'25' (nak) substitute readable ACK or NAK.
C
      if (ireg(1).eq.-2) then          ! timeout
        if (itry.lt.maxtry) goto 200
        ierr = -4
      else if (nrc.ne.nchrc(ir).and.imode.ne.9.and.imode.ne.-54) then
c                                ! wrong # of characters in response
        if (itry.lt.maxtry) goto 200
        call ifill_ch(irecv,1,80,' ')
        nrc=0
        ierr = -5
      else if (jchar(irecv,1).eq.o'6') then        ! ack response
        ierr = +1
        nrc = ichmv(irecv,1,3hack,1,3) - 1
      else if (jchar(irecv,1).eq.o'25') then     ! nak response
        if (ir.eq.5.and.itry.lt.maxtry) goto 200
        ierr = +2
        nrc = ichmv(irecv,1,3hnak,1,3) - 1
      else
        ierr = 0
      endif
      iat = ierr

      return
      end 
