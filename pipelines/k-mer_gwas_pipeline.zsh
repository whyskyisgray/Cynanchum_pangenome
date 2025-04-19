#!/usr/bin/zsh

######################################################
#k-mer-based GWAS and anchoring on the graph-pangenome
######################################################

code_dir='/data06/users/lee/codes'


# make sample dir list
ls -d */ | while read line;do realpath $line;done > sample_dir.txt
dir=`realpath sample_dir.txt`


# kmc running
cat sample_dir.txt| while read line
do 
    echo "zsh $code_dir/kmers_gwas/KMC_count_kmer-imcrop4.zsh 31 2 2 $line"
done | parallel -j 60


# make kmc result list
find $(pwd) | grep 'kmers_with_strand$' | while read line
do
  file_name=`ls $line | rev | cut -d '/' -f 1 | rev`
  echo -e $line"\t"$file_name
done > kmers_list_paths.txt



# provided from kmersGWAS
#make k-mer list
singularity run /data06/users/lee/programs/kmersGWAS_docker/kmers-gwas.sif /app/bin/list_kmers_found_in_multiple_samples -l kmers_list_paths.txt -k 31 --mac 3 -p 0.2 -o kmers_to_use 1> listkmers.log 2> listkmers.err

# Creat kmer table
singularity run /data06/users/lee/programs/kmersGWAS_docker/kmers-gwas.sif /app/bin/build_kmers_table -l kmers_list_paths.txt -k 31 -a kmers_to_use -o kmers_table 1> kmertable.log 2> kmertable.err

# calculate kinship matrix
singularity run /data06/users/lee/programs/kmersGWAS_docker/kmers-gwas.sif /app/bin/emma_kinship_kmers -t kmers_table -k 31 --maf 0.01 > kmers_table.kinship 2> kinship.err




#phenotype file making
pheno=`path kmer_pheno_merge.mod.tsv`
col_number=`head -1 $pheno | sed 's/\t/\n/g' | wc -l`
for i in {2..$(expr $col_number)}
do
    ids=`cat $pheno | head -1 | cut -f $i`
    echo -e 'accession_id\tphenotype_value' > $ids.pheno
    cat $pheno | cut -f 1,$i | awk '{print $1"_kmers_with_strand\t"$2}' | grep -v Taxa >> $ids.pheno
done


#run kmerGWAS program
ls *pheno | rev | cut -d . -f 2- | rev | while read line;do path -i $line $line.pheno;done > running_file

running_file=`path running_file`

cat $running_file| while read ids paths
do
  echo "python2.7 $programs/kmersGWAS_docker/kmers_gwas.py \
  --pheno $paths \
  --kmers_table kmers_table \
  --gemma_path $programs/gemma_0_98/gemma_0_98 \
  --outdir $ids \
  -l 31 \
  -p 10 \
  -k 100000 \
  --maf 0.01"
done | parallel -j 4





