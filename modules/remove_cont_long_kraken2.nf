process fastp_longworkflow {
        conda "${projectDir}/env/assembly.yml"
        storeDir "${params.output}/01.pre_processing/fastp"

        input:
        tuple val(sample_id), path(reads_short) 
        
        output:
        tuple val(sample_id), path("${sample_id}_R*.fastq.gz"), emit: reads
        path("${sample_id}.fastp.json"), emit: json
        path("${sample_id}.fastp.html"), emit: html
        
        script:
        """
        mkdir -p ${params.output}/01.pre_processing/fastp

        fastp -i ${reads_short[0]} \\
        -I ${reads_short[1]} \\
        -o ${sample_id}_R1.fastq.gz \\
        -O ${sample_id}_R2.fastq.gz \\
        --detect_adapter_for_pe -w ${task.cpus} \\
        -j ${sample_id}.fastp.json \\
        --html ${sample_id}.fastp.html 
        """  
    }  

process kraken2_remove_cont_long{
    conda "./env/krona.yml"
    storeDir "${params.output}/01.pre_processing/kraken2_long_reads"

    input:
        tuple val(sample_idl), path(reads_chopper)
        //dependency token: forces this to wait on kraken2_db when the database is built
        val(kraken2_db_ready)

    output:
        tuple val(sample_idl), path("${sample_idl}_report.txt"), emit: kraken2_report
        tuple val(sample_idl), path("${sample_idl}_output.txt"), emit: kraken2_output

    script:
    """
    mkdir -p ${params.output}/01.pre_processing/kraken2_long_reads

    kraken2 \\
    --threads ${task.cpus} \\
    --db ${params.kraken2_database} \\
    --memory-mapping \\
    --gzip-compressed ${reads_chopper} \\
    --output ${sample_idl}_output.txt \\
    --use-names \\
    --report ${sample_idl}_report.txt
    """
}

process extract_kraken2_reads {

    conda "./env/krona.yml"
    storeDir "${params.output}/01.pre_processing/kraken2_long_reads"

    input:
        tuple val(sample_idl), path(kraken2_report)
        tuple val(sample_idl), path(kraken2_output)
        tuple val(sample_idl), path(reads_chopper)

    output:
        tuple val(sample_idl), path("${sample_idl}_decontaminated.fastq.gz"), emit: decontaminated_reads

    script:
    """
    extract_kraken_reads.py \\
    -k ${kraken2_output} \\
    --report ${kraken2_report} \\
    -s ${reads_chopper} \\
    --taxid ${params.filter_taxa_interest} \\
    --include-children \\
    --fastq-output \\
    --output ${sample_idl}_decontaminated.fastq

     gzip -c ${sample_idl}_decontaminated.fastq > ${sample_idl}_decontaminated.fastq.gz
    """
}


process kraken2_remove_cont_short{
    conda "./env/krona.yml"
    storeDir "${params.output}/01.Pre_processing/kraken2_short_reads"

    input:
        tuple val(sample_id), path(reads)
        //dependency token: forces this to wait on kraken2_db when the database is built
        val(kraken2_db_ready)

    output:
        tuple val(sample_id), path("${sample_id}_report.txt"), emit: kraken2_report_short
        tuple val(sample_id), path("${sample_id}_output.txt"), emit: kraken2_output_short

    script:
    """
    mkdir -p ${params.output}/01.Pre_processing/kraken2_short_reads

    kraken2 \\
    --threads ${task.cpus} \\
    --db ${params.kraken2_database} \\
    --memory-mapping \\
    --gzip-compressed \\
    --paired ${reads[0]} ${reads[1]} \\
    --output ${sample_id}_output.txt \\
    --use-names \\
    --report ${sample_id}_report.txt
    """
}

process extract_kraken2_reads_short {

    conda "./env/krona.yml"
    storeDir "${params.output}/01.Pre_processing/kraken2_short_reads"

    input:
        tuple val(sample_id), path(kraken2_report_short)
        tuple val(sample_id), path(kraken2_output_short)
        tuple val(sample_id), path(reads)

    output:
        tuple val(sample_id), path("${sample_id}_cleaned_R*.fastq.gz"), emit: decontaminated_reads_short

    script:
    """
    extract_kraken_reads.py \\
    -k ${kraken2_output_short} \\
    --report ${kraken2_report_short} \\
    -s1 ${reads[0]} \\
    -s2 ${reads[1]} \\
    --taxid ${params.filter_taxa_interest} \\
    --include-children \\
    --fastq-output \\
    -o ${sample_id}_cleaned_R1.fastq \\
    -o2 ${sample_id}_cleaned_R2.fastq


    gzip -c ${sample_id}_cleaned_R1.fastq > ${sample_id}_cleaned_R1.fastq.gz
    gzip -c ${sample_id}_cleaned_R2.fastq > ${sample_id}_cleaned_R2.fastq.gz
    """
}