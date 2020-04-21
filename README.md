# nanopore-amplicon-consensus
A canu wrapper for generating amplicon consensus sequences using the raw data output and folder structure from nanopore DNA sequencing as input

This script will process demultiplexed amplicon sequencing data produced using Oxford Nanopore Technologies sequencing (ONT-seq) and generate consensus sequences using Canu. 

Prerequisits:
Canu and all of its requirements need to be installed. The directory containing the canu executable needs to be added to PATH. See Canu documentation for installation instructions (https://canu.readthedocs.io/en/latest/index.html).

Setting up the correct directory structure:
ONT-seq data should be copied into the directory that contains this README file as a single run directory that contains one or more barcode subdirectories. The names of each of these subdirectories should start with "barcode" or "Barcode", which is how these directories are created by ONT software during demultiplexing. Each barcode subdirectory will contain one or more fastq files of raw sequence data. In summary: nanopore-amplicon-consensus/<run>/<barcodesxx>/<files.fastq>

Running the nanopore-amplicon-consensus wrapper:
Use the following command:

sh nanopore-amplicon-consensus.sh <name_of_run_directory> <minimum_amplicon_length> <maximum_amplicon_length>

This will first remove any existing TEMP or result folders that may have been generated during a previous execution of the script. Next, multiple fastq files from the same barcode directory will be merged and filtered for minimum and maximum amplicon length. It is recommended to use the target amplicon length +/- 100 nucleotides. Finally, these merged and filtered files will be used by canu to generate consensus sequences. The fastq files of these consensus sequences will be copied to the output folder "consensus_seqs" for convenience. Note that this output directory and directories with merged, filtered, and consensus fastq created in the process will be removed when the script is executed again on the same run directory. 
