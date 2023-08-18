process gatk {
  
  debug true
  publishDir params.outdir2, mode:'copy', pattern: "*excluded_intervals.bed"
  
  input:
  path hdf5
  path interval_list
  path annotation_tsv
  val run_name
  val FilterIntervals_args
  
  output:
  
  path "snv_batch.txt", emit:snv_batch
  path "filtered.interval_list", emit:filtered_interval_list
  path "preprocessed.bed"
  path "filtered.bed"
  path "*excluded_intervals.bed",emit:excluded_intervals_bed
  path "ploidy-dir/*", emit:ploidy_dir
  path "gCNV-dir/*", emit:gCNV_dir
  
  
  """
    bash nextflow-bin/code_gatk.sh "$hdf5" $interval_list $annotation_tsv $run_name "$FilterIntervals_args"

  """
  

}
