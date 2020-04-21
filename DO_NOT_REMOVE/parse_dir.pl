#!/usr/bin/perl -w
use strict;

# parse_dir.pl 07NOV2019 by EMB to write shell script that will extract consensus sequence from nanopore data
# usage perl parse_dir.pl <content.txt> where content.txt contains the content of subdirectories in the folder of interest

open(IN, "<", $ARGV[0]) || die "cannot open input file: $!";
open(OUT, ">", "parse.sh") || die "cannot open output file: $!";

my $subdir = $ARGV[1];
$subdir =~ s/\/$//;
my $min = $ARGV[2];
my $max = $ARGV[3];
my %dirs;
my $flag;
my $rank = 1;
my @merged_files; my @filtered_files;
my $merged_file; my $filtered_file;

# parse content list of directory and subdirectories

while(my $line = <IN>){
  chomp $line;
  if($line =~ m/^[Bb]arcode/){      # each barcode subdirectory is assigned a 'rank' value
    $dirs{$line}{rank} = $rank;
  }elsif($line =~ m/\.\//){         # the relative path of each subdirectory is parsed to extract the subdirectory name and store this name in $flag
    my @data = split('/', $line);
    $flag = $data[2];
    $flag =~ s/://;
  }elsif($line =~ m/^$/){           # empty line resets the $flag variable that holds subdirectory information
    undef $flag;
  }elsif($flag){                    # the fastq files present in each barcode subdirectory are stored
    my $order = $dirs{$flag}{rank};
    $dirs{$flag}{$order} = $line;
    $dirs{$flag}{rank}++;
  }
}

# for each subdirectory, create output fastq files for merged and filtered data

foreach my $dir (sort keys %dirs){
  if($dirs{$dir}{rank} > 1){
    $merged_file = $dir."_merged.fastq";
    $filtered_file = $merged_file."_filtered.fastq";
    push @merged_files, $merged_file;
    push @filtered_files, $filtered_file;

    #print merge command
    print OUT "cat ";
    for(my $i = 1; $i < $dirs{$dir}{rank}; $i++){
      print OUT "./$subdir/$dir/", $dirs{$dir}{$i}, " ";
    }
    print OUT "> ./$subdir/merged_fastq/", $merged_file, "\n";
  }
}

print OUT "\n";

# print command to filter by minimum and maximum amplicon size
foreach my $file (@merged_files){
  print OUT "perl ./DO_NOT_REMOVE/filter.pl ", "./$subdir/merged_fastq/", $file, " ", $min, " ", $max, "\n";
}

print OUT "\n";
print OUT "mv ./$subdir/merged_fastq/*filtered.fastq ./$subdir/filtered_fastq\n";       # print command to move fastq files filtered by size to output folder
print OUT "\n";

# print canu command and copy result consensus files to separate folder

foreach my $file (@filtered_files){
  my @data2 = split('_', $file);
  print OUT "canu -p ", $data2[0], " -d ./$subdir/consensus_fastq/", $data2[0], " genomeSize=", $max/1000, "k corMhapSensitivity=high corMinCoverage=0 corOutCoverage=20000 -nanopore-raw ", "./$subdir/filtered_fastq/", $file, "\n";
  print OUT "cp ./$subdir/consensus_fastq/", $data2[0]. "/", $data2[0], ".contigs.fasta", " ./$subdir/consensus_seqs/", $data2[0], ".contigs.fasta", "\n";
}

close IN;
close OUT;
