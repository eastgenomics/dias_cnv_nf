hdf5="${1}"
preprocessed_interval_list="$2"
annotation_tsv="$3"
run_name="$4"
FilterIntervals_args="$5"
echo "hdf5 are $hdf5"

stringarray=($hdf5)


for i in "${stringarray[@]}"
do
  :
  echo "--input $i" >> snv_batch.txt
 
done


basecount_file=`cat snv_batch.txt`
echo $basecount_file

# filters out low coverage or not uniquely mappable regions
echo "Running FilterIntervals for the preprocessed intervals with sample basecounts"
gatk FilterIntervals \
       -L $preprocessed_interval_list -imr OVERLAPPING_ONLY \
        --annotated-intervals $annotation_tsv \
       $basecount_file $FilterIntervals_args \
      -O filtered.interval_list
      
echo "Identifying excluded intervals from CNV calling on this run"
# Convert interval_list to BED files      
gatk IntervalListToBed \
        -I $preprocessed_interval_list \
        -O preprocessed.bed
        
        
gatk IntervalListToBed \
        -I filtered.interval_list \
        -O filtered.bed

# Identify regions that are in preprocessed but not in filtered, ie the excluded regions        
nextflow-bin/bedtools intersect -v -a preprocessed.bed -b filtered.bed > excluded_intervals.bed

# takes the base count tsv-s from the previous step, optional target_bed, and a contig plody priors tsv
# outputs a ploidy model and ploidy-calls for each sample
echo "Running DetermineGermlineContigPloidy for the calculated basecounts"
mkdir ploidy-dir
gatk_path=$pwd
#chmod -R 777 $gatk_path
export HOME=$gatk_path
source activate gatk

gatk DetermineGermlineContigPloidy \
        -L filtered.interval_list -imr OVERLAPPING_ONLY \
        $basecount_file \
        --contig-ploidy-priors nextflow-bin/prior_prob.tsv \
       --output-prefix ploidy \
        -O ploidy-dir

# takes the base count tsv-s, target bed and contig ploidy calls from the previous steps
# outputs a CNVcalling model and copy ratio files for each sample
echo "Running GermlineCNVCaller for the calculated basecounts using the generated ploidy file"

mkdir gCNV-dir
gatk GermlineCNVCaller \
        -L filtered.interval_list -imr OVERLAPPING_ONLY \
        --annotated-intervals $annotation_tsv \
        --run-mode COHORT \
        $basecount_file \
        --contig-ploidy-calls ploidy-dir/ploidy-calls \
        --output-prefix CNV \
        -O gCNV-dir

mv excluded_intervals.bed ${run_name}_excluded_intervals.bed






