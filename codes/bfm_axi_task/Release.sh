#!/bin/bash -f
#------------------------------------------------------
# Copyright (c) 2009-2011-2016-2017 by Ando Ki
#------------------------------------------------------
# VERSION: 2017.01.22.
#------------------------------------------------------
# verbose: verbose mode when 1
# OPT    : options (-h -? -v -f x -d y )
# DST    : dstination directory name
# FILES  : file name - containing files to be archieved
#                      one line for each file 
# EXCLU  : file name - containing files not to be archieved
#                      one line for each file 
# DIRS   : file name - containing directory to be archieved
#                      one line for each directory
#------------------------------------------------------

SHELL=/bin/sh
verbose=0
OPT=
DST=
FILES=".Release_file.txt"
EXCLU=".Release_excl.txt"
DIRS=".Release_dir.txt"

#------------------------------------------------------
help() {
   echo "Usage : $0 [options] dest_dir"
   echo "            -d  dir_list_file  (default: -d ${DIRS})"
   echo "            -e  file_list_file (default: -e ${EXCLU})"
   echo "            -f  file_list_file (default: -f ${FILES})"
   echo "            -h/-?    printf help"
   echo "            -v       verbose mode on"
}

#------------------------------------------------------
if [ $# -eq 0 ]; then
   help
   exit -1
fi

while [ "`echo $1|cut -c1`" = "-" ]; do
   case $1 in
      -d) shift
            if [ ! "$1" ]; then
               echo "-d need file name"
               help
               exit -1
            fi
            DIRS=$1
            ;;
      -e) shift
            if [ ! "$1" ]; then
               echo "-e need file name"
               help
               exit -1
            fi
            EXCLU=$1
            ;;
      -f) shift
            if [ ! "$1" ]; then
               echo "-f need file name"
               help
               exit -1
            fi
            FILES=$1
            ;;
      -h|-\?) help
              exit -1
              ;;
      -v)   verbose=1
            OPT="${OPT} $1"
            ;;
      *)
            echo "Unknown option: $1"
            help
            exit -1
            ;;
   esac
   shift
done

#------------------------------------------------------
# Check destination
if [ ! "$1" ]; then
   echo "Destination should be specified"
   help
   exit -1
fi

if [ ! -d $1 ]; then
   mkdir -p $1 || exit 1
   if [ $verbose -eq 1 ]; then
      echo "\"$1\" created"
   fi
else
   if [ $verbose -eq 1 ]; then
      echo "\"$1\" exists"
   fi
fi

CWD=`pwd`
cd $1; DST=`pwd`
cd ${CWD}

#------------------------------------------------------
if [ -f ${FILES} ]; then
   #dos2unix ${FILES} 2>&1 > /dev/null
   #tr -d '\r' < ${FILES} > ${FILES}.x
   /bin/cat ${FILES} | tr -d '\r' | sed 's/#.*$//g' | tr -d " \t" | sed '/^ *$/d' > ${FILES}.x
   if [ -f ${EXCLU} ]; then
      #dos2unix ${EXCLU} 2>&1 > /dev/null
      #tr -d '\r' < ${EXCLU} > ${EXCLU}.x
      /bin/cat ${EXCLU} | tr -d '\r' | sed 's/#.*$//g' | tr -d " \t" | sed '/^ *$/d' > ${EXCLU}.x
      if [ $verbose -eq 1 ]; then
           echo "tar cf - -X ${EXCLU}.x -T ${FILES}.x | (cd ${DST}; tar xvf -)"
           tar cf - -X ${EXCLU}.x -T ${FILES}.x | (cd ${DST}; tar xvf -)
           if [ ${PIPESTATUS[0]} -ne 0 ]; then echo tar error at `pwd`.; exit -2; fi
      else
           tar cf - -X ${EXCLU}.x -T ${FILES}.x | (cd ${DST}; tar xf -)
           if [ ${PIPESTATUS[0]} -ne 0 ]; then echo tar error at `pwd`.; exit -2; fi
      fi
      /bin/rm -f ${EXCLU}.x
   else
      if [ $verbose -eq 1 ]; then
           echo "tar cf - -T ${FILES}.x | (cd ${DST}; tar xvf -)"
           tar cf - -T ${FILES}.x | (cd ${DST}; tar xvf -)
           if [ ${PIPESTATUS[0]} -ne 0 ]; then echo tar error at `pwd`.; exit -2; fi
      else
           tar cf - -T ${FILES}.x | (cd ${DST}; tar xf -)
           if [ ${PIPESTATUS[0]} -ne 0 ]; then echo tar error at `pwd`.; exit -2; fi
      fi
   fi
   /bin/rm -f ${FILES}.x
fi

#------------------------------------------------------
if [ -f ${DIRS} ]; then
   #dos2unix ${DIRS} 2>&1 > /dev/null
   #tr -d '\r' < ${DIRS} > ${DIRS}.x
   /bin/cat ${DIRS} | tr -d '\r' | sed 's/#.*$//g' | tr -d " \t" | sed '/^ *$/d' > ${DIRS}.x
   for D in `cat ${DIRS}.x`; do
       if [ -f ${D}/Release.sh ]; then
            if [ $verbose -eq 1 ]; then
                 echo "cd ${D}; ./Release.sh ${OPT} ${DST}/${D}"
            fi;
            ( cd ${D}; ${SHELL} Release.sh ${OPT} ${DST}/${D} );
       fi
   done
   /bin/rm -f ${DIRS}.x
fi

#------------------------------------------------------
# Revision history:
#
# Jan. 22, 2017: error code checking for tar added.
# Nov.  3, 2016: comment feature added, (comment: # to the end of line)
# Feb. 22, 2011: 'tr' added in order to handle CRLF line termination
# Jan. 26, 2010: 'SHELL' added
# Oct. 26, 2009: '-p' added for 'mkdir'
# June 05, 2009: Started by Ando Ki (adki@dynalith.com)
#------------------------------------------------------
