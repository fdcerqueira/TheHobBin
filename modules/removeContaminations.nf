process removeContaminations {

    conda "${projectDir}/env/bbmap.yml"
    publishDir "${params.output}/01.Pre_processing/processed_reads"
    
    input:
    tuple val(sample_id), path(merged_reads)
    tuple val(reference), path(reference)

    output:
    tuple val(sample_id), path("cleaned-${sample_id}_R*.fastq.gz"), emit: cleaned_reads
    tuple val(sample_id), path("${sample_id}.bbduk.txt")

    script:
    """
    bbwrap.sh \\
    -Xmx${params.mem} \\
    t=${task.cpus} \\
    minid=0.9 \\
    ref=${reference} \\
    in=${merged_reads[0]} \\
    in2=${merged_reads[1]} \\
    out=cleaned-${sample_id}_R1.fastq.gz \\
    out2=cleaned-${sample_id}_R2.fastq.gz \\
    2> ${sample_id}.bbduk.txt
    """
}
