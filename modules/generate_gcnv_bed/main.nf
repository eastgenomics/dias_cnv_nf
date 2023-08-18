process generate_gcnv_bed{
  debug true
  publishDir params.outdir2, mode:'copy'

  input:
  path denoised
  val run_name
  
  output:
  path "*gcnv.bed.gz"
  path "*gcnv.bed.gz.tbi"
  
  """
  python3 nextflow-bin/generate_gcnv_bed.py --copy_ratios $denoised -s --run "$run_name"
  """


}
