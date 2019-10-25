#!/usr/bin/perl

my $cogFile   = $ARGV[0];
my $clusterFile = $ARGV[1];

my @Cogs = ();
my @id       = ();
my %hashID   = {};
my %mapIDs   = {};
my $count = 0;

open(FILE, $cogFile) or die "Can't open $cogFile\n";


while($line = <FILE>){ 
    chomp($line);
    
    my @tokens = split(/,/,$line);	
	
    my $iid = $tokens[0];
    push(@id,$iid);

    if($iid =~/(.*)_\d+/){
        $stub=$1;
        if($mapIDs{$stub} eq undef){
            my @temp = ();
            $mapIDs{$stub} =\@temp;
        } 
        push(@{$mapIDs{$stub}},$iid);
    }

#    shift(@tokens);
    push(@Cogs,$line);
	$hashID{$iid} = $count;

	$count++;
}

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

  mkdir $dirName; 

  open (FILE,">$dirName/Cluster${k}.genes");

  foreach my $name(@ids){
    foreach my $iname(@{$mapIDs{$name}}){
	    my $idx = $hashID{$iname};
        print "$idx\n";
  	    print FILE "$Cogs[$idx]\n"
    }
  }
  close(FILE);
}
