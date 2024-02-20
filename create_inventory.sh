#!/bin/bash
find / -xdev -type d -name "*.app" -o -type f -perm +111 -print0 2>create_inventory.log \
    | xargs -0 codesign -dvv --continue 2>&1 \
    | perl -ne '
        BEGIN { print "Executable,Authority,teamIdentifier\n"; } 
        /^Executable=(.*)/ and do { 
            print "$exec,\"" . join(";", @auths) . "\", $team\n" if $exec; 
            $exec = $1; @auths = (); $team = ""; next; 
        }; 
        /^Authority=(.*)/ and do { 
            (my $auth = $1) =~ s/,/./g; # Ersetzt alle Kommas durch Punkte
            push @auths, $auth; 
            next; 
        }; 
        /TeamIdentifier=(.*)/ and do { 
            $team=$1; 
        }; 
        END { 
            print "$exec,\"" . join(";", @auths) . "\", $team\n" if $exec; 
        }' \
        > Executables_with_teamIdentifier.csv
perl -F',' -ane 'next if $. == 1; $F[1] =~ s/\R//g; $seen{$F[1]}++ or print "$F[1]\n"' \
    <Executables_with_teamIdentifier.csv \
    >Authority.csv
perl -F',' -ane 'next if $. == 1; $F[2] =~ s/\R//g; $seen{$F[2]}++ or print "$F[2]\n"' \
    <Executables_with_teamIdentifier.csv \
    >teamIdentifier.csv
