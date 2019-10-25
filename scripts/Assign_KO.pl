#!/usr/bin/perl

use strict;

my $koMapFile = "/home/ubuntu/Databases/keggs_database/KeggUpdate/genes/ko/ko_genes.list";

my %hashGeneKo = {};

open(KFILE,$koMapFile) or die "Can't open $koMapFile\n";

while(my $line = <KFILE>){
    chomp($line);

    my @tokens = split(/\t/,$line);
    
    $hashGeneKo{$tokens[1]} = $tokens[0];
}

close(KFILE);


my $minEvalue = -10.0;
my $maxDelta = 1000.0;
my $minHits = 1;

my %hashBest = {};
my %hashHits = {};

while(my $line = <STDIN>){
    chomp($line);
    
    if($line =~ /^\#.*/){
    #    print "$line\n";
    }
    else{    
        my @tokens = split(/\t/,$line);

        # Fields: Query Subject identity    aln-len mismatch    gap-openings    q.start q.end   s.start s.end   log(e-value)    bit-score
        # contig-1366000076_1   gme:Gmet_2972   79.4872 78  16  0   6   83  5   82  -28.82  132.49
        
        my $query = $tokens[0];
        my $subject = $tokens[1];

        my $logevalue = $tokens[10];

        if($hashBest{$query} > $logevalue){
            $hashBest{$query} = $logevalue;
        }
        if($query eq "contig-114791000065_6"){
            #print "$query $logevalue $hashBest{$query}\n";
        }
        if($logevalue - $hashBest{$query} < $maxDelta){
            if($query eq "contig-114791000065_6"){
             #   print "$query $logevalue $hashBest{$query}\n";
            }
    
            if($hashHits{$query} eq undef){
                my @temp = ();
                $hashHits{$query} = \@temp;
            }
            push(@{$hashHits{$query}},$subject);            
            #print "$query $subject $logevalue\n";
        }

    }
}

foreach my $qquery (sort keys %hashHits){

    if($hashHits{$qquery} ne undef){
        my @hits = @{$hashHits{$qquery}};
        my %kohits = {};
        foreach my $hhit(@hits){
            my $kohit = $hashGeneKo{$hhit};
            if($kohit ne ""){
                $kohits{$hashGeneKo{$hhit}}++;
            }
        } 
        my @ssorted = sort {$kohits{$b} <=> $kohits{$a}} keys %kohits;
        my $kkohit = $ssorted[0];
        if($kohits{$kkohit} >= $minHits){
            print "$qquery $kkohit $kohits{$kkohit}\n";
        }

    }
}
