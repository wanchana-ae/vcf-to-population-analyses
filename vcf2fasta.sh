conda activate vcf-kit
VCF=$1
INPUT_ID=${VCF##*/}
SampleID=`echo $INPUT_ID | cut -d "." -f 1`
vk phylo fasta ${VCF} > ${SampleID}.fasta
