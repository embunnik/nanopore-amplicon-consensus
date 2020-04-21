#usage: sh nanopore-amplicon-consensus.sh <run_directory> <minimum sequence length in nt> <maximum sequence length in nt>

subdir=$(echo $1 | sed 's/\/$//')

rm -r ./TEMP; mkdir ./TEMP
rm -r ./$subdir/merged_fastq; mkdir ./$subdir/merged_fastq
rm -r ./$subdir/filtered_fastq; mkdir ./$subdir/filtered_fastq
rm -r ./$subdir/consensus_fastq; mkdir ./$subdir/consensus_fastq
rm -r ./$subdir/consensus_seqs; mkdir ./$subdir/consensus_seqs
ls -R ./$subdir > ./TEMP/content.txt

perl ./DO_NOT_REMOVE/parse_dir.pl ./TEMP/content.txt $1 $2 $3

mv parse.sh ./TEMP/parse.sh

source ./TEMP/parse.sh

rm -r ./TEMP
