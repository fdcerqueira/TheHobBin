process remove_cont_long {
 conda "${projectDir}/env/flye.yml"
 storeDir "${params.output}/01.Pre_processing"
 //errorStrategy "ignore"

input:
tuple val(sample_idl), path(reads_chopper)
tuple val(reference), path(reference)

output:
tuple val(sample_idl), path("${sample_idl}_filt.fastq.gz"), emit: long_reads_host_remove

script:
"""
mkdir -p ${params.output}/01.Pre_processing/processed_reads

minimap2 -ax map-ont ${reference} \\
${reads_chopper} \\
-t ${task.cpus} > ${sample_idl}.contam.sam

samtools view -u -f 4 ${sample_idl}.contam.sam > ${sample_idl}_filtered.sam

samtools bam2fq ${sample_idl}_filtered.sam > ${sample_idl}.fastq.gz

rm ${sample_idl}.contam.sam
rm ${sample_idl}_filtered.sam 

mv cleaned_${sample_idl}.fastq.gz ${params.output}/01.pre_processing/processed_reads/cleaned_${sample_idl}.fastq.gz
"""
}

process remove_cont_short {
    conda "${projectDir}/env/bbmap.yml"
    storeDir "${params.output}/01.Pre_processing"

    input:
    tuple val(sample_idl), path(reads)
    tuple val(reference), path(reference)

    output:
    tuple val(sample_idl), path("${sample_id}_filt_R*.fastq.gz"), emit: short_reads_host_remove
    tuple val(sample_id), path("${sample_id}.bbduk.txt")

    script:
    """
    bbwrap.sh \\
    -Xmx${params.mem} \\
    t=${task.cpus} \\
    minid=0.9 \\
    ref=${reference} \\
    in=${reads[0]} \\
    in2=${reads[1]} \\
    out=${sample_id}_filt_R1.fastq.gz \\
    out2=${sample_id}_filt_R2.fastq.gz \\
    2> ${sample_id}.bbduk.txt
    """
}
