process generate_variannt_workbook{

  debug true
  tag "${reads[0].toString().split("-")[0]} ${reads[1].toString().split("-")[0]}"
  publishDir params.outdir6, mode:'copy'
  
  input:
  path(reads)
  val exclude_columns
  val acmg
  val add_comment_column
  val keep_tmp
  val reorder_columns
  val summary
  val keep_filtered
  path menifest
  val additional_sheet_names
  
  
  output:
  //path "*{.split.vcf.gz,filter.vcf.gz}"
  path "*xlsx"
  
  
  
  """
    echo "Running ${reads[0]} ${reads[1]}"
    parent_job_id=$DX_JOB_ID
    echo "parent job id: \$parent_job_id"
    
    sub_job_id=\$DX_JOB_ID
    echo "sub job id: \$sub_job_id"
    
    bash nextflow-bin/code_workbook.sh ${reads[0]} $menifest "${reads[0].toString().split("-")[0]}" "$exclude_columns" "$acmg" \\
  "$add_comment_column" $keep_tmp "$reorder_columns" "${reads[0].toString().split("_")[0]}" "$summary" "\$sub_job_id" "\$parent_job_id" $keep_filtered $additional_sheet_names ${reads[1]}
   
  """

}
