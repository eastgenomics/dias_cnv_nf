#!/bin/bash
# eggd_additional_cnv_tasks 1.0.0
vcf="$1"
output_length="$2"
output_seg="$3"

# -e = exit on error; -x = output each line that is executed to log; -o pipefail = throw an error if there's an error in pipeline
set -e -x -o pipefail

chmod -R 777 nextflow-bin/bcftools-1.18
# Check if both outputs have been turned off and exit
if [ "$output_length" == false ] && [ "$output_seg" == false ]; then
   echo "Invalid option combination, this will not output anything. :)"
   exit 1
fi

# Add length to vcf if required
if [ "$output_length" == true ]; then

    nextflow-bin/bcftools-1.18/bcftools index $vcf
    python3 nextflow-bin/add_length.py --vcf $vcf

fi

# Create seg file if required
if [ "$output_seg" == true ]; then

    python3 nextflow-bin/make_seg.py --vcf $vcf

fi


