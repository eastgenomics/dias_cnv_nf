process additional_cnv_tasks {

    debug true
    publishDir params.outdir4, mode:'copy'
    tag "$vcf"
    
    input:    
    path vcf
    val output_length
    val output_seg
   
    output:
    
    path "*.seg"
    path "*vcf.gz", emit:vcf_for_workbook
    
    script:

    """
    #!/bin/bash
    echo "Running $vcf"
    
    bash nextflow-bin/eggd_additional_cnv_tasks.sh $vcf $output_length $output_seg

    """
}
