#!/usr/bin/perl

my $scgFile = $ARGV[0];

my %hashSCGs = ();

open(FILE, $scgFile) or die "Can't open $scgFile\n";

while($line = <FILE>){
    chomp($line);

    $hashSCGs{$line} = 0;
}

close(FILE);

while($line = <STDIN>){
    chomp($line);

    my @tokens = split(/,/,$line);

    if($hashSCGs{$tokens[1]} ne undef){
        $hashSCGs{$tokens[1]}++;
    }
}

foreach $scg (keys %hashSCGs){
    print "$scg,$hashSCGs{$scg}\n";
}
