nextflow.enable.dsl=2

// -------------------------------------
// INCLUDE MODULES
// -------------------------------------

include { getting_panel_for_bed } from './modules/getting_panel_for_bed'
include { generate_bed_vep } from './modules/generate_bed_vep'
include { generate_bed_excluded_annotation } from './modules/generate_bed_excluded_annotation'
include { CollectReadCounts } from './modules/CollectReadCounts'
include { gatk } from './modules/gatk'
include { PostprocessGermlineCNVCalls } from './modules/PostprocessGermlineCNVCalls'
include { generate_gcnv_bed } from './modules/generate_gcnv_bed'
include { filter_b4_annotation } from './modules/filter_b4_annotation'
include { normalise } from './modules/normalise'
include { vep } from './modules/vep'
include { generate_transcript } from './modules/generate_transcript'
include { filter_after_annotation } from './modules/filter_after_annotation'
include { additional_cnv_tasks } from './modules/additional_cnv_tasks'
include { annotate_excluded_regions } from './modules/annotate_excluded_regions'
include { generate_variannt_workbook } from './modules/generate_variannt_workbook'

// -------------------------------------
// RUNNING WORKFLOWS
// -------------------------------------

workflow {
//run gatk cnv call

bam_ch=Channel.fromFilePairs(params.bam, checkIfExists: true)
CollectReadCounts(bam_ch,params.interval_list)
gatk(CollectReadCounts.out.hdf5.collect(),params.interval_list,params.annotation_tsv,params.run_name,params.FilterIntervals_args)
    
index_ch=Channel.from(0..params.num_sample-1)
//index_ch.view()
PostprocessGermlineCNVCalls(index_ch,gatk.out.ploidy_dir,gatk.out.gCNV_dir)
//Generate gcnv bed files from copy ratios for visualisation in IGV
generate_gcnv_bed(PostprocessGermlineCNVCalls.out.denoised.collect(),params.run_name)

//generate bed files

getting_panel_for_bed(params.epic_menifest,params.gene_panels)
sample_file_ch=PostprocessGermlineCNVCalls.out.segments_vcf
                           .map { file_path -> file_path.getSimpleName()}
                           .view()
generate_bed_vep(sample_file_ch,getting_panel_for_bed.out.menifest_file,params.gene_panels,params.exons_nirvana,params.nirvana_genes2transcripts,params.flank_vep,params.additional_regions)
generate_bed_excluded_annotation(sample_file_ch,getting_panel_for_bed.out.menifest_file,params.gene_panels,params.exons_nirvana,params.nirvana_genes2transcripts,params.additional_regions)

//running vep 

vcf_ch=PostprocessGermlineCNVCalls.out.segments_vcf  
vep_bed_file_ch=generate_bed_vep.out.vep_bed_file

vcf_ch.view()
vep_bed_file_ch.view()
    
vcf_ch
   .map { [it.toString().split("-")[0].split("/")[5],
      it] }
   .set { vcf_ch }
   
vep_bed_file_ch
   .map { [it.toString().split("-")[0].split("/")[4],
      it] }
   .set { vep_bed_file_ch }
   
vcf_ch
    .combine(vep_bed_file_ch, by: 0)
    .map { id, vcf, vep_bed -> [vcf, vep_bed] }
    .view()


filter_b4_annotation(vcf_ch
    .combine(vep_bed_file_ch, by: 0)
    .map { id, vcf, vep_bed -> [vcf, vep_bed] })
    
normalise(filter_b4_annotation.out.filtered_vcf,params.ref_bcftools)


vep(normalise.out.post_filtering_vcf,params.fasta,params.cache_file,params.field_str,params.buffer_size,params.cache_version)

generate_transcript(generate_bed_vep.out.vep_bed_file)

vcf_ch1=vep.out.temp_vcf
transcript_ch=generate_transcript.out.transcript

vcf_ch1.view()
transcript_ch.view()

vcf_ch1
   .map { [it.toString().split("-")[0].split("/")[4],
      it] }
   .set { vcf_ch1 }
   
transcript_ch
   .map { [it.toString().split("-")[0].split("/")[4],
      it] }
   .set { transcript_ch }
   
vcf_ch1
    .combine(transcript_ch, by: 0)
    .map { id, vcf, transcript -> [vcf, transcript] }
    .view()


filter_after_annotation(vcf_ch1
    .combine(transcript_ch, by: 0)
    .map { id, vcf, transcript -> [vcf, transcript] })
    
//run additional_cnv_tasks
additional_cnv_tasks(filter_after_annotation.out.vep_annotated_vcf,params.output_length,params.output_seg)

//run annotate_excluded_regions
annotate_excluded_regions(generate_bed_excluded_annotation.out.excluded_bed_file,params.additional_regions,gatk.out.excluded_intervals_bed,params.cds_hgnc,params.cds_gene)

//generate variant workbook

vcf_ch2=additional_cnv_tasks.out.vcf_for_workbook
additional_files_ch=annotate_excluded_regions.out.additional_files
vcf_ch2
   .map { [it.toString().split("-")[0].split("/")[4],
      it] }
   .set { vcf_ch2 }
   
additional_files_ch
   .map { [it.toString().split("-")[0].split("/")[4],
      it] }
   .set { additional_files_ch }
   
vcf_ch2
    .combine(additional_files_ch, by: 0)
    .map { id, vcf, additional_files -> [vcf, additional_files] }
    .view()

generate_variannt_workbook(vcf_ch2
    .combine(additional_files_ch, by: 0)
    .map { id, vcf, additional_files -> [vcf, additional_files] },params.exclude_columns,params.acmg,params.add_comment_column,
params.keep_tmp,params.reorder_columns,params.summary,params.keep_filtered,getting_panel_for_bed.out.menifest_file,params.additional_sheet_names)
}




