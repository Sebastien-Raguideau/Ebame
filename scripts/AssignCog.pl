#!/usr/bin/perl

use strict;

my $maxEValue = 1.0e-10;
my $cogFile = $ARGV[0];

open(COGFILE, $cogFile) or die "Can't open $cogFile\n";

my %hashCog = ();

while(my $line = <COGFILE>){
    chomp($line);

    my @tokens = split(/\t/,$line);

    #407693549,Actinobacillus_suis_H91_0380_uid176363,407693549,426,1,426,COG0001,0,
#    print "$tokens[0],$tokens[1]\n";
    $hashCog{$tokens[0]} = $tokens[1];
}

my %assignRead = ();
while(my $line = <STDIN>){
    chomp($line);

    my @tokens = split(/\t/,$line);
	#k141_8831_1	gnl|CDD|223808	5.94e-07	20.339	106	32	146	280	391	118	517
    #gnl|CDD|225117
    #gi|332285559|ref|YP_004417470.1|
    #NZ_CP009526.1-2690/1    gi|296139022|ref|YP_003646265.1|        48.8    43      22      0       16      144     132     174     8.8e-04 45.1
    if ($tokens[1]=~/gnl\|CDD\|(\d+)/){
        my $cog = $hashCog{$1};
        my $read = $tokens[0];
#	print "$cog\n";        

        if ($tokens[2] < $maxEValue){
            if($assignRead{$read} == undef){
                my @temp = ($cog);
                $assignRead{$read} = \@temp;
            }
            else{
                push(@{$assignRead{$read}},$cog);
            }
        }

        #print "$cog\n";
    }    
}

foreach my $read (keys %assignRead){
    my @assigns = @{$assignRead{$read}};
    my $total = 0;
    my %f;
    for (@assigns) {
        $f{$_}++;
        $total += 1;
    }

    my $maxAssign = (sort {$f{$a} <=> $f{$b}} keys %f)[0];

    print "$read\t$maxAssign\t$f{$maxAssign}\t$total\n";
}
