      subroutine lxhlp

      character*79 outbuf

      outbuf=' '
      outbuf(29:)='general commands'
      call po_put_c(outbuf)
      outbuf='<command>'
      outbuf(42:)='displays current values'
      call po_put_c(outbuf)
      outbuf='cfile=<path>'
      outbuf(42:)='file that contains logex commands'
      call po_put_c(outbuf)
      outbuf='list=<start>,<stop> or #<lines>'
      outbuf(42:)='lists selected entries on lu'
      call po_put_c(outbuf)
      outbuf='log=<log name>'
      outbuf(42:)='opens log file <log name>'
      call po_put_c(outbuf)
      outbuf='output=<lu> or <file name>'
      outbuf(42:)='output for lu or output file'
      call po_put_c(outbuf)
      outbuf='sked=<file name>,<start>,<stop>'
      outbuf(42:)='opens schedule file <filename>'
      call po_put_c(outbuf)
      outbuf='summary=<start>,<stop> or #<lines>'
      outbuf(42:)='summary of observations'
      call po_put_c(outbuf)
      outbuf='sksummary'
      outbuf(42:)='compares summary with schedule file'
      call po_put_c(outbuf)
      outbuf='ex or ::'
      outbuf(42:)='ends a logex session'
      call po_put_c(outbuf)
C
      outbuf=' '
      outbuf(29:)='plotting commands'
      call po_put_c(outbuf)
      outbuf='parm=<n1>,...<n5>'
      outbuf(42:)='specifies parms for plotting.'
      call po_put_c(outbuf)
      outbuf='scale=<min>,<max>,<n>,<db>,<delta>'
      outbuf(42:)='sets scale for plots.'
      call po_put_c(outbuf)
      outbuf='size=<width>,<height>'
      outbuf(42:)='plot width in chars, height in lines.'
      call po_put_c(outbuf)
      outbuf='tplot=<start>,<stop> or #<lines>'
      outbuf(42:)='plots in a strip chart format'
      call po_put_c(outbuf)
      outbuf='plot=<start>,<stop> or #<lines>'
      outbuf(42:)='single-screen plot.'
      call po_put_c(outbuf)
      outbuf=' '
      outbuf(29:)='selection commands'
      call po_put_c(outbuf)
C
      outbuf='command=<name 1>,...<name 5>'
      outbuf(42:)='search for up to five command names'
      call po_put_c(outbuf)
      outbuf='string=<name1>,...<name5>'
      outbuf(42:)='scans for up to five strings'
      call po_put_c(outbuf)
      outbuf='type=<char1>,...<char5>'
      outbuf(42:)='scans for up to five types of entries.'
      call po_put_c(outbuf)
C
      return
      end
