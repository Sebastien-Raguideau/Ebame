#!/usr/bin/perl
use strict;
my %hashHits = ();
my $minEvalue = 1.0;
while(my $line = <STDIN>){
#GT4.hmm	160	k141_10000_4	122	7e-22	70	146	1	76	0.475

	chomp($line);

	my @tokens = split('\t',$line);

	my $hit = $tokens[0];

	my $query = $tokens[2];

	my $evalue = $tokens[4];

	if($evalue < $minEvalue){
		$hashHits{$query}{$hit} += 1;
	}
}

foreach my $query (keys %hashHits) {
	my $maxHit = 0;
	my $bestHit = -1;
	foreach my $hit(keys %{$hashHits{$query}}){
		if ($hashHits{$query}{$hit} > $maxHit){
			$maxHit = $hashHits{$query}{$hit};
			$bestHit = $hit;
		}
	}
	print "$query,$bestHit\n";
}
