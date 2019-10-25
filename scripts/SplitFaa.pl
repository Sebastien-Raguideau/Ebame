#!/usr/bin/perl

use strict;

my $fastaFile   = $ARGV[0];
my $clusterFile = $ARGV[1];

my @Seq = ();
my @id       = ();
my %hashID   = {};
my %hashContigs = {};
my $count = 0;

open(FILE, $fastaFile) or die "Can't open $fastaFile\n";

my $seq = "";

while(my $line = <FILE>){ 
    chomp($line);
    
    if($line =~ />(.*?) .*/){
	#print "$1\n";	
	my $fid = $1;
	$id[$count] = $fid;
	$hashID{$1} = $count;

	if($seq ne ""){
	    $Seq[$count - 1] = $seq;

	    $seq = "";
	}
	
	my $contig="";
	if($fid=~/(.*)_(\d+)/){
		$contig=$1;
	}
	
	if($hashContigs{$contig} == undef){
		my @temp = ($fid);
		$hashContigs{$contig} = \@temp;
		
	}
	else{
		push(@{$hashContigs{$contig}},$fid); 
	}
#	print "$contig,$fid\n";
	$count++;
    }
    else{
	$seq .= $line;
    }
}

$Seq[$count - 1] = $seq;
my $total = $count;

my @t = ();
my $maxt = 0;
my $N = 0;
my $S = 0;
my %hashCluster = {};
my @clusterMap = [];

open(FILE, $clusterFile) or die "Can't open $clusterFile";

while(my $line = <FILE>){
  $N++;
  chomp($line);
  
  my @tokens = split(/,/,$line);

  my $name = $tokens[0];
  my $cluster = $tokens[1];

  $hashCluster{$name} = $cluster;
  #print "$name $cluster\n";
    if($clusterMap[$cluster] == undef){
      my @temp = ();

      $clusterMap[$cluster] = \@temp;
    }

    push(@{$clusterMap[$cluster]},$name);


  if($cluster > $maxt){
    $maxt = $cluster;
  }
}

close(FILE);

my $K = $maxt + 1;

for(my $k = 0; $k < $K; $k++){
  my @ids = @{$clusterMap[$k]};
  my $kSize = scalar(@ids);
  print "$k $kSize @ids\n";

  my $dirName = "Cluster$k";

  #mkdir $dirName; 

  open (FILE,">$dirName/Cluster${k}.faa");

  foreach my $name(@ids){
	foreach my $gene(@{$hashContigs{$name}}){
		my $idx = $hashID{$gene};
	
  		print FILE ">$id[$idx]\n$Seq[$idx]\n"
	}
  }
  close(FILE);
}

