process annotate_excluded_regions {

    debug true
    publishDir params.outdir5, mode:'copy'
    tag "$panel_bed"
    
    input:    
    path panel_bed
    path additional_regions
    path excluded_regions
    path cds_hgnc
    path cds_gene
   
    output:
    path "${panel_bed.toString().split("-")[0]}-annotated*.tsv",emit:additional_files
    
    script:

    """
    #!/bin/bash
    echo "Running $panel_bed"
    
    bash nextflow-bin/eggd_annotate_excluded_regions.sh $panel_bed $additional_regions $excluded_regions $cds_hgnc $cds_gene ${panel_bed.toString().split("-")[0]}

    """
}
