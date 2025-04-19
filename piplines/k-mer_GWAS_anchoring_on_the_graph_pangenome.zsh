#!/usr/bin/zsh


#convert kmerGWAS result into the fasta format
zcat phenotype_value.assoc.txt.gz | awk 'NR>1' | awk '{split ($2, a, "_")} {print ">no"NR"_"$10"\n"a[1]}' > extracted_kmer.fasta.fasta


# make index 
vg autoindex --workflow map --prefix cw_pan --gfa cactus.gfa -t 24 -T ./temp
vg map -F $paths -t 16 -x cw_pan.xg -g cw_pan.gcsa | vg surject -x cw_pan.xg -b /dev/stdin > $ids.bam
samtools view -F 4 $ids.bam | awk -v OFS="\t" '$6=="31M" {split($1, a, "_")} {print $3,$4,a[1], a[2]}' | sed '1 i chr\tpos\tno\tp' > $ids.pos
python $development/gwas/gwas_plotting_input_maker.py -input $ids.pos -config $development/gwas/config/kmer_manhattan.config > root_diameter.input


python $development/gwas/kmers_gwas_sliding_window_filtering.py -i root_diameter.kmer.input -o root_diameter.kmer.input.filter -w 31 -d 5 -lp 7

Rscript $development/gwas/manhattan_plotting_v5.R root_diameter.input manhattan_plot.pdf 0 15 $development/gwas/config/input.fai
