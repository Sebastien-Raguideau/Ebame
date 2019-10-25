#!/usr/bin/perl

use strict;
my $path = $ARGV[0];

my @files = glob("${path}/*_ko_cov.csv");
my %hashContigs = {};
my @names = ();
for my $file (@files){
    my $name;
    if($file=~/$path\/(.*)_ko_cov.csv/){
        $name = $1;
    }
    push(@names,$name);
    open(FILE,$file) or die "Can't open $file\n";

    while(my $line = <FILE>){
        chomp($line);
	$line =~ s/^\s+//;    
        my @tokens = split(/,/,$line);
        $hashContigs{$tokens[0]}{$name} += $tokens[1];         
    }
    close(FILE);
} 


my $cName = join(",",@names);
print "KO,$cName\n";
#ko:K01488
for my $contig(sort {$a=~/.*K(\d+)/; my $a1 = $1; $b=~/.*K(\d+)/; my $b1 = $1; $a1 <=> $b1;} keys %hashContigs){
    if($contig ne "genome"){
        if($hashContigs{$contig} ne undef){
        my @vals = ();
        foreach my $name(@names){
            my $val = 0.0;
        
            if($hashContigs{$contig}{$name} ne undef){
                   $val = $hashContigs{$contig}{$name};

            }
            push(@vals,$val);
        }        
        my $sum = 0.0;
        foreach my $v(@vals){
            $sum += $v;
        }
        if($sum > 0.0){
            my $vstring = join(",",@vals);
            print "$contig,$vstring\n";
        }
    }
}
}
