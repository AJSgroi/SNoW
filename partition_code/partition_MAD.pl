use strict;
use List::Util qw( min max );
use Statistics::Basic qw(:all);

#get the csv file with all the scores and open it for reading
my $inputFile = $ARGV[0];
open SCORES, "$inputFile";

#create hash with two keys that point to a vector to hold subject-pair distributions
my %subject_specific;

#iterate through file
while(my $line = <SCORES>){

	chomp $line;

	#check if it is of the correct form
	#unless($line =~ /((\d{5})\_\d{6}\_\w+)\s*((\d{5})\_\d{6}\_\w+)\s*(.*)/){
	unless($line =~ /((\d{3})\_\d{2}\_\d{2})\s((\d{3})\_\d{2}\_\d{2})\s(.*)/){
	#unless($line =~ /\w+\d{4}\/((\d{5})\w\d+)\.jpg\,\s*\w+\d{4}\/((\d{5})\w\d+)\.jpg\,\s*(.*)/){
	#unless($line =~ /\.\/((\d{5})\w\d+)\.\w+\,\.\/((\d{5})\w\d+)\.\w+\,(.*)/){
	#unless($line =~ /\.\/((\d{5})\w\d+)\.\w+\,\.\/((\d{5})\w\d+)\.\w+\,(.*)/){
	#unless($line =~ /((\d{7}))\s\,\s((\d{7}))\s\,\s(.*)/){
		next;
	}

	#print "past regex\n";

	#get information from line
	my $galleryImg = $1;
	my $galleryID = $2;

	my $probeImg = $3;
	my $probeID = $4;

	my $score = $5;

	#must check if they are nonmatches
	if($galleryID eq $probeID){
		next;
	}

	#push value onto appropriate hash element
	push(@{$subject_specific{$galleryID}}, $score);
	#my $tmp_val = scalar @{$subject_specific{$galleryID}};
	#print " $galleryID vector is of length $tmp_val\n";
}

close SCORES;
print "Finished reading all scores \n";

#create hashes to hold median and median absolute deviation
my %subject_specific_median;
my %subject_specific_MAD;

#interested in average, min, and max size of vectors
my $avg_vec_size = 0;
my $max_vec_size = 0;
my $min_vec_size = 100000;

foreach my $key ( keys %subject_specific) {

	#get vector out of hash
	my @tmp_vec = @{$subject_specific{$key}};

	#get stddev and mean
	my $tmp_median = median( @tmp_vec );
	
	my @MAD_vec;
	for my $tmp (@tmp_vec){
		
		$tmp = abs($tmp - $tmp_median);
		push(@MAD_vec, $tmp);
	}
	my $tmp_MAD = median( @MAD_vec );

	#store stddev and mean
	$subject_specific_median{$key} = $tmp_median;
	$subject_specific_MAD{$key} = $tmp_MAD;

	my $tmp_size = scalar @tmp_vec;

	$avg_vec_size = $avg_vec_size + $tmp_size;

	if($tmp_size < $min_vec_size){
		$min_vec_size = $tmp_size;
	}	
	if($tmp_size > $max_vec_size){
		$max_vec_size = $tmp_size;
	}
}

#print out stats
my $num_keys = scalar keys %subject_specific;
$avg_vec_size = $avg_vec_size / $num_keys;

print "Average Subject-Specific Distribution Size : $avg_vec_size \n";
print "Maximum Subject-Specific Distribution Size : $max_vec_size \n";
print "Minimum Subject-Specific Distribution Size : $min_vec_size \n";

##OUTLIER DETECTION##
#	Method : 3 Standard Deviations Rule	#

#create hashes to hold left(min) and right(max) comparison values
my %left_compare;
my %right_compare;

#we are also interested in the number of average, maximum, and minimum shifts required on both left and right;
my $right_max_shift = 0;
my $right_min_shift = 100;
my $right_avg_shift = 0;

my $left_max_shift = 0;
my $left_min_shift = 100;
my $left_avg_shift = 0;

foreach my $key ( keys %subject_specific){

	#get tmp vector from hash
	my @this_vec = @{$subject_specific{$key}};

	#sort vector numerically ascending
	my @sorted_vec = sort { $a <=> $b } @this_vec;

	#so now min is the first element and max is last element
	#get the max and min elements
	my $min_index = 0;
	my $max_index = (scalar @sorted_vec) - 1;
	my $this_min = $sorted_vec[$min_index];
	my $this_max = $sorted_vec[$max_index];

	#create variables for this vectors stats
	my $this_right_shift = 0;
	my $this_left_shift = 0;

	#run through vector until we hit a min that falls within 3 standard deviations
	my $left_boundary = $subject_specific_median{$key} - $subject_specific_MAD{$key};
	while($this_min < $left_boundary){

		$min_index++;
		$this_min = $sorted_vec[$min_index];
		$this_left_shift++;

	}
	
	#set/store left comparison value
	$left_compare{$key} = $this_min;

	#run through vector until we hit a max that falls within 3 standard deviations
	my $right_boundary = $subject_specific_median{$key} + 3*$subject_specific_MAD{$key};
	while($this_max > $right_boundary){

		$max_index--;
		$this_max = $sorted_vec[$max_index];
		$this_right_shift++;

	}
	
	#set/store right comparison value
	$right_compare{$key} = $this_max;

	#statistics tracking
	$right_avg_shift = $right_avg_shift + $this_right_shift;
	if($this_right_shift > $right_max_shift){
		$right_max_shift = $this_right_shift;
	}
	if($this_right_shift < $right_min_shift){
		$right_min_shift = $this_right_shift;
	}

	$left_avg_shift = $left_avg_shift + $this_left_shift;
	if($this_left_shift > $left_max_shift){
		$left_max_shift = $this_left_shift;
	}
	if($this_left_shift < $left_min_shift){
		$left_min_shift = $this_left_shift;
	}

}

