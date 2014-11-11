use strict;

#get four input files
my $inputFile1 = $ARGV[0];
my $inputFile2 = $ARGV[1];
my $inputFile3 = $ARGV[2];
my $inputFile4 = $ARGV[3];

#get two output files
my $outFile1 = $ARGV[4];
my $outFile2 = $ARGV[5];

open OUT_STRONG, ">$outFile1";
open OUT_WEAK, ">$outFile2";

#open input files for reading
open RESULTS1, "$inputFile1";
open RESULTS2, "$inputFile2";
open RESULTS3, "$inputFile3";
open RESULTS4, "$inputFile4";

#create hash table to store all information desire
my %results_hash = ();


#read through file 1
while(my $line = <RESULTS1>){

	#remove white space
	chomp $line;
	

	#001_01_01 001_02_01 1
	#unless($line =~ /(\w+)\s\:\s((\d{5})\_\d{6}\_\w{2}\_*\w*)\s((\d{5})\_\d{6}\_\w{2}\_*\w*)\s(.*)/){
	#unless($line =~ /(\w+)\s\:\s((\d{3})\_\d{2}\_\d{2})\s((\d{3})\_\d{2}\_\d{2})\s(.*)/){
	unless($line =~ /(\w+)\s\:\s((\d{5})\w\d+)\s((\d{5})\w\d+)\s(.*)/){
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
	unless($line =~ /(\w+)\s\:\s((\d{5})\w\d+)\s((\d{5})\w\d+)\s(.*)/){
	#unless($line =~ /(\w+)\s\:\s((\d{3})\_\d{2}\_\d{2})\s((\d{3})\_\d{2}\_\d{2})\s(.*)/){
	#unless($line =~ /(\w+)\s\:\s((\d{5})\_\d{6}\_\w{2}\_*\w*)\s((\d{5})\_\d{6}\_\w{2}\_*\w*)\s(.*)/){
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

#read through file 3
while(my $line = <RESULTS3>){

	#remove white space
	chomp $line;

	#STRONG : 02463d713 04203d631 -0.0472559
	unless($line =~ /(\w+)\s\:\s((\d{5})\w\d+)\s((\d{5})\w\d+)\s(.*)/){
	#unless($line =~ /(\w+)\s\:\s((\d{3})\_\d{2}\_\d{2})\s((\d{3})\_\d{2}\_\d{2})\s(.*)/){
	#unless($line =~ /(\w+)\s\:\s((\d{5})\_\d{6}\_\w{2}\_*\w*)\s((\d{5})\_\d{6}\_\w{2}\_*\w*)\s(.*)/){
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
	$results_hash{$gallery}{$probe}{3} = $p_type;
}
close RESULTS3;

#read through file 4
while(my $line = <RESULTS4>){

	#remove white space
	chomp $line;

	#STRONG : 02463d713 04203d631 -0.0472559
	unless($line =~ /(\w+)\s\:\s((\d{5})\w\d+)\s((\d{5})\w\d+)\s(.*)/){
	#unless($line =~ /(\w+)\s\:\s((\d{3})\_\d{2}\_\d{2})\s((\d{3})\_\d{2}\_\d{2})\s(.*)/){
	#unless($line =~ /(\w+)\s\:\s((\d{5})\_\d{6}\_\w{2}\_*\w*)\s((\d{5})\_\d{6}\_\w{2}\_*\w*)\s(.*)/){
		next;
	}

	#print "$line\n";

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

	$results_hash{$gallery}{$probe}{4} = $p_type;
}
close RESULTS4;


my $same_strong = 0;
my $same_weak = 0;
my $same_neutral = 0;


my $r1_strong = 0;
my $r1_neutral = 0;
my $r1_weak = 0;

my $r2_strong = 0;
my $r2_neutral = 0;
my $r2_weak = 0;

my $r3_strong = 0;
my $r3_neutral = 0;
my $r3_weak = 0;

my $r4_strong = 0;
my $r4_neutral = 0;
my $r4_weak = 0;

my $total_comps = 0;

foreach my $keys_1 (sort keys %results_hash){
	foreach my $keys_2 (keys %{ $results_hash{$keys_1}}){

		$total_comps = $total_comps+1;

		my $r1 = $results_hash{$keys_1}{$keys_2}{1};
		my $r2 = $results_hash{$keys_1}{$keys_2}{2};
		my $r3 = $results_hash{$keys_1}{$keys_2}{3};
		my $r4 = $results_hash{$keys_1}{$keys_2}{4};

		chomp $r1;
		chomp $r2;
		chomp $r3;
		chomp $r4;


		if($r1 eq "STRONG"){
			$r1_strong = $r1_strong +1;
		}
		elsif($r1 eq "NEUTRAL"){
			$r1_neutral = $r1_neutral +1;
		}
		else{
			$r1_weak = $r1_weak +1;
		}


		if($r2 eq "STRONG"){
			$r2_strong = $r2_strong +1;
		}
		elsif($r2 eq "NEUTRAL"){
			$r2_neutral = $r2_neutral +1;
		}
		else{
			$r2_weak = $r2_weak +1;
		}

		if($r3 eq "STRONG"){
			$r3_strong = $r3_strong +1;
		}
		elsif($r3 eq "NEUTRAL"){
			$r3_neutral = $r3_neutral +1;
		}
		else{
			$r3_weak = $r3_weak +1;
		}

		if($r4 eq "STRONG"){
			$r4_strong = $r4_strong +1;
		}
		elsif($r4 eq "NEUTRAL"){
			$r4_neutral = $r4_neutral +1;
		}
		else{
			$r4_weak = $r4_weak +1;
		}

		if($r1 eq $r2){
			if($r3 eq $r1){
				if($r4 eq $r1){

					if($r1 eq "WEAK"){
						$same_weak = $same_weak+1;
						print OUT_WEAK "$keys_1 $keys_2 \n";
					}
					elsif($r1 eq "NEUTRAL"){
						$same_neutral = $same_neutral+1;
					}
					else{
						$same_strong = $same_strong+1;
						print OUT_STRONG "$keys_1 $keys_2 \n";
					}

				}
			}
		}

	}
}

close OUT_WEAK;
close OUT_STRONG;


#$r1_strong = $r1_strong/$total_comps;
#$r1_neutral = $r1_neutral/$total_comps;
#$r1_weak = $r1_weak/$total_comps;


#$r2_strong = $r2_strong/$total_comps;
#$r2_neutral = $r2_neutral/$total_comps;
#$r2_weak = $r2_weak/$total_comps;

#$r3_strong = $r3_strong/$total_comps;
#$r3_neutral = $r3_neutral/$total_comps;
#$r3_weak = $r3_weak/$total_comps;

#$r4_strong = $r4_strong/$total_comps;
#$r4_neutral = $r4_neutral/$total_comps;
#$r4_weak = $r4_weak/$total_comps;

#print "1 : $r1_strong, $r1_neutral, $r1_weak \n";
#print "2 : $r2_strong, $r2_neutral, $r2_weak \n";
#print "3 : $r3_strong, $r3_neutral, $r3_weak \n";
#print "4 : $r4_strong, $r4_neutral, $r4_weak \n";


my $rate_strong = ($r1_strong * $r2_strong * $r3_strong * $r4_strong)/($total_comps ** 4);
my $rate_neutral = ($r1_neutral * $r2_neutral * $r3_neutral * $r4_neutral)/($total_comps ** 4);
my $rate_weak = ($r1_weak * $r2_weak * $r3_weak * $r4_weak)/($total_comps ** 4);

print "Strong rate 	: $rate_strong\n";
print "Neutral rate 	: $rate_neutral\n";
print "Weak rate 	: $rate_weak\n";


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


