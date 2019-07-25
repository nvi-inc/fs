      integer*2 function mdnam(lnam,ifc,ilc)

C   parse module names c#870407:13:00# 
C 
C     MDNAM parses module names entered as parameters in SNAP commands, 
C     outputting the appropriate 2-character mnemonic.
C 
C  INPUT: 
C 
      integer*2 lnam(1) 
C          - module name to be parsed 
      integer ifc,ilc
C          - ifc  first character position
C          - ilc  last character position
C 
C  OUTPUT:
C 
C     MDNAM - 2-character mnemonic for module name
C 
C  LOCAL VARIABLES: 
C 
      character*80 cicr
      character    cic2
      integer*2  ic2
C     NC - character position in LNAM 
C     IC2 - 2nd character of mnemonic 
C 
C  CONSTANTS: 
      character*9 cistcr
C 
      data cistcr /'aoeftivbr'/
C          - legal decimal values for 1st character of module name
C 
C  DATE  WHO  CHANGES 
C 840308 MWH  Created 
C 
C 
C  Initialize and transfer control based on first character of module name
      mdnam=0 
      cicr = ' '
      call hol2char(lnam,ifc,ilc,cicr)

      do i=1,9
        if (cicr(1:1).eq.cistcr(i:i)) goto 105 
      enddo
      goto 900 
105   goto (110,120,130,140,150,160,170,180,190) i 

C  Handle ALL, ODD, EVEN

110   if (cicr.eq.'all') call char2hol('al',mdnam,1,2)
      goto 900 

120   if (cicr.eq.'odd') call char2hol('od',mdnam,1,2)
      goto 900 

130   if (cicr.eq.'even') call char2hol('ev',mdnam,1,2)
      goto 900 

C  Handle formatter or tape 

140   if ((cicr.eq.'fm').or.(cicr.eq.'form')) 
     .  call char2hol('fm',mdnam,1,2)
      goto 900 

150   if ((cicr.eq.'tp').or.(cicr.eq.'tape'))
     .  call char2hol('tp',mdnam,1,2)
      goto 900 

C  Handle IFD's 

160   continue

      nc=2
      if (cicr(nc:nc).ne.'f') goto 163
        nc=3
      if (cicr(nc:nc).ne.'d') goto 163
        nc=4
163   if (cicr(nc:nc).eq.'3') call char2hol('i3',mdnam,1,2)
      if (cicr(nc:nc).eq.' ') call char2hol('if',mdnam,1,2)

C  look for VLBA mnemonics

      nc=2
      if (cicr(nc:nc).ne.'f') goto 166
        nc=3
      if (cicr(nc:nc).ne.'d') goto 166
        nc=4
166   if (cicr(nc:nc).eq.'a') call char2hol('ia',mdnam,1,2)
      if (cicr(nc:nc).eq.'c') call char2hol('ic',mdnam,1,2)

      goto 900 

C  Handle VC's

170   continue

      if (cicr(3:3).eq.' ') then
        if ((cicr(2:2).ge.'1'.and.cicr(2:2).le.'9').or.(cicr(2:2).ge.'a'
     ..and.cicr(2:2).le.'f')) call ichmv(mdnam,1,lnam(1),1,2)
        goto 900 
      endif
      nc=2
      if (cicr(4:4).ne.' ') nc=3 
      if (cicr(nc:nc).ne.'c'.and.cicr(nc:nc).ne.'0') goto 175
C  IF NC=2 and 2 = C OR 0 THEN DO THE FOLLOWING
      if (cicr(nc+1:nc+1).lt.'1'.or.cicr(nc+1:nc+1).gt.'f'.or.
     .   (cicr(nc+1:nc+1).gt.'9' .and.cicr(nc+1:nc+1).lt.'a')) goto 900 
        cic2=cicr(nc+1:nc+1) 
        goto 177 
175   if (cicr(nc:nc).ne.'1'.or.cicr(nc+1:nc+1).lt.'0'.or.
     .    cicr(nc+1:nc+1).gt.'5') goto 900
        call char2hol(cicr(nc+1:nc+1),ic2,1,1)
        ic2=ic2+49   !! change the number to corresponing letter,
        call hol2char(ic2,1,1,cic2)
C                       i.e. 5 to f
177     call char2hol(cicr(1:1),mdnam,1,1)
        call char2hol(cic2,mdnam,2,2)
       goto 900

