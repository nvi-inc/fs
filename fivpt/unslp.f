      subroutine unslp(tmplin,timlin,temp,tim,npts,slope,const) 
      dimension tmplin(2),timlin(2),temp(npts),tim(npts)
C 
C   REMOVE A LINEAR SLOPE AND A CONSTANT, DETERMINED FROM TMPLIN, 
C       FROM THE DATA IN TEMP 
C 
C  INPUT: 
C 
C      TMPLIN - ARRAY HOLDING THE TEMPERATURE DRIFT INFORMATION 
C 
C      TIMLIN - THE TIME COORDIANTE OF THE TMPLIN DATA
C 
C      TEMP   - THE DATA TO BE CORRECTED
C 
C      TIM    - THE TIME COORDINATE OF THE DATA 
C 
C      NPTS   - NUMBER OF POINTS IN TEMP AND TIM
C 
      slope=(tmplin(2)-tmplin(1))/(timlin(2)-timlin(1)) 
      tmid=tim((npts+1)/2)
      const=tmplin(1)+slope*(tmid-timlin(1))
      do i=1,npts
        temp(i)=temp(i)-((tim(i)-tmid)*slope+const)  
      enddo

      return
      end 
