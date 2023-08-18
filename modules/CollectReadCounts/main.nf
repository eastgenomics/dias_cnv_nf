process CollectReadCounts {

    debug true
    //publishDir params.outdir2, mode:'copy'
    tag "${reads[0]}"
    
    input:    
    tuple val(sample_id), path(reads) 
    path interval_list
   
    output:
    
    path "*_basecount.hdf5", emit:hdf5
    
    script:

    """
    #!/bin/bash
    echo "Running ${reads[0]} ${reads[1]}"
    
    gatk CollectReadCounts \\
      -I ${reads[0]} \\
      -L $interval_list -imr OVERLAPPING_ONLY \\
      -O ${reads[0].getBaseName()}_basecount.hdf5

    """
}
