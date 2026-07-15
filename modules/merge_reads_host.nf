process merge_reads_host {    
    publishDir "${params.output}/01.Pre_processing/merged_reads"

    input:
    tuple val(sample_id), path(reads) 
 
    output:
    tuple val(sample_id), path("M_${sample_id}_R*.fastq.gz"), emit: merged_reads
  
    script:
    """
    if [[ ${sample_id} == *"L00"* ]]; then
        echo "Merging ${sample_id} R1"
        cat ${reads[0]} > M_${sample_id}_R1.fastq.gz
        echo "Merging ${sample_id} R2"
        cat ${reads[1]} > M_${sample_id}_R2.fastq.gz
    else 
        echo "Copying ${sample_id} R1"
        cp ${reads[0]} M_${sample_id}_R1.fastq.gz
        echo "Copying ${sample_id} R2"
        cp ${reads[1]} M_${sample_id}_R2.fastq.gz
    fi
    """
}