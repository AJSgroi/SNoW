use strict;

#get four input files
my $inputFile1 = $ARGV[0];
my $inputFile2 = $ARGV[1];

#open input files for reading
open RESULTS1, "$inputFile1";
open RESULTS2, "$inputFile2";

#create hash table to store all information desire
my %results_hash = ();

#read through file 1
while(my $line = <RESULTS1>){

	#remove white space
	chomp $line;

	#STRONG : 02463d713 04203d631 -0.0472559
	unless($line =~ /(\w+)\s\:\s((\d+)_\d+_\w+)\s((\d+)_\d+_\w+)\s(.*)/){
		next;
	}

	#get data
	my $p_type = $1;
	my $gallery = $2;
	my $g_sub = $3;
	my $probe = $4;
	my $p_sub = $5;

	#add results to hash
	if($g_sub eq $p_sub){
		next;
	}

	$results_hash{$gallery}{$probe}{1} = $p_type;
}
close RESULTS1;
	
#read through file 2
while(my $line = <RESULTS2>){

	#remove white space
	chomp $line;

	#STRONG : 02463d713 04203d631 -0.0472559
	unless($line =~ /(\w+)\s\:\s((\d+)_\d+_\w+)\s((\d+)_\d+_\w+)\s(.*)/){
		next;
	}

	#get data
	my $p_type = $1;
	my $gallery = $2;
	my $g_sub = $3;
	my $probe = $4;
	my $p_sub = $5;

	#add results to hash
	if($g_sub eq $p_sub){
		next;
	}

	#add results to hash
	$results_hash{$gallery}{$probe}{2} = $p_type;
}
close RESULTS2;


my $same_strong = 0;
my $same_weak = 0;
my $same_neutral = 0;

my $total_comps = 0;

foreach my $keys_1 (sort keys %results_hash){
	foreach my $keys_2 (keys %{ $results_hash{$keys_1}}){

		$total_comps = $total_comps+1;

		my $r1 = $results_hash{$keys_1}{$keys_2}{1};
		my $r2 = $results_hash{$keys_1}{$keys_2}{2};

		chomp $r1;
		chomp $r2;


		if($r1 eq $r2){
			if($r1 eq "WEAK"){
				$same_weak = $same_weak+1;
			}
			elsif($r1 eq "NEUTRAL"){
				$same_neutral = $same_neutral+1;
			}
			else{
				$same_strong = $same_strong+1;
			}

		}

	}
}

#print out information
print "Same Strong	: $same_strong\n";
print "Same Neutral 	: $same_neutral\n";
print "Same Weak 	: $same_weak\n";


$same_strong = $same_strong/$total_comps * 100;
$same_neutral = $same_neutral/$total_comps * 100;
$same_weak = $same_weak/$total_comps * 100;

print "Same Strong %	: $same_strong%\n";
print "Same Neutral %	: $same_neutral%\n";
print "Same Weak %	: $same_weak%\n";


