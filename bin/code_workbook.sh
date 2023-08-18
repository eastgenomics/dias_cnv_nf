#!/bin/bash

set -exo pipefail
vcfs="$1"
menifest="$2"
sample_prefix="$3"
exclude_columns="$4"
acmg="$5"
add_comment_column="$6"
keep_tmp="$7"
reorder_columns="${8}"
output_prefix="${9}"
summary="${10}"
sub_job_id="${11}"
parent_job_id="${12}"
keep_filtered="${13}"
additional_sheet_names="${14}"
additional_files="${15}"

job_id=${sub_job_id}
workflow_id="Dias_nextflow ${parent_job_id}"
clinical_indication=$(grep -w $sample_prefix $menifest | cut -d , -f2)
panel=$(grep -w $sample_prefix $menifest | cut -d , -f4)
   
args=""
if [ "$additional_files" ]; then args+="--additional_files $additional_files "; fi
if [ "$images" ]; then args+="--images $(find ~/in/images -type f -name "*" | sort) "; fi
if [ "$image_sheet_names" ]; then args+="--image_sheets ${image_sheet_names} "; fi
if [ "$image_sizes" ]; then args+="--image_sizes ${image_sizes} "; fi
if [ "$clinical_indication" ]; then args+="--clinical_indication ${clinical_indication} "; fi
if [ "$exclude_columns" ]; then args+="--exclude ${exclude_columns} "; fi
if [ "$include_columns" ]; then args+="--include ${include_columns} "; fi
if [ "$reorder_columns" ]; then args+="--reorder ${reorder_columns} "; fi
if [ "$rename_columns" ]; then args+="--rename ${rename_columns} "; fi
if [ "$add_samplename_column" == true ]; then args+="--add_name "; fi
if [ "$add_comment_column" == true ]; then args+="--add_comment_column "; fi
if [ "$sheet_names" ]; then args+="--sheets ${sheet_names} "; fi
if [ "$additional_sheet_names" ]; then args+="--additional_sheets ${additional_sheet_names} "; fi
if [ "$print_columns" == true ]; then args+="--print_columns "; fi
if [ "$summary" ]; then args+="--summary ${summary} "; fi
if [ "$human_filter" ]; then args+="--human_filter ${human_filter} "; fi
if [ "$acmg" == true ]; then args+="--acmg "; fi
if [ "$keep_filtered" == true ]; then args+="--keep "; fi
if [ "$keep_tmp" == true ]; then args+="--keep_tmp "; fi
if [ "$print_header" == true ]; then args+="--print_header "; fi
if [ "$merge_vcfs" == true ]; then args+="--merge "; fi
if [ "$colour_cells" ]; then args+="--colour ${colour_cells} "; fi
if [ "$output_name" ]; then args+="--sample ${output_name} "; fi
if [ "$output_prefix" ]; then args+="--output ${output_prefix} "; fi
if [ "$workflow_id" ]; then args+="--workflow ${workflow_name} ${workflow_id} "; fi
if [ "$job_id" ]; then args+="--job_id ${job_id} "; fi
if [ "$types" ]; then args+="--types ${types} "; fi
if [ "$panel" ]; then args+="--panel ${panel} "; fi
if [ "$clinical_indication" ]; then args+="--clinical_indication ${clinical_indication} "; fi
if [ "$decipher" == true ]; then args+="--decipher "; fi

chmod -R 777 nextflow-bin/bcftools-1.18
args+="--out_dir ./ "
echo "$args" 
export BCFTOOLS_PLUGINS=nextflow-bin/bcftools-1.18/plugins
if [ "$filter" ]; then
nextflow-bin/generate_workbook.py --vcfs $vcfs $args --filter "${filter}"
else
nextflow-bin/generate_workbook.py --vcfs $vcfs $args
fi

