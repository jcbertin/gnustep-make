#! /bin/sh
#
#   fixpath.sh
#
#   Script for converting between windows and unix-style paths.
#
#   Copyright (C) 2001,2002 Free Software Foundation, Inc.
#
#   Author:  Stephen Brandon <stephen@brandonitconsulting.co.uk>
#   Modified by:  Richard Frith-Macdonald <rfm@gnu.org>
#
#   This file is part of the GNUstep Makefile Package.
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License
#   as published by the Free Software Foundation; either version 2
#   of the License, or (at your option) any later version.
#   
#   You should have received a copy of the GNU General Public
#   License along with this library; see the file COPYING.LIB.
#   If not, write to the Free Software Foundation,
#   59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#

if [ ! $# -eq 2 ]; then
  quit="yes"
fi

test "$1" = '-u' || test "$1" = '-w' || quit="yes"


if [ "$quit" = "yes" ]; then
  echo "Usage: $0 (-u)|(-w) filename"
  echo "Options:"
  echo "   -u print Unix form of filename"
  echo "   -w print Windows form of filename"
  exit 1
fi

operation=$1
file=$2

# convert to Unix style file name
if [ "$operation" = "-u" ]; then
  file=`echo "$file" | tr '\\\' '/'`
  if [ "$GNUSTEP_HOST_OS" = "cygwin" ]; then
    echo $file | sed 's/^\([a-zA-Z]\):\(.*\)$/\/cygdrive\/\1\2/'
  else
    echo $file | sed 's/^\([a-zA-Z]\):\(.*\)$/\/\1\2/'
  fi
  exit 0
fi

# convert to Windows style file name
if [ "$GNUSTEP_HOST_OS" = "cygwin" ]; then
  file=`echo $file | sed 's/^\(\/cygdrive\)\?\/\([a-zA-Z]\)\(\/.*\)$/\2:\3/'`
else
  file=`echo $file | sed 's/^\(\/\)\?\/\([a-zA-Z]\)\(\/.*\)$/\2:\3/'`
fi
file=`echo "$file" | tr '/' '\\\'`
echo $file


