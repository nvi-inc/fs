C@PID_STR

      subroutine pid_str (cpid,pid)      

C Pid_str constructs a character string from the given process 
C ID number.
C
C -P. Ryan

      integer     pid,i,j,k
      character*(*) cpid 

C get character string from integer

      k = pid
      do i=5,1,-1
        j = (k - ((k/10)*10))
        write (cpid(i:i),1000) j
        k = k/10
      end do
1000  format (i1)

      return
      end

