
                            README_nng.make

Because we are using the NNG library on older Linux platforms than the required
CMake version supports, we have to generate a fixed baked in Makefile to match
the oldest platform we intend to support.

This generation is done in the FS third_party/src directory by running on a
Debian 5 'lenny' platform (with CMake >= 3.8 - see CMAKE VERSIONS below):

	./gen_nng.make 1.3.0

where 1.3.0 is the NNG version for which one is generating the Makefile.  This
generates a new 'nng.make' file based on 'nng.make.template' by filling the
source and header file names, compiler flags and C pre-processor defines as
gleaned by running CMake on the NNG source tree.

The internal process it uses is as follows:

1. Unpack the original source tarball nng-<VERSION>.tar.gz.

2. Patch nng-<VERSION>/CMakeLists.txt to downgrade the  minimum required CMake
   version from 3.13 to 3.6 (as the former will not compile on Debian 5) and to
   comment out the test related to libatomic which does not yet exist in this
   distribution.

NOTE:  This patch is the most likely point of breakage going forward as NNG's
       use of CMake evolves. As things stand CMake 3.6 is capable of handling
       enough of 3.13's features that the library is effectively unaffected
       but that will eventually change.

3. Make a "build" directory for within which 'cmake ../nng-<VERSION>' is run,
   generating an out-of-tree build infrastructure.

4. Lift the names of the source files that need to be compiled from

		build/src/CMakeFiles/nng.dir/build.make

   the names of the header files from a recursive search of the 

                nng-<VERSION>/include

   directory and the compiler flags, Cpp defines and include dirs from

		build/src/CMakeFiles/nng.dir/flags.make

5. Convert the absolute include directory paths to relative ones suitable for
   inclusion in nng.make.

6. Insert the above values into the 'nng.make.template' to create 'nng.make'

7. Clean up the ephemeral "nng-<VERSION>" and "build" directories then exit.


CMAKE VERSIONS

Not all CMake version are created equal and hence projects making use of it
specify what is the minimum version of CMake that contains all the features
needed.  For nng-1.0.1 CMake>=3.1 was required whilst nng-1.3.0 now requires
CMake>=3.13.  However it seems that it is possible to use a much older version
by dropping a feature that just happens to be unnecessary on x86 machines.

Fortunately CMake is also easy to build from scratch and compatibility depends
mainly on the capabilities of the available compilers, so backporting of newer
versions into older distributions is possible to some extent.
For reference:

	Debian 5 'lenny'   (FSL8)  has cmake-2.6.0 but will build up to 3.8.2,
	Debian 7 'wheezy'  (FSL9)  has cmake-2.8.9 but will build up to 3.9.6,
	Debian 9 'stretch' (FSL10) has cmake-3.7.2 but will build up to 3.15.7

and only the current stable Debian 10 actually has the requisite >=3.13.

Static stand-alone pre-compiled versions of CMake are available up to 3.6.3
in the Linux i386 (32-bit) ELF binary format and from 3.1.0 onwards in the
equivalent x86_64 (64-bit) format.
