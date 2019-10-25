#!/usr/bin/perl

use strict;

my $bFirst = 1;
while(my $line = <STDIN>){
    chomp($line);

    if ($bFirst == 0){
        my @tokens = split(/\t/,$line);
        

        my @split1 = split(/\|/,shift(@tokens));

#        print "@split1\n";

        if (scalar(@split1) == 7){
            my $tString = join("\t",@tokens);
            print "$split1[-1]\t$tString\n";
#       print "$line\n";
        }
        
    }
    else{
        print "$line\n";
        $bFirst = 0;
    }
}

