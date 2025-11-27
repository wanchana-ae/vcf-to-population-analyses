ml load plink
ml load admixture
VCF=$1
INPUT_ID=${VCF##*/}
SampleID=`echo $INPUT_ID | cut -d "." -f 1`
plink --double-id --make-bed --out ${SampleID} \
--vcf ${VCF} --allow-extra-chr
for K in 2 3 4 5 6 7 8 9 10 11 12 ; do admixture --cv=10 ${SampleID}.bed -j64 $K | tee log${K}.out; done
grep "CV" *out | awk '{print $3"\t"$4}' | sed -e 's/(//;s/)//;s/://;s/K=//' > FILE.cv.error
