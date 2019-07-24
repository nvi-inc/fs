      function igtcm(ifc,iec)
C 
C IGTCM - Returns Command number after checking name in IBUF
C 
C MODIFICATIONS:  
C 
C     DATE     WHO  DESCRIPTION 
C 
C     820416   KNM  THE OUTPUT COMMAND REPLACED THE LU COMMAND. THE 
C                   USER MAY NOW SPECIFY AN OUTPUT FILE OR ANY LOGICAL
C                   UNIT FOR LOGEX OUTPUT.
C 
C     820421   KNM  THE SKSUMMARY WAS ADDED.
C 
C     820519   KNM  THE OLD PLOT COMMAND WAS CHANGED TO TPLOT 
C                   (STILL IKEY=6) AND THE NEW PLOT COMMAND (PLOT)
C                   WAS ADDED (IKEY=13).
C 
C     820825   KNM  SKED COMMAND WAS ADDED AS A VALID COMMAND 
C 
C     820909   KNM  CFILE COMMAND WAS ADDED AS A VALID COMMAND
C 
C     820922   KNM  IGTCM WAS REWRITTEN TO TEST FOR AMBIGUOUS 
C                   COMMANDS INPUT FROM THE USER FOR MINIMUM
C                   MATCHING. 
C 
C  INPUT VARIABLES: 
C 
C     IFC - first char to use in IBUF 
C     IEC - last char to use in IBUF
C 
C 
C  OUTPUT VARIABLES:
C 
C     IGTCM - command number, as found in LKEYNM
C 
C  LOCAL VARIABLES: 
C 
      character cjchar
      integer*2 lkeynm(48)
C     - key words which are recognized
C 
C     ICOMN - Contains the command number count 
C     IFCMD - Flag which indicates whether first match has  
C             been encountered. 
C     IKEYWD - Number of words in LKEYNM.  This Constant must 
C              be increased if any new commands are added.
C 
C  COMMON BLOCKS USED:
C 
      include 'lxcom.i'
C 
C 
C  INITIALIZED VARIABLES: 
C 
C  ******IMPORTANT!!!****** 
C 
C  One blank must always precede the beginning of a command word, even
C  the first command in LKEYNM!!
C 
      data lkeynm /2h O,2hUT,2hPU,2hT ,2hCO,2hMM,2hAN,2HD ,2hLO,2hG , 
     /             2hLI,2hST,2h ?,2h? ,2hTP,2hLO,2hT ,2hPA,2hRM,2h S, 
     .             2hCA,2hLE,2h S,2hUM,2hMA,2hRY,2h S,2hTR,2hIN,2hG , 
     .             2hTY,2hPE,2h S,2hKS,2hUM,2hMA,2hRY,2h P,2hLO,2hT ,   
     .             2hSK,2hED,2h C,2hFI,2hLE,2h S,2hIZ,2hE / 
C 
      data ikeywd/48/ 
C 
C 
C ************************************************************
C 
C 1. Scan for a comparision of strings in LKEYNM and in IBUF. 
C 
C ************************************************************
C 
C 
      ic1 = 1 
      ifcmd=0 
      nch = iec-ifc+1 
100   ich = iscns(lkeynm,ic1,ikeywd*2,ibuf,ifc,nch) 
      if (ich.gt.0) goto 200 
      if (ifcmd.eq.1) goto 300 
      icomn=0   
      goto 400
C 
C 
C ************************************************************
C 
C 2. Some match was found. Check to see if it starts at the 
C    beginning of a word in LKEYNM. 
C 
C **********************************************************
C 
C 
200   if (cjchar(lkeynm,ich-1).eq.' ') goto 210   
      ic1=ich+1 
      goto 100
210   ich1=ich
      ic1=ich+1 
      ifcmd=ifcmd+1 
      if (ifcmd.gt.1) icomn=-1 
      if (ifcmd.le.1) goto 100 
      goto 400
C 
C 
C ************************************************************
C 
C 3. Count the number of blanks to determine the Command #
C 
C ************************************************************
C 
C 
300   ic2=1 
      icomn=0 
310   ic3=iscn_ch(lkeynm,ic2,ikeywd*2,' ')
      if (ic3.eq.0) goto 400 
      icomn=icomn+1 
      if (ic3+1.eq.ich1) goto 400  
      ic2=ic3+1 
      goto 310
C 
C 
C ************************************************************
C 
C 4. Store the command number and return. 
C 
C ************************************************************
C 
C 
400   igtcm = icomn 
C
      return
      end 
