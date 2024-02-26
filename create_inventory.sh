#!/bin/bash

echo -e "Working...\nThis can take between 3 and 30 minutes. Please be patient."

TEMP=`basename -s .sh $0`
DIRNAME=`hostname`
TEMPDIR=`mktemp -d /tmp/${TEMP}-XXXXXX` || exit 1
cd $TEMPDIR
mkdir ${DIRNAME}
cd ${DIRNAME}

find / \( -xdev -type d -name "*.app" -o -type f -perm +111 -print0 \) -o \( \( -path "/System" -o -path "/Volumes" \) -prune \) 2>create_inventory.log \
    | xargs -0 codesign -dvv --continue 2>&1 \
    | perl -ne '
        our %vanilla_mac_book;

        BEGIN { 
            my $url = "https://raw.githubusercontent.com/dipe/square-software-inventory/main/vanilla_mac_book.txt";
            my $vanilla_mac_book_txt = `curl -s $url`;
            unless ($? == 0) {
                    die "Error when retrieving the URL: $url\n";
            }

            my @vanilla_mac_book_lines = split /\n/, $vanilla_mac_book_txt;
            foreach my $path (@vanilla_mac_book_lines) {
                chomp $path;
                $vanilla_mac_book{$path} = 1;
            }

            print "Type,App Name,Publisher Details\n"; 
        } 

        /^Executable=(.*)/ and do { 
            print "$type,$exec,\"" . join(";", @auths) . "\"\n" if $exec && !exists $vanilla_mac_book{$exec}; 
            $exec = $1; @auths = (); $type = ""; next; 
        }; 
        /^Authority=(.*)/ and do { 
            (my $auth = $1) =~ s/,/./g; # Ersetzt alle Kommas durch Punkte
            push @auths, $auth; 
            next; 
        }; 
        /Format=bundle/ and do { 
            $type="Bundle";
        }; 
        /Format=app bundle/ and do { 
            $type="Bundle";
        }; 
        /Format=Mach-O/ and do { 
            $type="Binary";
        }; 
        /Format=generic/ and do { 
            $type="Generic";
        }; 
        END { 
            print "$type,$exec,\"" . join(";", @auths) . "\"\n" if $exec && !exists $vanilla_mac_book{$exec}; 
        }
    ' >square_tisax_inventory.csv

cd ..

echo -e "\nCreating zip archive:"
ZIPFILE=${DIRNAME}.zip 
zip -r ${ZIPFILE} ${DIRNAME}
mv ${ZIPFILE} ~/.
echo -e "done.\n"

echo "You will now find a file named ${ZIPFILE} in your user directory ${USER}."
