use strict;

#get the csv file with all the scores and open it for reading
my $inputFile = $ARGV[0];
open SCORES, "$inputFile";

#make data structures for max and min
my %global_Max = ();
my %global_Min = ();

my $current_max = 0;
my $current_min = 0;

#determine images used
my %strong_images = ();
my %weak_images = ();
my %neutral_images = ();

my $simg = 'strong_images.txt';
open SIMG, ">$simg";

my $wimg = 'weak_images.txt';
open WIMG, ">$wimg";

my $nimg = 'neutral_images.txt';
open NIMG, ">$nimg";

my $matches = 'matches.txt';
open MScores, ">$matches";

#iterate through file
while(my $line = <SCORES>){

	chomp $line;

	#check if it is of the correct form
	#unless($line =~ /((\d{3})\_\d{2}\_\d{2})\s((\d{3})\_\d{2}\_\d{2})\s(.*)/){
	unless($line =~ /((\d{5})\_\d{6}\_\w+)\s*((\d{5})\_\d{6}\_\w+)\s*(.*)/){
	#unless($line =~ /((\d{7}))\s\,\s((\d{7}))\s\,\s(.*)/){
	#unless($line =~ /(.*(\d{5})\w\d+.*)\s(.*(\d{5})\w\d+.*)\s(.*)/){
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
		print MScores "$galleryImg $probeImg $score\n";
		next;
	}


	#check if have global entry for gallery
	if(exists ($global_Min{$galleryID})){
		#get the current value
		$current_min = $global_Min{$galleryID};

		#compare it
		if($score < $current_min){
			#replace it
			$global_Min{$galleryID} = $score;
		}
	}
	else{
		$global_Min{$galleryID} = $score;
	}


	#check if have global entry for probe
	if(exists ($global_Min{$probeID})){
		#get the current value
		$current_min = $global_Min{$probeID};

		#compare it
		if($score < $current_min){
			#replace it
			$global_Min{$probeID} = $score;
		}
	}
	else{
		$global_Min{$probeID} = $score;
	}

	#check if have global entry for gallery
	if(exists ($global_Max{$galleryID})){
		#get the current value
		$current_max = $global_Max{$galleryID};

		#compare it
		if($score > $current_max){
			#replace it
			$global_Max{$galleryID} = $score;
		}
	}
	else{
		$global_Max{$galleryID} = $score;
	}


	#check if have global entry for probe
	if(exists ($global_Max{$probeID})){
		#get the current value
		$current_max = $global_Max{$probeID};

		#compare it
		if($score > $current_max){
			#replace it
			$global_Max{$probeID} = $score;
		}
	}
	else{
		$global_Max{$probeID} = $score;
	}


}

close SCORES;
close MScores;

#get outputfile and open it for writing
my $outputFile = $ARGV[1];
open OUT, ">$outputFile";

my $strong = 'strong_test.txt';
open STRONG, ">$strong";

my $weak = 'weak_test.txt';
open WEAK, ">$weak";

my $neutral = 'neutral_test.txt';
open NEUTRAL, ">$neutral";

my $strongCount = 0;
my $weakCount = 0;
my $neutralCount = 0;

open SCORES, "$inputFile";

#iterate through hashes
while(my $line2 = <SCORES>){

	chomp $line2;

	#check if it is of the correct form
#	00002_930831_fa 00002_931230_fa 0.999973
	unless($line2 =~ /((\d{5})\_\d{6}\_\w+)\s*((\d{5})\_\d{6}\_\w+)\s*(.*)/){
	#unless($line2 =~ /((\d{3})\_\d{2}\_\d{2})\s((\d{3})\_\d{2}\_\d{2})\s(.*)/){
	#unless($line2 =~ /((\d{7}))\s\,\s((\d{7}))\s\,\s(.*)/){
	#unless($line2 =~ /(.*(\d{5})\w\d+.*)\s(.*(\d{5})\w\d+.*)\s(.*)/){
	#unless($line2 =~ /((\d{5})\w\d+)\,((\d{5})\w\d+)\,(.*)/){
		next;
	}

	#print "past regex\n";

	#get information from line
	my $galleryImg = $1;
	my $galleryID = $2;

	my $probeImg = $3;
	my $probeID = $4;

	my $score = $5;
	
	my $g_max = $global_Max{$galleryID};
	my $p_max = $global_Max{$probeID};

	my $g_min = $global_Min{$galleryID};
	my $p_min = $global_Min{$probeID};


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
			if(exists ($weak_images{$galleryImg}) ){
			}
			else{
				$weak_images{$galleryImg} = 1;
				print WIMG "$galleryImg\n";
			}			
			if(exists ($weak_images{$probeImg}) ){
			}
			else{
				$weak_images{$probeImg} = 1;
				print WIMG "$probeImg\n";
			}
			print WEAK "0 $score\n";
			$weakCount++;
		}	
		elsif($gallery eq 'min'){
			print OUT "STRONG : $galleryImg $probeImg $score \n";
			if(exists ($strong_images{$galleryImg}) ){
			}
			else{
				$strong_images{$galleryImg} = 1;
				print SIMG "$galleryImg\n";
			}			
			if(exists ($strong_images{$probeImg}) ){
			}
			else{
				$strong_images{$probeImg} = 1;
				print SIMG "$probeImg\n";
			}
			print STRONG "0 $score\n";
			$strongCount++;
		}
	}
	else{
		print OUT "NEUTRAL : $galleryImg $probeImg $score \n";
		if(exists ($neutral_images{$galleryImg}) ){
		}
		else{
			$neutral_images{$galleryImg} = 1;
			print NIMG "$galleryImg\n";
		}			
		if(exists ($neutral_images{$probeImg}) ){
		}
		else{
			$neutral_images{$probeImg} = 1;
			print NIMG "$probeImg\n";
		}
		print NEUTRAL "0 $score\n";
		$neutralCount++;
	}
		
}

#end printing
close OUT;
close STRONG;
close WEAK;
close NEUTRAL;

close WIMG;
close NIMG;
close SIMG;

print "Number of Strong: $strongCount, Neutral: $neutralCount, and Weak: $weakCount\n";

