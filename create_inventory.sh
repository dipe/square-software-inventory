#!/bin/sh

find / -xdev -type d -name "*.app" -o -type f -perm +111 -print0 | (xargs -0 codesign -dv --continue 2>&1) | perl -ne 'BEGIN { print "Executable,TeamIdentifier\n"; } if (/^Executable=(.*)/) { $exec = $1; } elsif (/^TeamIdentifier=(.*)/) { $ti = $1; print "\"$exec\",\"$ti\"\n"; }' >Executables_with_teamIdentifier.csv
perl -F',' -ane 'next if $. == 1; $seen{$F[1]}++ or print "$F[1]\n"' <Executables_with_teamIdentifier.csv >teamIdentifier.csv 
