process polypolish_index {
    conda "./env/flye.yml"
    storeDir "${params.output}/03.Post_processing/polishing/polypolish"
    
    input:
    tuple val(sample_idl), path(fasta_assembly), path(reads_short)

    output:
    //tuple val(sample_idl), path("${sample_idl}.{amb,ann,bwt,pac,sa}")
    tuple val(sample_idl), path("${sample_idl}_alignments_1.sam"), emit:alignment1_polypolish
    tuple val(sample_idl), path("${sample_idl}_alignments_2.sam"), emit:alignment2_polypolish
    
    script:
    """
    mkdir -p ${params.output}/03.Post_processing/polishing/polypolish
    mkdir -p ${params.output}/03.Post_processing/polishing/polypolish/index
    
    bwa index \\
        -p ${params.output}/03.Post_processing/polishing/polypolish/index/${sample_idl} \\
        ${fasta_assembly}
    
    bwa mem -t ${task.cpus} \\
        -a ${params.output}/03.Post_processing/polishing/polypolish/index/${sample_idl} \\
        ${reads_short[0]} \\
        > ${sample_idl}_alignments_1.sam
    
    bwa mem -t ${task.cpus} \\
        -a ${params.output}/03.Post_processing/polishing/polypolish/index/${sample_idl} \\
        ${reads_short[1]} \\
        > ${sample_idl}_alignments_2.sam
    """
}

process polypolish {
    conda "./env/flye.yml"
    storeDir "${params.output}/03.Post_processing/polishing/polypolish"
    
    input:
    tuple val(sample_idl), path(alignment1_polypolish), path(alignment2_polypolish), path(fasta_assembly)

    output:
    tuple val(sample_idl), path("${sample_idl}_polished.fasta"), emit:polypolish_assembly
    
    script:
    """
    polypolish filter \\
        --in1 ${alignment1_polypolish} \\
        --in2 ${alignment2_polypolish} \\
        --out1 ${sample_idl}_filtered_1.sam \\
        --out2 ${sample_idl}_filtered_2.sam
    
    polypolish polish \\
        ${fasta_assembly} \\
        ${sample_idl}_filtered_1.sam \\
        ${sample_idl}_filtered_2.sam > ${sample_idl}_polished.fasta
    
    rm ${sample_idl}_filtered_1.sam
    rm ${sample_idl}_filtered_2.sam
    rm -rf ${params.output}/03.Post_processing/polishing/polypolish/index
    rm ${alignment1_polypolish}
    rm ${alignment2_polypolish}
    """
}
