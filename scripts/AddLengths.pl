#!/usr/bin/perl

my $lengthFile = $ARGV[0];

open(FILE, $lengthFile) or die;
my %hashLength = ();
while($line = <FILE>){
    chomp($line);

    my @tokens = split(/\t/,$line);

    $hashLengths{$tokens[0]} = $tokens[1];

}

while($line = <STDIN>){
    chomp($line);
    $id = $line;
#    my @tokens = split(/,/,$line);

    print "$id\t1\t$hashLengths{$id}\n";
}
