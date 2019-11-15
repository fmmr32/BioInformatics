#!/usr/bin/env nextflow

/*
* Name: F M MUSHFIQUR RAHMAN
*sorting and overlapping through bedfile, gff file using
* Perl and BEDtools from docker containers
*
*/

params.gffFile = "X_nematophila_GCF_000252955.1_ASM25295v1_genomic.gff"
params.bedFile_1 ="X_nematophila_sRNAs.bed"

gtfFile = file (params.gffFile)
fileBed = file(params.bedFile_1)


process getBEDfile {

	
input:
	 file gtfFile
output:
	file "tempFile.bed" into BED

script:
"""
awk '\$3 ~/gene/ {print;}' $gtfFile | awk '{t=\$7;\$7=\$9;\$9=t;print;}'| awk -vOFS="\t" '{\$7 = \$7; sub(/.*tag=/,"",\$7); print}'|
cut -f1,4,5,7,9 | cut -d ';' -f1 |awk '{ (\$2=\$2-1)"" };1'|
 awk '\$4 = \$4 FS "."'| perl -p -e 's/ +/\t/g'|awk '\$6!=""' > tempFile.bed


"""
}


process getOverLap {

container 'genomicpariscentre/bedtools'
input:
	file fileBed
	file bedFile from BED
output: 
	file "A2_T2_overlap.txt" into OVERLAP

script: 
"""
bedtools intersect -a $bedFile -b $fileBed -f 0.60  > A2_T2_overlap.txt
"""
	
}


OVERLAP
.collectFile(storeDir:".")





