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
	unless($line =~ /\w+\d{4}\/((\d{5})\w\d+)\.jpg\,\s*\w+\d{4}\/((\d{5})\w\d+)\.jpg\,\s*(.*)/){
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

#create hashes to hold standard deviation and mean
my %subject_specific_upper;
my %subject_specific_lower;

#interested in average, min, and max size of vectors
my $avg_vec_size = 0;
my $max_vec_size = 0;
my $min_vec_size = 100000;

foreach my $key ( keys %subject_specific) {

	#print "$key \n";

	#get vector out of hash
	my @tmp_vec = @{$subject_specific{$key}};
	my @sorted_vec = sort { $a <=> $b } @tmp_vec;

	#get stddev and mean
	my $tmp_median = median( @sorted_vec );
	my $tmp_min = min( @sorted_vec );
	my $tmp_max = max( @sorted_vec );

	#print "median : $tmp_median \n";

	#slice vector at median
	my @lower_vec = @sorted_vec[$tmp_min..$tmp_median];
	my @upper_vec = @sorted_vec[$tmp_median..$tmp_max];

	#get medians of upper and lower as upper and lower quartiles
	my $lower_q = median( @lower_vec );
	my $upper_q = median( @upper_vec );

	#print "Q1 : $lower_q\n";
	#print "Q2 : $upper_q\n\n\n";

	#store upper and lower quartile values
	$subject_specific_upper{$key} = $upper_q;
	$subject_specific_lower{$key} = $lower_q;

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

	print "$key\n";

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


	my $fail_flag = 0;

	#print "Q1 : " . $subject_specific_lower{$key}."\n";
	#print "Q2 : " . $subject_specific_upper{$key}."\n";
	my $IQR = abs( $subject_specific_lower{$key} - $subject_specific_upper{$key} ); 
	#print "IQR : $IQR \n\n\n";

	#run through vector until we hit a min that falls within 3 standard deviations
	#my $left_boundary = $subject_specific_lower{$key} - 1.5*(abs( $subject_specific_lower{$key} - $subject_specific_upper{$key} ));
	#my $right_boundary = $subject_specific_upper{$key} + 1.5*(abs( $subject_specific_lower{$key} - $subject_specific_upper{$key} ));
	
	my $left_boundary = $subject_specific_lower{$key};
	my $right_boundary = $subject_specific_upper{$key};

	#print "Left : $left_boundary\n";
	#print "Right : $right_boundary \n";

	while($this_min < $left_boundary){

		$min_index++;
		$this_min = $sorted_vec[$min_index];
		$this_left_shift++;

		if($min_index >= $max_index){
			$fail_flag = 1;		
			last;
		}

	}
	
	#set/store left comparison value
	if($fail_flag == 0){
		$left_compare{$key} = $this_min;
	}
	else{
		$left_compare{$key} = $left_boundary;
	}

	$fail_flag = 0;

	#run through vector until we hit a max that falls within 3 standard deviations
	while($this_max > $right_boundary){

		$max_index--;
		$this_max = $sorted_vec[$max_index];
		$this_right_shift++;

		if($max_index <=0){
			$fail_flag = 1;
			last;
		}

	}
	
	#set/store right comparison value
	if($fail_flag == 0){
		$right_compare{$key} = $this_max;
	}
	else{
		$right_compare{$key} = $right_boundary;
	}

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

my $strong = "strong_".$baseFile.".txt";
open STRONG, ">$strong";

my $weak = "weak_".$baseFile.".txt";
open WEAK, ">$weak";

my $neutral = "neutral_".$baseFile.".txt";
open NEUTRAL, ">$neutral";

my $strongCount = 0;
my $weakCount = 0;
my $neutralCount = 0;

open SCORES, "$inputFile";

#iterate through hashes
while(my $line2 = <SCORES>){

	chomp $line2;

	#check if it is of the correct form
	unless($line2 =~ /\w+\d{4}\/((\d{5})\w\d+)\.jpg\,\s*\w+\d{4}\/((\d{5})\w\d+)\.jpg\,\s*(\-*\d+\.*\d*)/){
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
			print OUT "STRONG : $galleryImg $probeImg $score \n";
			print STRONG "0 $score\n";
			$strongCount++;
		}	
		elsif($gallery eq 'min'){
			print OUT "WEAK : $galleryImg $probeImg $score \n";
			print WEAK "0 $score\n";
			$weakCount++;
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

