!***********************************************************************
      subroutine SplitNTokens(ldum,ltokens,MaxToken,NumGot)
      implicit none
      charactER*(*) ldum
      integer MaxToken,NumGot
      character*(*) ltokens(MaxToken)

      logical ktoken     !got token
      logical knospace   !no more space
      logical keol       !eol.
      integer istart,inext,itoken

      istart=1
      do itoken=1,MaxToken
        call ExtractNextToken(ldum,istart,inext,ltokens(itoken),ktoken,
     >   knospace, keol)
         if(.not.ktoken) then
            NumGot=itoken-1
            return
         endif
        istart=inext
      end do
      NumGot=MaxToken

      return
      end

