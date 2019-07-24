      function mdnam(lnam)

C   parse module names c#870407:13:00# 
C 
C     MDNAM parses module names entered as parameters in SNAP commands, 
C     outputting the appropriate 2-character mnemonic.
C 
C  INPUT: 
C 
      dimension lnam(1) 
C          - module name to be parsed 
C 
C  OUTPUT:
C 
C     MDNAM - 2-character mnemonic for module name
C 
C  LOCAL VARIABLES: 
C 
      integer*2 icr(4)
      integer*2 ic2
C          - array of individual characters in LNAM 
C     NC - character position in LNAM 
C     IC2 - 2nd character of mnemonic 
C 
C  CONSTANTS: 
      integer*2 istcr(9)
C 
      data istcr/97,111,101,102,116,105,118,98,114/
C                a   o   e   f   t   i   v   b  r
C          - legal decimal values for 1st character of module name
C 
C  DATE  WHO  CHANGES 
C 840308 MWH  Created 
C 
C 
C  Initialize and transfer control based on first character of module name
      mdnam=0 
      do ii=1,4 
        icr(ii)=jchar(lnam,ii)
      enddo

      do i=1,9
        if (jchar(lnam,1).eq.istcr(i)) goto 105 
      enddo
      goto 900 
105   goto (110,120,130,140,150,160,170,180,190) i 

C  Handle ALL, ODD, EVEN

110   if (ichcm(lnam,1,4Hall ,1,4).eq.0) call char2hol('al',mdnam,1,2)
      goto 900 

120   if (ichcm(lnam,1,4Hodd ,1,4).eq.0) call char2hol('od',mdnam,1,2)
      goto 900 

130   if (ichcm(lnam,1,4Heven,1,4).eq.0) call char2hol('ev',mdnam,1,2)
      goto 900 

C  Handle formatter or tape 

140   if (ichcm(lnam,1,4Hfm  ,1,4).eq.0.or.ichcm(lnam,1,4Hform,1,4)
     .   .eq.0) call char2hol('fm',mdnam,1,2)
      goto 900 

150   if (ichcm(lnam,1,4Htp  ,1,4).eq.0.or.ichcm(lnam,1,4Htape,1,4)
     .   .eq.0) call char2hol('tp',mdnam,1,2)
      goto 900 

C  Handle IFD's 

160   continue

      nc=2
      if (icr(nc).ne.o'146') goto 163  !! "f"
        nc=3
      if (icr(nc).ne.o'144') goto 165  !! "d"
        nc=4
163   if (icr(nc).eq.o'61') call char2hol('i1',mdnam,1,2) !! "1"
      if (icr(nc).eq.o'62') call char2hol('i2',mdnam,1,2) !! "2"
165   if (icr(nc).eq.o'40') call char2hol('if',mdnam,1,2) !! " "

C  look for VLBA mnemonics

      nc=2
      if (icr(nc).ne.o'146') goto 166  !! "f"
        nc=3
      if (icr(nc).ne.o'144') goto 166  !! "d"
        nc=4
166   if (icr(nc).eq.o'141') call char2hol('ia',mdnam,1,2) !! "a"
      if (icr(nc).eq.o'143') call char2hol('ic',mdnam,1,2) !! "c"

      goto 900 

C  Handle VC's

170   continue

      if (icr(3).eq.o'40') then
        if ((icr(2).ge.o'61'.and.icr(2).le.o'71').or.(icr(2).ge.o'141'
     ..and.icr(2).le.o'146'))mdnam=lnam(1) 
        goto 900 
      endif
      nc=2
      if (icr(4).ne.o'40') nc=3 
      if (icr(nc).ne.o'143'.and.icr(nc).ne.o'60') goto 175
      if (icr(nc+1).lt.o'61'.or.icr(nc+1).gt.o'146'.or.(icr(nc+1).gt.
     .o'71'.and.icr(nc+1).lt.o'141')) goto 900 
        ic2=icr(nc+1) 
        goto 177 
175   if (icr(nc).ne.o'61'.or.icr(nc+1).lt.o'60'.or.icr(nc+1).gt.o'65')
     .   goto 900
        ic2=icr(nc+1) + o'61' 
177    call pchar(mdnam,1,icr(1))
       call pchar(mdnam,2,ic2)
       goto 900

180   continue

      if (ichcm_ch(lnam,1,'bbc').eq.0) then
c  must be a number 1 to f in 4
        if (icr(4).lt.o'61'.or.icr(4).gt.o'146'.or.(icr(4).gt.
     .      o'71'.and.icr(4).lt.o'141')) goto 900 
          call pchar(mdnam,1,icr(1))
          call pchar(mdnam,2,icr(4))
          goto 900 
C
      else if (ichcm_ch(lnam,1,'bc').eq.0) then
C           u or l in 4 and 3 has 1 to f
        if ((icr(4).eq.o'165').or.(icr(4).eq.o'154')) then
          if (icr(3).ge.o'61'.and.icr(3).le.o'71'.or.(icr(3).le.
     .      o'146'.and.icr(3).ge.o'141')) then
            call pchar(mdnam,1,icr(3))
            call pchar(mdnam,2,icr(4))
            goto 900
          endif
C          a 1 in 3 and 4 has 0 to 5
        else if (((icr(4).ge.o'60').or.(icr(4).le.o'65')).and.
     .    (icr(3).eq.o'61')) then
          ic2=icr(4) + o'61' 
          call pchar(mdnam,1,icr(1))
          call pchar(mdnam,2,ic2)
          goto 900
C          a blank in 4 and 3 has 1 to f 
        else if (icr(4).eq.o'40') then
          if (icr(3).ge.o'61'.and.icr(3).le.o'71'.or.(icr(3).le.
     .      o'146'.and.icr(3).ge.o'141')) then
            call pchar(mdnam,1,icr(1))
            call pchar(mdnam,2,icr(3))
            goto 900
          endif
        else
          goto 900
        endif
C
      else
C  if u or l in 3 2 has to be 1 to f
        if ((icr(3).eq.o'165').or.(icr(3).eq.o'154')) then
          if (icr(2).ge.o'61'.and.icr(2).le.o'71'.or.(icr(2).le.
     .      o'146'.and.icr(2).ge.o'141')) then
            call pchar(mdnam,1,icr(2))
            call pchar(mdnam,2,icr(3))
            goto 900
          else
            goto 900
          endif
C          a 1 in 2 and 3 has 0 to 5
        else if (((icr(3).ge.o'60'.or.icr(3).le.o'65')).and.
     .    (icr(2).eq.o'61')) then
          ic2=icr(3) + o'61' 
          call pchar(mdnam,1,icr(1))
          call pchar(mdnam,2,ic2)
          goto 900
C          a blank in 3 and 2 has 1 to f 
        else if (icr(3).eq.o'40') then
          if (icr(2).ge.o'61'.and.icr(2).le.o'71'.or.(icr(2).le.
     .      o'146'.and.icr(2).ge.o'141')) then
            call pchar(mdnam,1,icr(1))
            call pchar(mdnam,2,icr(2))
            goto 900
          endif
        else
          goto 900
        endif
      endif

      goto 900

C  Check for recorder

190   continue
      if (ichcm(lnam,1,4Hrc  ,1,4).eq.0.or.ichcm(lnam,1,4Hrec ,1,4)
     .   .eq.0) call char2hol('rc',mdnam,1,2)
      goto 900 

C  Return to calling routine

900   continue
      return
      end 
