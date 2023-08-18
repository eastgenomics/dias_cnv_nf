process vep {
    tag "$post_filtering_vcf"
    debug true
    //publishDir params.outdir3, mode:'copy'
    
    input:

    path post_filtering_vcf
    path fasta
    path cache_dir
   
    val field_str
    val buffer_size
    val cache_version
    
    output:
    
    path "*_temp_annotated.vcf" , emit:temp_vcf
    
    
    """
   #!/bin/bash 
   set -euxo pipefail
   echo "Running $post_filtering_vcf"
   mkdir "cache_file_folder"
   tar xf $cache_dir -C cache_file_folder
   
    vep --cache --cache_version $cache_version --dir_cache cache_file_folder \
      -i $post_filtering_vcf --format vcf -o ${post_filtering_vcf.getBaseName()}_temp_annotated.vcf \
      --vcf --no_stats --fasta $fasta \
      --offline --refseq --exclude_predicted --symbol --hgvs --hgvsg --check_existing --variant_class --numbers --exclude_null_alleles --force_overwrite \
      --assembly GRCh37 \
      --fields "$field_str" \
      --buffer_size $buffer_size \
      --fork \$(grep -c ^processor /proc/cpuinfo) \
      --compress_output bgzip --shift_3prime 1

    """
}