180   continue !!! BBC's

      if (cicr(1:3).eq.'bbc') then    !!! BBC
        if (cicr(4:4).eq.'0') then    !!! BBCnn
           if ((cicr(5:5).ge.'1').and.(cicr(5:5).le.'9').and.
     .         (cicr(6:6).eq.' ')) then
             call char2hol(cicr(1:1),mdnam,1,1)
             call char2hol(cicr(5:5),mdnam,2,2)
             goto 900
           else
             goto 900
           endif
        else if ((cicr(4:4).eq.'1').and.(cicr(5:5).ge.'0').and.
     .                                  (cicr(5:5).le.'5')) then
          call char2hol(cicr(5:5),ic2,1,1)
          ic2=ic2+49
          call hol2char(ic2,1,1,cic2)
          if (cicr(6:6).eq.' ') then
            call char2hol(cicr(1:1),mdnam,1,1)
            call char2hol(cic2,mdnam,2,2)
            goto 900
          else
            goto 900
          endif
        else if ((cicr(4:4).ge.'1').and.(cicr(4:4).le.'9').or.
     .           (cicr(4:4).ge.'a').and.(cicr(4:4).le.'f')) then
C   !!! BBCn
          if (cicr(5:5).eq.' ') then
            call char2hol(cicr(1:1),mdnam,1,1)
            call char2hol(cicr(4:4),mdnam,2,2)
            goto 900
          else
            goto 900
          endif
        endif
      else if (cicr(1:2).eq.'bc') then    !!! BC
        if (cicr(3:3).eq.'0') then    !!! BCnn
          if ((cicr(4:4).ge.'1').and.(cicr(4:4).le.'9')) then
            if (cicr(5:5).eq.' ') then
              call char2hol(cicr(1:1),mdnam,1,1)
              call char2hol(cicr(4:4),mdnam,2,2)
              goto 900
            else
              goto 900
            endif
          else
            goto 900
          endif
        else if ((cicr(3:3).eq.'1').and.((cicr(4:4).ge.'0').and.
     .                                   (cicr(4:4).le.'5'))) then
          call char2hol(cicr(4:4),ic2,1,1)
          ic2=ic2+49
          call hol2char(ic2,1,1,cic2)
          if (cicr(5:5).eq.' ') then
            call char2hol(cicr(1:1),mdnam,1,1)
            call char2hol(cic2,mdnam,2,2)
            goto 900
          else
            goto 900
          endif
        else if (((cicr(3:3).ge.'1').and.(cicr(3:3).le.'9')).or.
     .           ((cicr(3:3).ge.'a').and.(cicr(3:3).le.'f'))) then
C    !!! BCn
          if (cicr(4:4).eq.' ') then
            call char2hol(cicr(1:1),mdnam,1,1)
            call char2hol(cicr(3:3),mdnam,2,2)
            goto 900
          else
            goto 900
          endif
        else
          goto 900
        endif
      else if (cicr(1:1).eq.'b') then    !!! B
        if (cicr(2:2).eq.'0') then 
          if ((cicr(3:3).ge.'1').and.(cicr(3:3).le.'9').and.
     .        (cicr(4:4).eq.' ')) then
              call char2hol(cicr(1:1),mdnam,1,1)
              call char2hol(cicr(3:3),mdnam,2,2)
              goto 900
          else
            goto 900
          endif
        else if ((cicr(2:2).eq.'1').and.((cicr(3:3).ge.'0').and.
     .                                   (cicr(3:3).le.'5'))) then
          call char2hol(cicr(3:3),ic2,1,1)
          ic2=ic2+49
          call hol2char(ic2,1,1,cic2)
          if (cicr(4:4).eq.' ') then
            call char2hol(cicr(1:1),mdnam,1,1)
            call char2hol(cic2,mdnam,2,2)
            goto 900
          else
            goto 900
          endif
        else if (((cicr(2:2).ge.'1').and.(cicr(2:2).le.'9')).or.
     .           ((cicr(2:2).ge.'a').and.(cicr(2:2).le.'f'))) then
          if (cicr(3:3).eq.' ') then
            call char2hol(cicr(1:1),mdnam,1,1)
            call char2hol(cicr(2:2),mdnam,2,2)
            goto 900
          else
            goto 900
          endif
        else
          goto 900
        endif
      else
        goto 900
      endif

C  Check for recorder

190   continue
      if ((cicr.eq.'rc').or.(cicr.eq.'rec'))
     .  call char2hol('rc',mdnam,1,2)
      goto 900 

C  Return to calling routine

900   continue
      return
      end 