#print statistics
print "\n\n";
$right_avg_shift = $right_avg_shift / $num_keys;
$left_avg_shift = $left_avg_shift / $num_keys;

print "Averge left (min value) shift : $left_avg_shift\n";
print "Maximum left (min value) shift : $left_max_shift\n";
print "Minimum left (min value) shift : $left_min_shift\n\n";

print "Averge right (max value) shift : $right_avg_shift\n";
print "Maximum right (max value) shift : $right_max_shift\n";
print "Minimum right (max value) shift : $right_min_shift\n\n";

#get outputfile and open it for writing
my $outputFile = $ARGV[1];
open OUT, ">$outputFile";

#get base for strong, neutral and weak files
my $baseFile = $ARGV[2];

my $strong = "strong_MAD_".$baseFile.".txt";
open STRONG, ">$strong";

my $weak = "weak_MAD_".$baseFile.".txt";
open WEAK, ">$weak";

my $neutral = "neutral_MAD_".$baseFile.".txt";
open NEUTRAL, ">$neutral";

my $strongCount = 0;
my $weakCount = 0;
my $neutralCount = 0;

open SCORES, "$inputFile";

#iterate through hashes
while(my $line2 = <SCORES>){

	chomp $line2;

	#check if it is of the correct form
	#unless($line2 =~ /((\d{5})\_\d{6}\_\w+)\s*((\d{5})\_\d{6}\_\w+)\s*(.*)/){
	unless($line2 =~ /((\d{3})\_\d{2}\_\d{2})\s((\d{3})\_\d{2}\_\d{2})\s(.*)/){
	#unless($line2 =~ /\.\/((\d{5})\w\d+)\.\w+\,\.\/((\d{5})\w\d+)\.\w+\,(.*)/){
	#unless($line2 =~ /\w+\d{4}\/((\d{5})\w\d+)\.jpg\,\s*\w+\d{4}\/((\d{5})\w\d+)\.jpg\,\s*(\-*\d+\.*\d*)/){
	#unless($line2 =~ /((\d{7}))\s\,\s((\d{7}))\s\,\s(.*)/){
		next;
	}

	#print "past regex\n";

	#get information from line
	my $galleryImg = $1;
	my $galleryID = $2;

	my $probeImg = $3;
	my $probeID = $4;

	my $score = $5;
	
	my $g_max = $right_compare{$galleryID};
	my $p_max = $right_compare{$probeID};

	my $g_min = $left_compare{$galleryID};
	my $p_min = $left_compare{$probeID};


	#look at distance from max score to all global scores
	my $gallery_diff_max = abs($score-$g_min);
	my $gallery_diff_min = abs($score-$g_max);
	my $probe_diff_max = abs($score-$p_min);
	my $probe_diff_min = abs($score-$p_max);

	#print "$gallery_diff_max and $gallery_diff_min and $galleryID\n";

	my $gallery;
	my $probe;

	#find the closes max or min for gallery and probe
	if($gallery_diff_max > $gallery_diff_min){
		#closer to the gallery max
		$gallery = 'max';
	}
	else{
		#closer to the gallery min
		$gallery = 'min';
	}

	if($probe_diff_max > $probe_diff_min){
		#closer to the probe max
		$probe = 'max';
	}
	else{
		#closer to the probe min
		$probe = 'min';
	}

	if($gallery eq $probe){
		if($gallery eq 'max'){
			print OUT "WEAK : $galleryImg $probeImg $score \n";
			print WEAK "0 $score\n";
			$weakCount++;
		}	
		elsif($gallery eq 'min'){
			print OUT "STRONG : $galleryImg $probeImg $score \n";
			print STRONG "0 $score\n";
			$strongCount++;
		}
	}
	else{
		print OUT "NEUTRAL : $galleryImg $probeImg $score \n";
		print NEUTRAL "0 $score\n";
		$neutralCount++;
	}
		
}

#end printing
close OUT;
close STRONG;
close WEAK;
close NEUTRAL;
print "Number of Strong: $strongCount, Neutral: $neutralCount, and Weak: $weakCount\n";

