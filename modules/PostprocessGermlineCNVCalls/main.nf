process PostprocessGermlineCNVCalls{

  tag "sample $index"
  debug true
  publishDir params.outdir2, mode:'copy'


  input:
  val index
  path ploidy_dir
  path gCNV_dir
  
  output:
  path "vcfs/*segments.vcf", emit:segments_vcf
  path "vcfs/*intervals.vcf", emit:intervals_vcf
  path "vcfs/*denoised_copy_ratios.tsv", emit:denoised
  
  """
  bash nextflow-bin/PostprocessGermlineCNVCalls.sh $index $ploidy_dir $gCNV_dir

  """


}
