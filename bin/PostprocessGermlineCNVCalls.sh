index="$1"
ploidy_calls="$2"
ploidy_model="$3"
CNV_calls="$4"
CNV_model="$5"
echo "ploidy_calls is $ploidy_calls"
echo "ploidy_model is $ploidy_model"
echo "CNV_calls is $CNV_calls"
echo "CNV_model is $CNV_model"

# takes CNV-model in, spits vcfs out
echo "Running PostprocessGermlineCNVCalls"

mkdir vcfs
gatk_path=$pwd
export HOME=$gatk_path
source activate gatk
gatk PostprocessGermlineCNVCalls \
        --sample-index ${index} \
        --autosomal-ref-copy-number 2 \
        --allosomal-contig X \
        --allosomal-contig Y \
        --contig-ploidy-calls ${ploidy_calls} \
        --calls-shard-path ${CNV_calls} \
        --model-shard-path ${CNV_model} \
        --output-genotyped-intervals vcfs/sample_${index}_intervals.vcf \
        --output-genotyped-segments vcfs/sample_${index}_segments.vcf \
        --output-denoised-copy-ratios vcfs/sample_${index}_denoised_copy_ratios.tsv

#Rename output vcf files based on the sample they contain information about
chmod -R 777 nextflow-bin/bcftools-1.18
sample_name=$(nextflow-bin/bcftools-1.18/bcftools view "vcfs/sample_${index}_segments.vcf" -h | tail -n 1 | cut -f 10 )
echo "sample name is ${sample_name}"
mv vcfs/sample_${index}_intervals.vcf vcfs/${sample_name}_intervals.vcf
mv vcfs/sample_${index}_intervals.vcf.idx vcfs/${sample_name}_intervals.vcf.idx
mv vcfs/sample_${index}_segments.vcf vcfs/${sample_name}_segments.vcf
mv vcfs/sample_${index}_denoised_copy_ratios.tsv vcfs/${sample_name}_denoised_copy_ratios.tsv
