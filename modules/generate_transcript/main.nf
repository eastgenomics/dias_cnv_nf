process generate_transcript{

 debug true
 publishDir params.outdir3, mode:'copy'
 tag "$panel_bed"
 
 input:
 path panel_bed
 
 output:
 path "*transcripts.txt", emit:transcript
 
 """
 #!/bin/bash 
 set -euxo pipefail
 bash nextflow-bin/transcript.sh $panel_bed
 """

}
