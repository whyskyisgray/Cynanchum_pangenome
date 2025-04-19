#!/usr/bin/zsh


#convert kmerGWAS result into the fasta format



# make index 
vg autoindex --workflow map --prefix test --gfa cactus.gfa -t 24 -T ./temp
