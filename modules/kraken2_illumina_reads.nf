process kraken2_remove_cont_illumina {
    conda "./env/krona.yml"
    storeDir "${params.output}/01.Pre_processing/kraken2_reports"

    input:
        tuple val(sample_id), path(merged_reads)
        //dependency token: forces this to wait on kraken2_db when the database is built
        val(kraken2_db_ready)

    output:
    tuple val(sample_id),
          path("${sample_id}_report.txt"),
          path("${sample_id}_output.txt"),
          emit: kraken2_short_all


    script:
    """
    mkdir -p ${params.output}/01.Pre_processing/kraken2_reports

    kraken2 \\
    --threads ${task.cpus} \\
    --db ${params.kraken2_database} \\
    --memory-mapping \\
    --gzip-compressed \\
    --paired ${merged_reads[0]} ${merged_reads[1]} \\
    --output ${params.output}/01.Pre_processing/kraken2_reports/${sample_id}_output.txt \\
    --use-names \\
    --report ${params.output}/01.Pre_processing/kraken2_reports/${sample_id}_report.txt
    """
}

process extract_kraken2_reads_illumina {
    conda "./env/krona.yml"
    storeDir "${params.output}/01.Pre_processing/kraken2_short_reads"

    input:
        tuple val(sample_id),
              path(kraken2_report_short),
              path(kraken2_output_short),
              path(merged_reads)

    output:
        tuple val(sample_id), path("${sample_id}_cleaned_R*.fastq.gz"), emit: decontaminated_reads_short

    script:
    """
    mkdir -p ${params.output}/01.Pre_processing/kraken2_short_reads

    extract_kraken_reads.py \\
    -k ${kraken2_output_short} \\
    --report ${kraken2_report_short} \\
    -s1 ${merged_reads[0]} \\
    -s2 ${merged_reads[1]} \\
    --taxid ${params.filter_taxa_interest} \\
    --include-children \\
    --fastq-output \\
    -o ${params.output}/01.Pre_processing/kraken2_short_reads/${sample_id}_cleaned_R1.fastq \\
    -o2 ${params.output}/01.Pre_processing/kraken2_short_reads/${sample_id}_cleaned_R2.fastq


    gzip -c ${params.output}/01.Pre_processing/kraken2_short_reads/${sample_id}_cleaned_R1.fastq > ${params.output}/01.Pre_processing/kraken2_short_reads/${sample_id}_cleaned_R1.fastq.gz
    gzip -c ${params.output}/01.Pre_processing/kraken2_short_reads/${sample_id}_cleaned_R2.fastq > ${params.output}/01.Pre_processing/kraken2_short_reads/${sample_id}_cleaned_R2.fastq.gz
    """
}