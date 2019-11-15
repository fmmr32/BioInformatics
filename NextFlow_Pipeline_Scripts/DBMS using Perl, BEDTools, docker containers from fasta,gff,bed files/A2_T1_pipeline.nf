#!/usr/bin/env nextflow

/*
* Name: F M MUSHFIQUR RAHMAN
*sorting through fasta file, hmmer file using BEDtools, Perl, Clustal omega from docker containers
*
*/
params.fastaFile = "sequenceFromEntrez.fasta"
params.hmmerRes = "hmmer_results.txt"

resFile = file(params.hmmerRes)
fastaFile = file(params.fastaFile)

/*
* Get a file with the sequence lengths
*/
lenF = file("sequenceLens.txt") //file to be created
Channel
.fromPath("$params.fastaFile")
.splitFasta( record: [id: true, seqString: true ])
.subscribe { record -> lenF.append("${record.id}\t${record.seqString.size()}\n")} //write length of the sequences to the file


process getBEDfile {

//container 'genomicpariscentre/bedtools'

input:

    file resFile
    file lenF
    
output:

    
file "domainCoordinates_v2.bed" into BED


script:
//For info on BEDtools see https://bedtools.readthedocs.io/en/latest/
// In command line perl, the parameter -e means to run the following commands in command line, write the perl expression after this parameter.
//-p means to repeat the command for each line in the file.
"""
#Extract the coordinates of the protein domains from the hmmer results
grep -i 'Insulin' $resFile  | cut -f1-3 | sort -u | perl -p -e 's/^>\\s+//' | perl -p -e 's/ .*]//'|   column -t| sed 's/>//'  > domainCoordinates_v1.bed

#Correct the first coordinate on the BED file.
slopBed -i domainCoordinates_v1.bed -g $lenF  -l 1 -r 0 > domainCoordinates_v2.bed 
"""

}


/*
 * Get a FASTA file with the sequences corresponding to the protein domains.
 * To facilitate the interpretation of the MSA, add the species name to the header of the final fasta file
*/
/*
process getFASTAwithDomains {
 
input:

  file fastaFile
  file bedFile from BED

 output:
  file "Sequences4MSA.fasta" into domainFile

script:
"""
#Get a tab-delimited file with ID and Species
 grep ">" $fastaFile | perl -p -e 's/>//' | perl -p -e 's/ .+\\[/\\t/'| perl -p -e 's/\\]\$//' | perl -p -e 's/ /_/' | sort -k1,1  > Ids_Species.txt
 #Get a tab-delimited file with ID and domain sequence
 #For info on BEDtools see https://bedtools.readthedocs.io/en/latest/
 fastaFromBed -tab -fi $fastaFile  -bed $bedFile | perl -p -e 's/\\:.+\\t/\\t/' | sort -k1,1 > DomainSequences.tsv
 #Add the species name, and get a FASTA file with the domain sequences
 join -1 1 -2 1 Ids_Species.txt DomainSequences.tsv | perl -p -e 's/^/>/' | perl -p -e 's/ /_/' | perl -p -e 's/ /\\n/' > Sequences4MSA.fasta
"""
}

//MSA

process MSA {
  container = 'k47swp/clustal_omega'
  input:
  file domain from domainFile
  
  output: 
  file "A2_T1_MSA.txt" into MSAdone

  script:
  """
  clustalo --help > A2_T1_MSA.txt

  """
}
*/

MSAdone
.collectFile(name: file("MSAdone"))

