#!/usr/bin/zsh

kmer_length=$1
shift
thread=$1
shift
read_count=$1
shift
dir=$1



kmc='/data06/users/lee/.conda/envs/lee/bin/kmc'


#output file paths and names
base=$dir/$dir:t
output_kmc_canon=${base}_kmc_canon
output_kmc_all=${base}_kmc_all
output_for_GWAS=${base}_kmers_with_strand

# screen outputs
kmcerr=${base}_kmc.err
canonlog=${base}_canon.log
canonerr=${base}_canon.err
alllog=${base}_all.log
allerr=${base}_all.err
strandlog=${base}_strand.log
stranderr=${base}_strand.err


export SINGULARITY_BIND=/data06
input=${base}_input_files.txt
# remove if already exist
rm -f $input

{ 
 find $dir | egrep 'fq.gz$|fastq.gz$|R1.fastq.gz|R2.fastq.gz$' | head -n 2 > $input
 #find $dir | egrep 'fq.gz$|fastq.gz$|R1.fastq.gz$' > $input
 
 $kmc -k$kmer_length -t$thread -ci$read_count @$input $output_kmc_canon $dir 1>$canonlog 2>$canonerr # canonized count (KMC run 1)
 
 $kmc -k$kmer_length -t$thread -ci0 -b @$input $output_kmc_all $dir 1>$alllog 2>$allerr # no canonization (KMC run 2)
 
 singularity run /data06/users/lee/programs/kmersGWAS_docker/kmers-gwas.sif /app/bin/kmers_add_strand_information  -c $output_kmc_canon -n $output_kmc_all -k $kmer_length -o $output_for_GWAS 1>$strandlog 2>$stranderr # combine two KMC runs to one list of k-mers

 #$kmers_add_strand_information -c $output_kmc_canon -n $output_kmc_all -k $kmer_length -o $output_for_GWAS 1>$strandlog 2>$stranderr # combine two KMC runs to one list of k-mers
 
 rm -f $dir/*.kmc*
 
 }
 
 
 
 
 
 
 
 
 
 
 
