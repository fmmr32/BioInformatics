#!/usr/bin/env nextflow

/***
*Name: F M Mushfiqur Rahman
*
*S_coelicolor_S_avermitilis_blast.tab found from genbank using blast search and blast tools
* using NextFlow Pipelining to get desired results
* to run the nf file ,write :nextflow run A1T2_pipeline.nf --f1 S_coelicolor_S_avermitilis_blast.tab 

*/

scol = file ("${params.f1}")




process A1T2_pipeline {

	input:
	file scol
	

	output:
	file "A1T2_results.txt" into results

	script:
	"""
	

	awk -F "\t" ' \$7<5 && \$12<1*10^-10 {print}{next}' ${scol}| cut -f1,2,3,7,12>A1T2_results.txt

	"""
}
results
.collectFile(storeDir:".")
