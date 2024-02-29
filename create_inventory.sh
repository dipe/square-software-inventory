#!/bin/bash

SECONDS=0

echo -e "Working...\nThis can take between 3 and 90 minutes. Please be patient and don't close this window."
echo "You don't have to wait. You can continue your work and switch back here later."

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

            binmode(STDOUT, ":encoding(UTF-8)");
            print "\"Type\";\"Publisher Details\";\"TeamIdentifier\";\"Guessed App Name\";\"Path\"\n";
        } 
        /^Executable=(.*)/ and do { 
            if ($exec) {
                my $appName = "";
                if ($exec =~ /\/([^\/]+)\.app/) {
                    $appName = $1;  # Extrahiert den Namen der Anwendung
                }else{
                    $appName = "? check path";
                }
                my $authority_to_print = $devIdApp ? $devIdApp : join(";", @auths);
                print "\"$type\";\"$authority_to_print\";\"$team\";\"$appName\";\"$exec\"\n" if $exec && !exists $vanilla_mac_book{$exec} && $team ne "not set"; 
            }
           $exec = $1; @auths = (); $type = ""; $devIdApp = ""; $team = ""; next; 
        }; 
        /^Authority=Developer ID Application: (.*)/ and do {
            $devIdApp = $1 unless $devIdApp; 
        };
        /^Authority=(.*)/ and do {
            (my $auth = $1) =~ s/,/./g;
            push @auths, $auth unless $devIdApp;
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
        /^TeamIdentifier=(.*)/ and do {
            $team = $1;
        };
        END { 
            my $appName = ""; 
            if ($exec =~ /\/([^\/]+)\.app/) {
                $appName = $1;  # Extrahiert den Namen der Anwendung
            }else{
                $appName = "? check path";
            }
            my $authority_to_print = $devIdApp ? $devIdApp : join(";", @auths);
            print "\"$type\";\"$authority_to_print\";\"$team\";\"$appName\";\"$exec\"\n" if $exec && !exists $vanilla_mac_book{$exec} && $team ne "not set"; 
        }
    ' >square_tisax_inventory.csv

cd ..

echo -e "\nCreating zip archive:"
ZIPFILE=${DIRNAME}.zip 
zip -r ${ZIPFILE} ${DIRNAME}
mv ${ZIPFILE} ~/.
rm -r ${TEMPDIR}
echo -e "done.\n"
echo "The execution of the script took $SECONDS seconds."
echo "You will now find a file named ${ZIPFILE} in your user directory ${USER}."